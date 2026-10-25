-- Restore earned Wireless recipes when the native 1024-slot vault filled up.
-- Never grant a skill, delete a slot, or repeatedly append existing patterns.
local M={}
local specs={}
for _,resource in ipairs({'Petrol','Diesel','Oil','FreshWater','SaltWater','Oxygen','CarbonDioxide','Methane','Steam','Universal'})do
    local skill='DA_Skill_Wireless_'..resource
    for _,role in ipairs({'Transmitter','Receiver'})do
        local item='DA_Wireless_'..resource..'_'..role
        specs[#specs+1]={item='/Game/CaretakerWireless/Items/'..item..'.'..item,
            skill='/Game/CaretakerWireless/Skills/'..skill..'.'..skill}
    end
end
for _,kind in ipairs({'Electric','Fuel','Gas','Water'})do
    local item='DA_Module_WallSocket_'..kind
    local skill='DA_Skill_Engineering_Wall_Socket_'..kind
    specs[#specs+1]={item='/Game/Data/Assets/Cable/'..item..'.'..item,
        skill='/Game/Data/Assets/Skill/Cables/'..skill..'.'..skill}
end
for _,item in ipairs({'DA_Module_WirelessResourceTransmitter','DA_Module_WirelessResourceTransmitter_Socket_Electricity','DA_Module_Wireless_Relay'})do
    specs[#specs+1]={item='/Game/Data/Assets/Cable/'..item..'.'..item}
end
local function valid(o)return o and o:IsValid()end
local function asset(path)
    local o=StaticFindObject(path)
    if not valid(o)then o=LoadAsset(path)end
    return o
end
function M.repair(pc)
    if not valid(pc)or not valid(pc.Pawn)or not valid(pc.PlayerState)then return 0 end
    local vault=pc:GetInventoryComponent(2)
    local gp=StaticFindObject('/Script/Voyage.Default__VoyageGameplayBlueprintFunctionLibrary')
    if not valid(vault)or not valid(gp)or vault.Type~=2 then return 0 end
    -- Capacity is only an upper bound, not a preallocated list. Keep room for
    -- the next unlock, including recipes already lost in an older save.
    local needed=vault:GetNumOccupiedSlots()+64
    if vault.Capacity>0 and vault.Capacity<needed then
        vault.Capacity=math.ceil(needed/256)*256
    end
    local restored=0
    for _,s in ipairs(specs)do
        local item=asset(s.item)
        if valid(item)and vault:GetNumItems(item)==0 then
            local earned=gp:HasItemBeenScanned(pc,item)
            if not earned and s.skill then
                local skill=asset(s.skill)
                earned=valid(skill)and gp:HasPlayerSkill(skill,pc)
            end
            if earned then
                vault:AddItem(item,{ItemCount=1,Timestamp=0,Flags=0,Version=0},true,true)
                if vault:GetNumItems(item)>0 then restored=restored+1 end
            end
        end
    end
    if restored>0 then print('[CaretakerWirelessControls] Restored '..restored..' earned Wireless recipes to the vault\n')end
    return restored
end
function M.prepareVault()
    -- Set the pawn template before a saved inventory is deserialized. Expanding
    -- only the live vault afterwards cannot recover slots truncated on load.
    local cls=asset('/Game/Blueprints/BP_FirstPersonCharacter_New.BP_FirstPersonCharacter_New_C')
    if not valid(cls)then return end
    local vault=cls:GetCDO().VaultInventory
    if valid(vault)and vault.Type==2 and vault.Capacity>0 and vault.Capacity<4096 then
        vault.Capacity=4096
    end
end
function M.start()
    RegisterInitGameStatePreHook(function()
        local ok,err=pcall(M.prepareVault)
        if not ok then print('[CaretakerWirelessControls] Vault preparation deferred: '..tostring(err)..'\n')end
    end)
    if not LoopInGameThreadWithDelay then return end
    LoopInGameThreadWithDelay(10000,function()
        local state=FindFirstOf('VoyageGameStateSubsystem')
        if not valid(state)or not state:IsPlaying()then return end
        local ok,err=pcall(M.repair,FindFirstOf('VoyagePlayerController'))
        if not ok then print('[CaretakerWirelessControls] Recipe recovery deferred: '..tostring(err)..'\n')end
    end)
end
return M
