-- Resolve only saved endpoint identities. No proximity search and no new wires.
local M={}
local function valid(o)return o and o:IsValid()end
local function same(a,b)return valid(a)and valid(b)and a:GetAddress()==b:GetAddress()end
function M.restore(actors)
 local sockets,cables={},{}
 local info={actors=0,sockets=0,cables=0,eligible=0,matched=0,occupied=0,paired=0}
 local moduleClass=StaticFindObject('/Script/Voyage.VoyageModuleComponent')
 local socketClass=StaticFindObject('/Script/Voyage.ModuleSocketComponent')
 local misc=StaticFindObject('/Script/Voyage.Default__VoyageMiscBlueprintFunctionLibrary')
 local function id(m,s)return tostring(m)..':'..tostring(s)end
 local function add(m,s)
  if not valid(m)or m.ModuleAddressCached==0 then return end
  local k=id(m.ModuleAddressCached,s.SocketID)
  if sockets[k]and not same(sockets[k],s)then sockets[k]=false
  elseif sockets[k]==nil then sockets[k]=s end
 end
 for _,list in pairs(actors)do for _,a in pairs(list)do
  if valid(a)then
   info.actors=info.actors+1
   if a:GetClass():GetFName():ToString():find('ModuleCable',1,true)then cables[#cables+1]=a end
   local modules=a:K2_GetComponentsByClass(moduleClass)
   for _,v in ipairs(a:K2_GetComponentsByClass(socketClass))do
    local s=v:get()
    info.sockets=info.sockets+1
    -- Wireless outputs change their runtime module owner. Both the saved
    -- physical receiver identity and its current transmitter are legitimate.
    for _,m in ipairs(modules)do add(m:get(),s)end
    add(s:GetModule(),s)
   end
  end
 end end
 local restored=0
 info.cables=#cables
 for _,c in ipairs(cables)do
  -- bDisconnectedA/B are also set transiently when a saved endpoint has not
  -- loaded yet. bIsConnected records a completed cable, so keep its exact IDs.
  if c.bIsConnected and c.ModuleIDA~=0 and c.ModuleIDB~=0 then
   info.eligible=info.eligible+1
   local a=sockets[id(c.ModuleIDA,c.SocketIDA)];local b=sockets[id(c.ModuleIDB,c.SocketIDB)]
   if valid(a)and valid(b)and not same(a,b)then
    info.matched=info.matched+1
    local ca=misc:GetCableFromSocket(a);local cb=misc:GetCableFromSocket(b)
    if (not valid(ca)or same(ca,c))and (not valid(cb)or same(cb,c))then
     if not same(a:GetConnectedSocket(),b)or not same(b:GetConnectedSocket(),a)then
      a:SetSocketDirectionType(c.DirectionA);b:SetSocketDirectionType(c.DirectionB)
      misc:ConnectCable(c,a,b);restored=restored+1
     else info.paired=info.paired+1 end
    else info.occupied=info.occupied+1 end
   end
  end
 end
 return restored,info
end
return M
