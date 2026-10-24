-- Read-only index of native saved cable endpoints. Never edits a save or creates
-- sidecar state: each world/save builds its own graph from its own actor records.
local M={}
local function blob(array)
 local parts={};array:ForEach(function(_,b)parts[#parts+1]=string.char(b:get())end)
 return table.concat(parts)
end
function M.properties(b)
 local p=2;assert(b:byte(1)==0,'Unsupported native property stream')
 local function take(n)assert(n>=0 and p+n-1<=#b,'Truncated property');local s=b:sub(p,p+n-1);p=p+n;return s end
 local function integer()return string.unpack('<i4',take(4))end
 local function str()
  local n=integer();assert(n>0 and n<65536,'Unsupported property name')
  local s=take(n);assert(s:byte(n)==0);return s:sub(1,-2)
 end
 local function typename(depth)
  assert(depth<8);local n=str();local count=integer();assert(count>=0 and count<=8)
  for _=1,count do typename(depth+1)end
  return n
 end
 local props={}
 while true do
  local name=str();if name=='None'then break end
  local kind=typename(0);local size=integer();local flags=take(1):byte()
  if flags&1~=0 then take(4)end
  if flags&2~=0 then take(16)end
  assert(flags&4==0 and flags&192==0,'Unsupported property flags')
  props[name]={kind=kind,value=take(size),flags=flags}
 end
 return props
end
function M.index(persistent,cellSize)
 local seeds,edges,counts={},{},{}
 local function connect(a,b)
  if a and b then edges[a]=edges[a]or{};edges[b]=edges[b]or{};edges[a][b]=true;edges[b][a]=true end
 end
 local function point(prop)
  if not prop or #prop.value~=36 then return end
  local x,y=string.unpack('<dd',prop.value)
  if x~=x or y~=y or math.abs(x)>1e9 or math.abs(y)>1e9 then return end
  return math.floor(x/cellSize)..':'..math.floor(y/cellSize)
 end
 local total,cables=0,0
 persistent.PersistentActors:ForEach(function(k,v)
  local zone=k:get():ToString()
  if not zone:match('^%-?%d+:%-?%d+$')then return end
  v:get().actors:ForEach(function(_,r)
   local d=r:get();total=total+1
   local c=d.ActorClass
   if c and c:IsValid()then
    -- Null-class records are removal markers, not actors that will be loaded.
    counts[zone]=(counts[zone]or 0)+1
    local name=c:GetFName():ToString()
    if name=='BP_Module_WirelessResourceTransmitter_C' or name=='BP_WirelessResource_Socket_Base_C'then seeds[zone]=true end
    if name:find('ModuleCable',1,true)then
     cables=cables+1
     local props=M.properties(blob(d.ByteData))
     -- Socket transforms are saved in world coordinates by native ResourceCable.
     for _,side in ipairs({'A','B'})do
      local disconnected=props['bDisconnected'..side]
      local id=props['ModuleID'..side]
      local complete=props.bIsConnected and props.bIsConnected.flags&16~=0
      if id and id.value~=string.rep('\0',8)and (complete or not disconnected or disconnected.flags&16==0)then
       connect(zone,point(props['Sphere'..side..'Transform']))
      end
     end
    end
   end
  end)
 end)
 local queue,selected={},{}
 for z in pairs(seeds)do queue[#queue+1]=z;selected[z]=true end
 local i=1
 while i<=#queue do
  for z in pairs(edges[queue[i]]or{})do if not selected[z]then selected[z]=true;queue[#queue+1]=z end end
  i=i+1
 end
 local actors=0;for z in pairs(selected)do actors=actors+(counts[z]or 0)end
 return selected,{records=total,cables=cables,cells=#queue,actors=actors}
end
return M
