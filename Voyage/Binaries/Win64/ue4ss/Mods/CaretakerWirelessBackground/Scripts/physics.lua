-- Suspend rigid-body movement without changing bSimulatePhysics or saved module state.
-- DOF locks are transient engine settings, not Voyage's saved collision/physics flags.
local M={}
local locks={'bLockTranslation','bLockRotation','bLockXTranslation','bLockYTranslation','bLockZTranslation','bLockXRotation','bLockYRotation','bLockZRotation'}
function M.freeze(actor)
 local records={}
 local ok,err=pcall(function()
 for _,v in ipairs(actor:K2_GetComponentsByClass(StaticFindObject('/Script/Engine.PrimitiveComponent')))do
  local c=v:get()
  do
   local r={c=c,mode=c.BodyInstance.DOFMode,values={}}
   for _,k in ipairs(locks)do r.values[k]=c.BodyInstance[k];c.BodyInstance[k]=true end
   records[#records+1]=r
   c:SetConstraintMode(1)
   if c:IsSimulatingPhysics(FName('None'))then
    c:SetPhysicsLinearVelocity({X=0,Y=0,Z=0},false,FName('None'))
    c:SetPhysicsAngularVelocityInDegrees({X=0,Y=0,Z=0},false,FName('None'))
    c:PutRigidBodyToSleep(FName('None'))
   end
  end
 end
 end)
 if not ok then M.restore(records);error(err)end
 return records
end
function M.restore(records)
 for _,r in ipairs(records)do
  if r.c:IsValid()then
   for k,v in pairs(r.values)do r.c.BodyInstance[k]=v end
   r.c:SetConstraintMode(r.mode)
  end
 end
end
return M
