"""Offline tests of actual Lua discovery, saved-network seeds and channel control.

Uses Lua 5.4 via lupa, never opens the game. Native flow is verified separately.
"""
from pathlib import Path
import json, unittest
from lupa.lua54 import LuaRuntime

ROOT=Path(__file__).resolve().parent.parent
MODS=ROOT/'Voyage/Binaries/Win64/ue4ss/Mods'
SPEC=json.loads((ROOT/'resources.json').read_text(encoding='utf-8'))
RESOURCES=SPEC['resources']
NAMES=['BP_Module_WirelessResourceTransmitter_C','BP_WirelessResource_Socket_Base_C']
for row in RESOURCES:NAMES += [row['senderClass'],row['receiverClass']]
NAMES.append(SPEC['universal']['senderClass'])
NAMES.append(SPEC['universal']['receiver']['receiverClass'])
assert len(NAMES)==22 and len(set(NAMES))==22

def setup():
 lua=LuaRuntime(unpack_returned_tuples=True)
 lua.globals().background=(MODS/'CaretakerWirelessBackground/Scripts').as_posix()+'/'
 lua.globals().controls=(MODS/'CaretakerWirelessControls/Scripts').as_posix()+'/'
 lua.globals().names=lua.table_from(NAMES)
 lua.execute('''
 package.loadlib=function(path,symbol)
  assert(path:find('native/caretaker_catchup.dll',1,true))
  assert(symbol=='caretaker_catchup_enable' or symbol=='caretaker_catchup_disable')
  return function(value)assert(value==true);return true end
 end
 function validObject(t) t=t or {}; function t:IsValid() return true end;return t end
 function fname(s) return {ToString=function() return s end} end
 function wrap(v) return {get=function() return v end} end
 function list(t) return {ForEach=function(self,f)for k,v in pairs(t)do f(wrap(k),wrap(v))end end}end
 function klass(name) return validObject({GetFName=function()return fname(name)end})end
 function print()end
 function RegisterInitGameStatePreHook(fn) end
 ''')
 return lua

class Resources(unittest.TestCase):
 def test_unsupported_native_guard_keeps_normal_streaming(self):
  lua=setup();lua.execute('''
  package.loadlib=function()return function()return nil end end
  function RegisterHook()end
  function ExecuteInGameThreadWithDelay()end
  function FindFirstOf()error('Disabled background must not scan the world')end
  local M=dofile(background..'main.lua')
  assert(M.catchupReady==false)
  M.refresh();M.setEnabled(true);M.refresh()
  assert(next(M.snapshot().pins)==nil and M.stats.refreshes==0)
  ''')
 def test_exact_registry_shared_by_both_mods(self):
  lua=setup();lua.execute('''
  a=dofile(background..'devices.lua');b=dofile(controls..'devices.lua')
  local count=0;for n in pairs(a)do count=count+1;assert(b[n])end
  assert(count==#names)
  for _,n in ipairs(names)do assert(a[n] and b[n])end
  assert(not a.BP_Module_SmallGenerator_C and not a.BP_Wireless_Unknown_Receiver_C)
  ''')

 def test_saved_network_seeds_every_resource_and_ignores_other_devices(self):
  lua=setup();lua.execute('''
  saved=dofile(background..'saved_network.lua');records={}
  for i,n in ipairs(names)do records[fname(i..':0')]={actors=list({{ActorClass=klass(n)}})}end
  records[fname('99:0')]={actors=list({{ActorClass=klass('UnrelatedDevice')}})}
  cells,info=saved.index({PersistentActors=list(records)},10000)
  assert(info.cells==#names and info.actors==#names and not cells['99:0'])
  for i=1,#names do assert(cells[i..':0'])end
  ''')

 def test_channel_control_handles_all_devices_and_preserves_game_keys(self):
  lua=setup();lua.execute('''
  bindings={};timers={};Key={OEM_THREE=192}
  function RegisterKeyBind(k,mods,f)bindings[#bindings+1]={key=k,fn=f};assert(#mods==0)end
  function IsKeyBindRegistered()return false end
  function LoopInGameThreadWithDelay(ms,f)timers[ms]=f end
  actor=validObject({GetClass=function()return klass(current)end,GetAttachParentActor=function()return nil end,WirelessChannelControl=validObject()})
  component=validObject({GetOwner=function()return actor end,K2_GetComponentLocation=function()return {X=0,Y=0,Z=0}end})
  pointer=validObject({MaxReach=1000,GetHoverReference=function()return component end})
  pawn=validObject({InteractiveDetectorPointerComponent=pointer})
  pc=validObject({Pawn=pawn,bShowMouseCursor=false,HasActiveDialog=function()return false end,
   PlayerCameraManager={GetCameraLocation=function()return {X=0,Y=0,Z=0}end}})
  state=validObject({IsPlaying=function()return true end})
  shown=0;dialog=validObject({SetInteractiveSource=function(self,control,source)assert(source==actor and control==actor.WirelessChannelControl);shown=shown+1 end})
  gi=validObject({ShowCommonDialog=function()return dialog end})
  function FindFirstOf(c)return ({PlayerController=pc,VoyageGameStateSubsystem=state,VoyageGameInstance=gi})[c]end
  function LoadAsset()return validObject(),true,true end
  M=dofile(controls..'main.lua')
  assert(#bindings==1 and bindings[1].key==192)
  for _,n in ipairs(names)do current=n;bindings[1].fn();timers[50]()end
  assert(shown==#names)
  current='UnrelatedDevice';assert(not M.open());assert(shown==#names)
  current=names[1];pc.bShowMouseCursor=true;assert(not M.open())
  ''')

 def test_background_discovers_twenty_two_types_in_one_scan_and_deduplicates(self):
  lua=setup();lua.execute('''
  actors={};persistentComponents={};scanCount=0
  world=validObject({GetAddress=function()return 1 end})
  persistent=validObject({GetPersistentActorComponent=function(self,a)return a.persistent end})
  locator=validObject();modules=validObject({GetConnectedModules=function()end})
  pc=validObject({GetWorld=function()return world end})
  for i,n in ipairs(names)do
   local id=i;local name=n
   local a=validObject({GetAddress=function()return id+10 end,GetWorld=function()return world end,
    GetClass=function()return klass(name)end,GetAttachParentActor=function()return nil end})
   a.persistent=validObject({CurrentRuntimeZoneId=fname(id..':0'),GetOwner=function()return a end})
   a.ModuleComponent=validObject({bHasInitialized=true,GetAddress=function()return id+100 end,
    GetOwner=function()return a end,Sockets=list({})})
   actors[#actors+1]=a;persistentComponents[#persistentComponents+1]=a.persistent
   persistentComponents[#persistentComponents+1]=a.persistent
  end
  function FindFirstOf(c)if c=='PlayerController'then return pc end end
  function FindAllOf(c)assert(c=='VoyagePersistentActorComponent');scanCount=scanCount+1;return persistentComponents end
  local subsystems={['/Script/Voyage.VoyagePersistentSubsystem']=persistent,
   ['/Script/Voyage.VoyageLocatorSubsystem']=locator,['/Script/Voyage.VoyageModuleSubsystem']=modules}
  function StaticFindObject(p)
   if p=='/Script/Engine.Default__SubsystemBlueprintLibrary'then
    return {GetWorldSubsystem=function(self,pc,c)return subsystems[c.path]end}
   end
   return {path=p}
  end
  function RegisterHook()end
  function ExecuteInGameThreadWithDelay()end
  M=dofile(background..'main.lua');M.refresh()
  assert(scanCount==1 and M.stats.cells==#names and M.stats.actors==#names)
  for i=1,#names do assert(M.snapshot().pins[i..':0'])end
  ''')

if __name__=='__main__':unittest.main()
