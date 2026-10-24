-- Caretaker Wireless Background 1.0.0, Voyage 0.10.0.653173.
-- Keep the game's native resource simulation for selected runtime-actor cells.
-- World Partition, terrain, scenery and unrelated cells still unload normally.
local folder=debug.getinfo(1,'S').source:sub(2):match('^(.*[/\\])')
local config=dofile(folder..'config.lua')
local classes=dofile(folder..'devices.lua')
local physics=dofile(folder..'physics.lua')
local saved=dofile(folder..'saved_network.lua')
local connections=dofile(folder..'connections.lua')
local M={stats={refreshes=0,refreshMs=0,maxRefreshMs=0,intercepts=0,restores=0}}
local function log(s)print('[CaretakerWirelessBackground] '..s..'\n')end
local function valid(o)return o and o:IsValid()end
local function same(a,b)return valid(a)and valid(b)and a:GetAddress()==b:GetAddress()end
local function key(x,y)return x..':'..y end
local function coords(k)local x,y=k:match('^(%-?%d+):(%-?%d+)$');return tonumber(x),tonumber(y)end
local state={pins={},background={},actors={},frozen={}}
local stack={}
local bypass=false
local lastRefresh=0
local lastActorScan=0
local lastActorCount=0
local enabled=true
local function scanActors()
 local found={};local n=0
 for _,c in ipairs(FindAllOf('VoyagePersistentActorComponent')or{})do
  if valid(c)then
   local a=c:GetOwner()
   if valid(a)and same(a:GetWorld(),state.world)then
    local k=c.CurrentRuntimeZoneId:ToString()
    if state.pins[k]then found[k]=found[k]or{};found[k][a:GetAddress()]=a;n=n+1 end
   end
  end
 end
 state.actors=found;lastActorScan=os.clock();lastActorCount=n
 return n
end
local function restoreActor(id)
 local r=state.frozen[id]
 if r then physics.restore(r.records);state.frozen[id]=nil end
end
local function freezeCell(k)
 if os.clock()-lastActorScan>1 then
  scanActors()
 end
 if lastActorCount>config.MaxProtectedActors then log('Cell actor budget exceeded; retaining normal streaming');return false end
 for id,a in pairs(state.actors[k]or{})do
  if valid(a)and not state.frozen[id]then
   local records=physics.freeze(a)
   if #records>0 then state.frozen[id]={actor=a,zone=k,records=records}end
  end
 end
 return true
end
local function restoreCell(k)
 for id,r in pairs(state.frozen)do if r.zone==k then restoreActor(id)end end
end
local function bindWorld()
 local pc=FindFirstOf('PlayerController')
 if not valid(pc)then return false end
 local world=pc:GetWorld()
 if not valid(world)then return false end
 if not same(world,state.world)then
  for id in pairs(state.frozen)do restoreActor(id)end
  local lib=StaticFindObject('/Script/Engine.Default__SubsystemBlueprintLibrary')
  local function sub(c)return lib:GetWorldSubsystem(pc,StaticFindObject('/Script/Voyage.'..c))end
  state={world=world,pins={},background={},actors={},frozen={},persistent=sub('VoyagePersistentSubsystem'),
   locator=sub('VoyageLocatorSubsystem'),modules=sub('VoyageModuleSubsystem'),since=os.time(),bootstrapDone=false}
  lastRefresh=0;lastActorScan=0;lastActorCount=0
  log('World changed; cleared previous network references')
 end
 return valid(state.persistent)and valid(state.locator)and valid(state.modules)
end
local function releaseCell(k)
 restoreCell(k)
 state.background[k]=nil
 local x,y=coords(k)
 if x then
  bypass=true
  local ok,e=pcall(function()state.persistent:OnStreamCellDeactivate(state.locator:GetMainStreamingGridName(),x,y)end)
  bypass=false
  if not ok then error(e)end
 end
end
function M.refresh()
 if not enabled then return end
 local started=os.clock()
 if not bindWorld()then return end
 local wanted,seen,mods,actors={},{},{},{}
 local function addActor(a)
  if not valid(a)or not same(a:GetWorld(),state.world)then return end
  local addr=a:GetAddress();if seen[addr]then return end;seen[addr]=true
  local p=state.persistent:GetPersistentActorComponent(a)
  if valid(p)then
   local k=p.CurrentRuntimeZoneId:ToString()
   if coords(k)then wanted[k]=true;actors[k]=actors[k]or{};actors[k][addr]=a end
  end
  local parent=a:GetAttachParentActor()
  if valid(parent)then addActor(parent)end
 end
 local function addModule(c)
  if not valid(c)or mods[c:GetAddress()]then return end
  mods[c:GetAddress()]=c;addActor(c:GetOwner())
 end
 -- Discover all twenty supported device classes in one native component scan,
 -- rather than repeating a global class search for every resource and role.
 local discovered={}
 for _,persistent in ipairs(FindAllOf('VoyagePersistentActorComponent')or{})do
  if valid(persistent)then
   local a=persistent:GetOwner()
   if valid(a)and not discovered[a:GetAddress()]and same(a:GetWorld(),state.world)and classes[a:GetClass():GetFName():ToString()]then
    discovered[a:GetAddress()]=true
    addActor(a)
    local c=a.ModuleComponent
    if valid(c)and c.bHasInitialized then
     addModule(c)
     local out={};state.modules:GetConnectedModules(c,out,true,true,true,false)
     for _,v in ipairs(out)do addModule(v:get())end
    end
   end
  end
 end
 local misc=StaticFindObject('/Script/Voyage.Default__VoyageMiscBlueprintFunctionLibrary')
 for _,c in pairs(mods)do
  c.Sockets:ForEach(function(_,v)
   local s=v:get()
   if valid(s)then addActor(s:GetOwner());addActor(misc:GetCableFromSocket(s))end
  end)
 end
 if state.bootstrapPins then for k in pairs(state.bootstrapPins)do wanted[k]=true end end
 -- Only the discovered devices and their connected networks are protected.
 -- Full per-cell actor collection remains limited to streaming transitions.
 local n=0;local cells=0
 for _ in pairs(wanted)do cells=cells+1 end
 for _,list in pairs(actors)do for _ in pairs(list)do n=n+1 end end
 if cells>config.MaxProtectedCells or n>config.MaxProtectedActors then
  if not state.limitWarned then log('Background budget exceeded ('..cells..' cells, '..n..' actors); using normal streaming until the network is smaller');state.limitWarned=true end
  wanted={};actors={}
 else state.limitWarned=false end
 for k,b in pairs(state.background)do
  if not wanted[k]then
   b.missing=(b.missing or 0)+1
   if b.missing>=2 then releaseCell(k)else wanted[k]=true;actors[k]=state.actors[k]end
  else b.missing=0 end
 end
 state.pins=wanted;state.actors=actors
 for id,r in pairs(state.frozen)do if not valid(r.actor)then state.frozen[id]=nil end end
 lastRefresh=os.clock()
 local ms=(os.clock()-started)*1000
 M.stats.refreshes=M.stats.refreshes+1;M.stats.refreshMs=M.stats.refreshMs+ms
 M.stats.maxRefreshMs=math.max(M.stats.maxRefreshMs,ms);M.stats.cells=cells;M.stats.actors=n
 if config.LogStatistics and M.stats.refreshes%12==0 then log(string.format('%d cells / %d actors; refresh %.3f ms (max %.3f ms)',cells,n,ms,M.stats.maxRefreshMs))end
end
RegisterHook('/Script/Voyage.VoyagePersistentSubsystem:OnStreamCellDeactivate',function(ctx,g,x,y)
 local e={};stack[#stack+1]=e
 local ok,err=pcall(function()
 if bypass or not enabled or not same(ctx:get(),state.persistent)then return end
 if os.clock()-lastRefresh>2 then M.refresh()end
 if g:get():ToString()~=state.locator:GetMainStreamingGridName():ToString()then return end
 local k=key(x:get(),y:get())
 if not state.pins[k]then return end
 if not freezeCell(k)then return end
 state.background[k]={}
 e.g=g:get();e.x=x:get();e.y=y:get()
 -- Modify this bound callback only. Its multicast caller and the World Partition
 -- listeners see the original parameters again in the post-hook.
 g:set(FName('CaretakerBackgroundSuppressed'));x:set(2147480000);y:set(2147480000)
 M.stats.intercepts=M.stats.intercepts+1
 end)
 if not ok then log('Streaming guard failed; native streaming retained: '..tostring(err))end
end,function(ctx,g,x,y)
 local e=table.remove(stack)
 if e and e.g then g:set(e.g);x:set(e.x);y:set(e.y)end
end)
RegisterHook('/Script/Voyage.VoyagePersistentSubsystem:OnStreamCellActivate',function(ctx,g,x,y)
 if bypass or not same(ctx:get(),state.persistent)then return end
 if g:get():ToString()~=state.locator:GetMainStreamingGridName():ToString()then return end
 local k=key(x:get(),y:get())
 if state.background[k]then
  restoreCell(k);state.background[k]=nil;M.stats.restores=M.stats.restores+1
 end
end,function()end)
function M.snapshot()return state end
function M.bootstrap()
 if not enabled or not bindWorld()then return end
 state.bootstrapStarted=true
 local started=os.clock()
 local cells,info=saved.index(state.persistent,state.locator:GetStreamingCellSize(state.locator:GetMainStreamingGridName()))
 if info.cells>config.MaxProtectedCells or info.actors>config.MaxProtectedActors then
  log('Saved network exceeds background budget; normal streaming retained');return false
 end
 M.stats.bootstrapMs=(os.clock()-started)*1000;M.stats.bootstrap=info
 state.bootstrapPins=cells
 local original=state
 local queue={};for k in pairs(cells)do queue[#queue+1]=k end;table.sort(queue)
 local function nextCell(i)
  if not enabled or state~=original then return end
  if i>#queue then
   M.refresh();scanActors()
   for k in pairs(state.background)do freezeCell(k)end
   local function reconnect(attempt)
    if not enabled or state~=original then return end
    -- Pending registration finishes after activation; the routine network cache
    -- is incomplete until these saved wires are attached. Refresh the complete
    -- protected-cell actor list only during this bounded startup sequence.
    scanActors()
    local ok,n=pcall(connections.restore,state.actors)
    if ok then M.stats.connectionsRestored=(M.stats.connectionsRestored or 0)+n
    else log('Saved cable restoration: '..tostring(n))end
    if attempt<6 then ExecuteInGameThreadWithDelay(1000,function()reconnect(attempt+1)end)end
   end
   ExecuteInGameThreadWithDelay(500,function()reconnect(1)end)
   ExecuteInGameThreadWithDelay(3000,function()
    if not enabled or state~=original then return end
    M.refresh();scanActors()
    for k in pairs(state.background)do freezeCell(k)end
    state.bootstrapDone=true;M.refresh()
    ExecuteInGameThreadWithDelay(12000,function()
     if enabled and state==original then state.bootstrapPins=nil;M.refresh()end
    end)
    log('Restored '..info.cells..' native runtime cells from current save; world scenery remains streamed')
   end)
   return
  end
  local k=queue[i];local x,y=coords(k)
  local grid=state.locator:GetMainStreamingGridName()
  local location=state.locator:GetStreamingCellLocation(grid,x,y)
  if not state.locator:IsLocationActivated(location)then
   state.pins[k]=true;state.background[k]={}
   bypass=true
   local ok,e=pcall(function()state.persistent:OnStreamCellActivate(grid,x,y)end)
   bypass=false
   if not ok then error(e)end
   -- Suspension is repeated after native deferred initialization finishes.
   lastActorScan=0
  end
  -- All connected cells must exist before native deferred cable restoration.
  -- Splitting them over frames can leave an endpoint absent during PostLoad.
  nextCell(i+1)
 end
 nextCell(1)
 return true
end
function M.setEnabled(value)
 enabled=value
 if not enabled then
  local keys={};for k in pairs(state.background)do keys[#keys+1]=k end
  state.pins={};state.bootstrapPins=nil
  for _,k in ipairs(keys)do releaseCell(k)end
 else M.refresh();M.bootstrap()end
end
local function tick()
 local ok,e=pcall(function()
  M.refresh()
  if enabled and valid(state.persistent) and not state.bootstrapStarted and os.time()-state.since>=25 then M.bootstrap()end
 end)
 if not ok then log('Refresh error: '..tostring(e))end
 ExecuteInGameThreadWithDelay(config.RefreshMilliseconds,tick)
end
ExecuteInGameThreadWithDelay(config.RefreshMilliseconds,tick)
log('1.0.0 loaded; native wireless simulation, 5-second network refresh')
return M
