-- Development probe; NEVER packaged. C is supplied by the private test harness.
local C=assert(WIRELESS_RESEARCH_TEST)
local T={ready=false,done=false};WIRELESS_RESEARCH_PROBE=T
function T.log(s)
 local f=assert(io.open(C.output..'/native.log','a'));f:write(s..'\n');f:close()
 print('[WirelessResearchTest] '..s..'\n')
end
function T.valid(o)return o and o:IsValid()end
function T.load(path)
 local s=StaticFindObject('/Script/Engine.Default__KismetSystemLibrary')
 return s:LoadAsset_Blocking(s:Conv_SoftObjPathToSoftObjRef(s:MakeSoftObjectPath(path)))
end
function T.step(ms,fn)
 ExecuteInGameThreadWithDelay(ms,function()
  if T.done then return end
  local ok,e=pcall(fn);if not ok then T.log('FAIL '..tostring(e))end
 end)
end
function T.quit()
 local pc=FindFirstOf('PlayerController')
 if T.valid(pc)then StaticFindObject('/Script/Engine.Default__KismetSystemLibrary'):ExecuteConsoleCommand(pc,'quit',pc)end
 T.done=true
end
T.step(20000,function()
 local sys=StaticFindObject('/Script/Engine.Default__KismetSystemLibrary')
 local saved=sys:GetProjectSavedDirectory():ToString():gsub('\\','/')
 assert(saved:find('/research-1.0.1/profile/',1,true),'Wrong profile')
 T.log('ISOLATED_PROFILE_CONFIRMED')
 local gi=FindFirstOf('VoyageGameInstance');local p=gi:GetPrimaryPlayer()
 local save=StaticFindObject('/Script/Voyage.Default__VoyageSaveGame'):LoadSaveGame(C.slot,p:GetSaveGamePlatformUserIdK2())
 assert(T.valid(save),'Test save missing')
 assert(gi:TravelToWorldWithSaveGame(gi.WorldMap:ToString(),save,C.slot,p:GetSaveGamePlatformUserId()))
 for ms=1000,60000,1000 do T.step(ms,function()
  local pc=FindFirstOf('VoyagePlayerController')
  if T.ready or not T.valid(pc)or not T.valid(pc.Pawn)or not pc.Pawn:GetFullName():find('BP_FirstPersonCharacter_New_C',1,true)then return end
  T.ready=true;T.pc=pc;T.log('READY')
 end)end
end)
LoopInGameThreadWithDelay(1000,function()
 if T.done then return true end
 if not T.ready then return end
 local p=C.output..'/command.lua';local f=io.open(p,'r');if not f then return end
 local s=f:read('*a');f:close();os.remove(p)
 local fn,e=load(s);if not fn then T.log('COMPILE_FAIL '..tostring(e));return end
 local ok,err=pcall(fn);T.log(ok and 'COMMAND_OK'or('COMMAND_FAIL '..tostring(err)))
end)
T.step(1200000,function()T.log('TIMEOUT');T.quit()end)
