-- Caretaker Wireless Controls 1.0.0. Independent of all game interaction bindings.
local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])')
local function log(s)print('[CaretakerWirelessControls] '..s..'\n')end
local loaded,config=pcall(dofile,folder..'config.lua')
-- Recipe recovery also works when the channel hotkey is disabled or occupied.
dofile(folder..'availability.lua').start()
local M={}
if not loaded or type(config)~='table' then
    log('Cannot read Scripts/config.lua; fix the Lua syntax and restart. Channel hotkey inactive.')
    return M
end
if type(config.MaxReach)~='number' or config.MaxReach<=0 or config.MaxReach~=config.MaxReach then
    config.MaxReach=350
end
local pending=false
local function valid(o)return o and o:IsValid()end
local classes=dofile(folder..'devices.lua')
local function device(a)
    for _=1,4 do
        if not valid(a)then return end
        if classes[a:GetClass():GetFName():ToString()]then return a end
        a=a:GetAttachParentActor()
    end
end
function M.target(pc)
    local pawn=pc.Pawn
    if not valid(pawn)then return end
    local pointer=pawn.InteractiveDetectorPointerComponent
    if not valid(pointer)then return end
    local component=pointer:GetHoverReference()
    if not valid(component)then return end
    local a=device(component:GetOwner())
    if not valid(a)then return end
    local camera=pc.PlayerCameraManager:GetCameraLocation()
    local point=component:K2_GetComponentLocation()
    local reach=math.min(config.MaxReach,pointer.MaxReach)
    local dx,dy,dz=point.X-camera.X,point.Y-camera.Y,point.Z-camera.Z
    if dx*dx+dy*dy+dz*dz>reach*reach then return end
    return a
end
function M.open()
    local pc=FindFirstOf('PlayerController')
    local state=FindFirstOf('VoyageGameStateSubsystem')
    if not valid(pc)or not valid(state)or not state:IsPlaying()then return false end
    if pc:HasActiveDialog()or pc.bShowMouseCursor then return false end
    local a=M.target(pc)
    if not valid(a)then return false end
    local data=LoadAsset('/Game/Data/UI/Dialogs/DA_Dialog_Customize.DA_Dialog_Customize')
    if not valid(data)then return false end
    local gi=FindFirstOf('VoyageGameInstance')
    local dialog=gi:ShowCommonDialog(pc,data)
    if not valid(dialog)then return false end
    dialog:SetInteractiveSource(a.WirelessChannelControl,a)
    return true
end
local function request()pending=true end
local function name(value)
    return type(value)=='string' and value:match('^%s*(.-)%s*$'):upper() or nil
end
local keyName=name(config.KeyName)
local key=keyName and Key and Key[keyName]
if not key then
    log('Unknown KeyName in Scripts/config.lua. Use a UE4SS key name such as F8 or OEM_THREE; restart after editing.')
    return M
end
local modifiers,labels,seen={},{},{}
local configured=config.Modifiers
if configured==nil then configured={} end
if type(configured)~='table' then
    log('Modifiers must be a list in Scripts/config.lua, e.g. {} or {"CONTROL"}; controls inactive')
    return M
end
local count=0
for index in pairs(configured)do
    count=count+1
    if type(index)~='number' or index<1 or index%1~=0 then
        log('Modifiers must be a sequential list in Scripts/config.lua; controls inactive')
        return M
    end
end
for i=1,count do
    local modifier=name(configured[i])
    if modifier=='CTRL' then modifier='CONTROL' end
    if not modifier or (modifier~='CONTROL' and modifier~='ALT' and modifier~='SHIFT') or not ModifierKey or not ModifierKey[modifier] then
        log('Unknown modifier in Scripts/config.lua; use CONTROL, ALT or SHIFT. Controls inactive')
        return M
    end
    if not seen[modifier] then
        modifiers[#modifiers+1]=ModifierKey[modifier]
        labels[#labels+1]=modifier
        seen[modifier]=true
    end
end
labels[#labels+1]=keyName=='OEM_THREE' and 'OEM_THREE (DE: Ö; US: backtick)' or keyName
local keyLabel=table.concat(labels,'+')
if not RegisterKeyBind or not LoopInGameThreadWithDelay then
    log('Key binding or game-thread scheduler unavailable; controls inactive')
    return M
end
if IsKeyBindRegistered and IsKeyBindRegistered(key,modifiers)then
    log(keyLabel..' already used by another mod; choose a different KeyName/Modifiers in Scripts/config.lua and restart')
    return M
end
-- The input thread only sets a flag. Unreal calls stay on the game thread.
RegisterKeyBind(key,modifiers,request)
LoopInGameThreadWithDelay(50,function()
    if not pending then return end
    pending=false
    local ok,err=pcall(M.open)
    if not ok then log('Open failed: '..tostring(err))end
end)
log('1.0.0: '..keyLabel..' opens channel settings; configure Scripts/config.lua; game input unchanged')
return M
