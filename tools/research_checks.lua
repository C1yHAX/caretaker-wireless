-- Development-only native research regression, on the probe's isolated player.
local T=assert(WIRELESS_RESEARCH_PROBE);assert(T.ready)
local gp=StaticFindObject('/Script/Voyage.Default__VoyageGameplayBlueprintFunctionLibrary');local pc=T.pc
T.gp=gp;T.originalState=T.originalState or pc.PlayerState
T.skills={}
for _,name in ipairs({'Electricity','Petrol','Diesel','FreshWater','SaltWater','Oil','Oxygen','CarbonDioxide','Methane','Steam','Universal'})do
 for _,suffix in ipairs(name=='Universal' and {''} or {'','_Receiver'})do
  local id='DA_Skill_Wireless_'..name..suffix
  local skill=T.load('/Game/CaretakerWireless/Skills/'..id..'.'..id)
  local cost=name=='Universal' and 3 or 1
  assert(T.valid(skill) and skill.Unlock.Cost==cost,id..' wrong native cost')
  T.skills[#T.skills+1]={asset=skill,id=id,cost=cost}
 end
end
T.testState=pc:GetWorld():SpawnActor(StaticFindObject('/Script/Voyage.VoyagePlayerState'),{X=0,Y=0,Z=10000},{Pitch=0,Yaw=0,Roll=0})
assert(T.valid(T.testState))
T.testState.PlayerGameProgress.PlayerData.Level=36
pc.PlayerState=T.testState
assert(gp:GetUsedSkillPoints(pc)==0)
-- UnlockPlayerSkill is the engine's unconditional grant operation (also used
-- by the admin menu). Normal research first checks ValidatePlayerSkill.
local function validate(skill)
 local flags={};local result=gp:ValidatePlayerSkill(pc,skill,flags)
 return result,flags.OutNotEligibleFlags
end
local function purchase(skill)
 if validate(skill)~=0 then return false end
 return gp:UnlockPlayerSkill(skill,pc)
end
local paid=T.skills[1].asset;local rx=T.skills[2].asset;local universal=T.skills[#T.skills].asset
assert(purchase(paid));assert(gp:GetUsedSkillPoints(pc)==1)
assert(not gp:HasPlayerSkill(rx,pc),'Receiver auto-granted')
local availability=require('availability')
availability.repair(pc)
assert(not gp:HasPlayerSkill(rx,pc),'Recovery bypassed research')
T.log('NO_RECEIVER_AUTOGRANT_PASS')
pc.PlayerState.PlayerGameProgress.PlayerData.Level=17
local result,flags=validate(rx);assert(result==2 and (flags&1)~=0,'Missing level gate')
assert(not purchase(rx),'Level gate bypassed')
pc.PlayerState.PlayerGameProgress.PlayerData.Level=21
assert(not purchase(universal),'Universal level gate bypassed')
pc.PlayerState.PlayerGameProgress.PlayerData.Level=36
T.log('LEVEL_GATES_PASS')
-- Exhaust only the temporary character's budget with the already purchased
-- test skill. Restore its cost on success AND failure; never write the asset.
local ok,err=pcall(function()
 paid.Unlock.Cost=gp:GetMaxSkillPoints(36)
 assert(gp:GetAvailableSkillPoints(pc)==0)
 local result,flags=validate(rx);assert(result==2 and (flags&2)~=0,'Missing points gate')
 assert(not purchase(rx),'Zero-budget unlock succeeded')
 assert(not gp:HasPlayerSkill(rx,pc))
 T.log('ZERO_POINTS_BLOCKED_PASS')
 paid.Unlock.Cost=gp:GetMaxSkillPoints(36)-2
 assert(gp:GetAvailableSkillPoints(pc)==2)
 local result,flags=validate(universal);assert(result==2 and (flags&2)~=0)
 assert(not purchase(universal),'Universal unlocked with two points')
 paid.Unlock.Cost=gp:GetMaxSkillPoints(36)-3
 assert(gp:GetAvailableSkillPoints(pc)==3)
 assert(purchase(universal),'Universal rejected with three points')
 assert(gp:GetAvailableSkillPoints(pc)==0)
 T.log('UNIVERSAL_EXACT_THREE_POINT_PURCHASE_PASS')
end)
paid.Unlock.Cost=1
assert(ok,err)
for _,s in ipairs(T.skills)do
 if not gp:HasPlayerSkill(s.asset,pc)then
  local before=gp:GetAvailableSkillPoints(pc)
  assert(purchase(s.asset),s.id..' unlock rejected')
  assert(gp:GetAvailableSkillPoints(pc)==before-s.cost,s.id..' wrong deduction')
 end
 assert(gp:HasPlayerSkill(s.asset,pc),s.id..' not owned')
 local before=gp:GetAvailableSkillPoints(pc)
 assert(not purchase(s.asset),s.id..' duplicate purchase')
 assert(gp:GetAvailableSkillPoints(pc)==before)
end
assert(gp:GetUsedSkillPoints(pc)==23)
T.log('ALL_21_PURCHASES_AND_DUPLICATE_GUARDS_PASS totalCost=23')
