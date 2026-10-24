"""Exercise the actual background Lua with ten-resource engine API fixtures.

No game launch. These tests cover our streaming/restore logic, not native flow.
GetConnectedModules' argument names were checked against the game header dump:
InModule, OutModules, Recursive, IncludeGroups, IncludeCableConnections,
OnlyEnabledGroups. The call enables the first three flags and disables the last.
"""
from pathlib import Path
import unittest
from test_resources import setup, SPEC


class UniversalBackground(unittest.TestCase):
    def lua(self):
        lua = setup()
        lua.globals().resources = lua.table_from(
            ['Electricity'] + [row['resource'] for row in SPEC['resources']])
        lua.execute('''
        assert(#resources==10)
        nextAddress=10
        function object(t)
          nextAddress=nextAddress+1;local id=nextAddress
          t=validObject(t);function t:GetAddress()return id end;return t
        end
        function ref(value)
          return {get=function()return value end,set=function(self,v)value=v end}
        end
        ''')
        return lua

    def test_all_resource_network_cells_survive_streaming_and_restore_arguments(self):
        lua=self.lua();lua.execute('''
        world=object();allPersistent={};expected={};hooks={};scans=0;queries=0
        function actor(name,zone,parent)
          local a=object({GetWorld=function()return world end,
            GetClass=function()return klass(name)end,
            GetAttachParentActor=function()return parent end,
            K2_GetComponentsByClass=function()return {}end})
          a.persistent=object({CurrentRuntimeZoneId=fname(zone),GetOwner=function()return a end})
          allPersistent[#allPersistent+1]=a.persistent;expected[zone]=true
          return a
        end
        function module(a)
          local m=object({bHasInitialized=true,GetOwner=function()return a end})
          m.socketRows={};m.Sockets=list(m.socketRows);a.ModuleComponent=m;return m
        end
        function socket(m,owner,resource,cable)
          local s=object({ResourceType=resource,GetOwner=function()return owner end,cable=cable})
          m.socketRows[#m.socketRows+1]=s;return s
        end
        local mount=actor('Mount','-1:0')
        tx=module(actor('BP_Wireless_Universal_Transmitter_C','0:0',mount))
        rx=module(actor('BP_Wireless_Universal_Receiver_C','1:0'))
        connected={[tx]={},[rx]={}}
        for i,r in ipairs(resources)do
          local source=module(actor('Source_'..r,(10+i)..':0'))
          local load=module(actor('Consumer_'..r,(30+i)..':0'))
          local a=actor('BP_ModuleCable_'..r..'_C',(50+i)..':0')
          local b=actor('BP_ModuleCable_'..r..'_C',(70+i)..':0')
          connected[tx][#connected[tx]+1]=wrap(source)
          connected[rx][#connected[rx]+1]=wrap(load)
          socket(tx,tx:GetOwner(),r,a);socket(source,source:GetOwner(),r,a)
          -- Wireless outputs can belong to TX's native module while physically on RX.
          socket(tx,rx:GetOwner(),r,b);socket(load,load:GetOwner(),r,b)
        end
        persistent=object({GetPersistentActorComponent=function(self,a)return a.persistent end})
        locator=object({GetMainStreamingGridName=function()return fname('Runtime')end})
        modules=object({GetConnectedModules=function(self,c,out,recursive,groups,cables,enabledOnly)
          assert(recursive and groups and cables and not enabledOnly);queries=queries+1
          for _,v in ipairs(connected[c])do out[#out+1]=v end
        end})
        pc=object({GetWorld=function()return world end})
        function FindFirstOf(c)assert(c=='PlayerController');return pc end
        function FindAllOf(c)assert(c=='VoyagePersistentActorComponent');scans=scans+1;return allPersistent end
        local subsystems={['/Script/Voyage.VoyagePersistentSubsystem']=persistent,
          ['/Script/Voyage.VoyageLocatorSubsystem']=locator,['/Script/Voyage.VoyageModuleSubsystem']=modules}
        function StaticFindObject(p)
          if p=='/Script/Engine.Default__SubsystemBlueprintLibrary'then
            return {GetWorldSubsystem=function(self,pc,c)return subsystems[c.path]end}
          elseif p=='/Script/Voyage.Default__VoyageMiscBlueprintFunctionLibrary'then
            return {GetCableFromSocket=function(self,s)return s.cable end}
          end
          return {path=p}
        end
        function RegisterHook(path,pre,post)hooks[path]={pre,post}end
        function ExecuteInGameThreadWithDelay()end
        function FName(s)return fname(s)end
        local m=dofile(background..'main.lua');m.refresh()
        assert(scans==1 and queries==2 and m.stats.cells==43 and m.stats.actors==43)
        for k in pairs(expected)do assert(m.snapshot().pins[k],k)end
        assert(not m.snapshot().pins['999:0'])
        local deactivate=hooks['/Script/Voyage.VoyagePersistentSubsystem:OnStreamCellDeactivate']
        local activate=hooks['/Script/Voyage.VoyagePersistentSubsystem:OnStreamCellActivate']
        for k in pairs(expected)do
          local x=tonumber(k:match('^(%-?%d+):'))
          local g,px,py=ref(fname('Runtime')),ref(x),ref(0)
          deactivate[1](ref(persistent),g,px,py)
          assert(g:get():ToString()=='CaretakerBackgroundSuppressed')
          assert(m.snapshot().background[k])
          deactivate[2](ref(persistent),g,px,py)
          assert(g:get():ToString()=='Runtime' and px:get()==x and py:get()==0)
          activate[1](ref(persistent),g,px,py)
          assert(not m.snapshot().background[k])
        end
        local g,x,y=ref(fname('Runtime')),ref(999),ref(0)
        deactivate[1](ref(persistent),g,x,y);deactivate[2](ref(persistent),g,x,y)
        assert(g:get():ToString()=='Runtime' and x:get()==999 and not m.snapshot().background['999:0'])
        assert(m.stats.intercepts==43 and m.stats.restores==43)
        ''')

    def test_saved_cable_graph_covers_all_resources_and_excludes_disconnected_edges(self):
        lua=self.lua();lua.execute('''
        local function str(s)return string.pack('<i4',#s+1)..s..'\\0'end
        local function prop(name,kind,data,flags)
          return str(name)..str(kind)..string.pack('<i4i4B',0,#data,flags or 0)..data
        end
        local function bytes(s)local out={};for i=1,#s do out[i]=s:byte(i)end;return list(out)end
        local function point(x)return string.pack('<dd',x*10000+1,1)..string.rep('\\0',20)end
        local function cable(class,a,b,complete)
          local s='\\0'..prop('bIsConnected','BoolProperty','',complete and 16 or 0)
          for side,x in pairs({A=a,B=b})do
            s=s..prop('ModuleID'..side,'Int64Property',string.pack('<i8',x+100))
              ..prop('bDisconnected'..side,'BoolProperty','',complete and 0 or 16)
              ..prop('Sphere'..side..'Transform','StructProperty',point(x))
          end
          return {ActorClass=klass(class),ByteData=bytes(s..str('None'))}
        end
        local records={}
        records[fname('0:0')]={actors=list({{ActorClass=klass('BP_Wireless_Universal_Transmitter_C')}})}
        records[fname('1:0')]={actors=list({{ActorClass=klass('BP_Wireless_Universal_Receiver_C')}})}
        local cableNames={'Electric','Fuel','Fuel','Liquid','Liquid','Liquid','Gas','Gas','Gas','Gas'}
        for i,r in ipairs(resources)do
          records[fname((10+i)..':0')]={actors=list({cable('BP_ModuleCable_'..cableNames[i]..'_C',0,30+i,true)})}
          records[fname((30+i)..':0')]={actors=list({{ActorClass=klass('Source_'..r)}})}
          records[fname((50+i)..':0')]={actors=list({cable('BP_ModuleCable_'..cableNames[i]..'_C',1,70+i,true)})}
          records[fname((70+i)..':0')]={actors=list({{ActorClass=klass('Consumer_'..r)}})}
        end
        records[fname('900:0')]={actors=list({cable('BP_ModuleCable_Gas_C',0,901,false)})}
        records[fname('901:0')]={actors=list({{ActorClass=klass('DisconnectedTank')}})}
        local saved=dofile(background..'saved_network.lua')
        local cells,info=saved.index({PersistentActors=list(records)},10000)
        assert(info.cells==42 and info.actors==42 and info.cables==21)
        for _,offset in ipairs({10,30,50,70})do for i=1,10 do assert(cells[(offset+i)..':0'])end end
        assert(cells['0:0']and cells['1:0']and not cells['900:0']and not cells['901:0'])
        ''')

    def test_exact_saved_endpoints_for_every_resource_and_repeat_restore(self):
        lua=self.lua();lua.execute('''
        local actors={};local calls=0
        function makeActor(name)
          local a=object({GetClass=function()return klass(name)end})
          a.mods={};a.sockets={}
          function a:K2_GetComponentsByClass(c)
            local out={};for _,v in ipairs(c=='module' and self.mods or self.sockets)do out[#out+1]=wrap(v)end;return out
          end
          actors[a:GetAddress()]=a;return a
        end
        function endpoint(a,number,type,currentModule)
          local m=object({ModuleAddressCached=number});a.mods[#a.mods+1]=m
          local s=object({SocketID=number+1000,ResourceType=type})
          function s:GetModule()return currentModule or m end
          function s:GetConnectedSocket()return self.peer end
          function s:SetSocketDirectionType(d)self.direction=d end
          a.sockets[#a.sockets+1]=s;return s,m
        end
        tx=makeActor('BP_Wireless_Universal_Transmitter_C');rx=makeActor('BP_Wireless_Universal_Receiver_C')
        local assigned=object({ModuleAddressCached=987654})
        for i,r in ipairs(resources)do
          local a,ma=endpoint(rx,i,r,assigned)
          local b,mb=endpoint(makeActor('Consumer_'..r),100+i,r)
          local c=makeActor('BP_ModuleCable_'..r..'_C')
          -- Alternate saved physical RX and assigned TX identity.
          c.ModuleIDA=i%2==0 and assigned.ModuleAddressCached or ma.ModuleAddressCached
          c.ModuleIDB=mb.ModuleAddressCached;c.SocketIDA=a.SocketID;c.SocketIDB=b.SocketID
          c.bIsConnected=true;c.bDisconnectedA=true;c.bDisconnectedB=true;c.DirectionA=1;c.DirectionB=2
        end
        function StaticFindObject(p)
          if p=='/Script/Voyage.VoyageModuleComponent'then return 'module' end
          if p=='/Script/Voyage.ModuleSocketComponent'then return 'socket' end
          return {GetCableFromSocket=function(self,s)return s.cable end,
            ConnectCable=function(self,c,a,b)
              assert(a.ResourceType==b.ResourceType and a.direction==1 and b.direction==2)
              a.peer=b;b.peer=a;a.cable=c;b.cable=c;calls=calls+1
            end}
        end
        local restore=dofile(background..'connections.lua').restore
        local count,info=restore({['0:0']=actors})
        assert(count==10 and calls==10 and info.matched==10)
        local again,info2=restore({['0:0']=actors})
        assert(again==0 and calls==10 and info2.paired==10)
        ''')


if __name__=='__main__':
    unittest.main()
