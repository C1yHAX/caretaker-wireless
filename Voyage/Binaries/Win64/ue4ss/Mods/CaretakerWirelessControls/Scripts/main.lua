-- Caretaker Wireless Controls 1.4.2. Independent of all game interaction bindings.
local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])')
local config=dofile(folder..'config.lua')
local M={}
local pending=false
local function valid(o)return o and o:IsValid()end
local function log(s)print('[CaretakerWirelessControls] '..s..'\n')end
local classes={BP_Module_WirelessResourceTransmitter_C=true,BP_WirelessResource_Socket_Base_C=true}
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
local key=Key[config.KeyName]
if not key or not RegisterKeyBind or not LoopInGameThreadWithDelay then
    log('Unavailable key or scheduler; controls inactive')
    return M
end
if IsKeyBindRegistered and IsKeyBindRegistered(key,{})then
    log('Key already used by another mod; choose a different KeyName in config.lua')
    return M
end
-- The input thread only sets a flag. Unreal calls stay on the game thread.
RegisterKeyBind(key,{},request)
LoopInGameThreadWithDelay(50,function()
    if not pending then return end
    pending=false
    local ok,err=pcall(M.open)
    if not ok then log('Open failed: '..tostring(err))end
end)
log('1.4.2: '..config.KeyLabel..' opens channel settings; E/F/game input unchanged')
return M
