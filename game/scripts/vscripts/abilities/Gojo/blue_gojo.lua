ability_blue_gojo = class({})
LinkLuaModifier("modifier_blue_gojo_pull", "abilities/Gojo/blue_gojo", LUA_MODIFIER_MOTION_HORIZONTAL)

function ability_blue_gojo:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("pull_duration")

    local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(),
        point,
        nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )
    
    local particle_vacuum = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(particle_vacuum, 0, point)
    ParticleManager:SetParticleControl(particle_vacuum, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle_vacuum)

    for _, enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, self, "modifier_blue_gojo_pull", {
            duration = duration, 
            x = point.x,
            y = point.y,
            z = point.z
        })
    end

    local bomb = CreateUnitByName("npc_dota_custom_bomb_unit", point, true, caster, caster, DOTA_TEAM_NEUTRALS)
    bomb:AddNewModifier(caster, self, "modifier_invisible", {})
end

modifier_blue_gojo_pull = class({})

function modifier_blue_gojo_pull:IsHidden() return true end
function modifier_blue_gojo_pull:IsPurgable() return false end

function modifier_blue_gojo_pull:OnCreated(kv)
    if not IsServer() then return end
    self.center = Vector(kv.x, kv.y, kv.z)
    if self:ApplyHorizontalMotionController() == false then
        self:Destroy()
    end
end

function modifier_blue_gojo_pull:UpdateHorizontalMotion(me, dt)
    if not IsServer() then return end
    
    local pos = me:GetAbsOrigin()
    local distance_vec = self.center - pos
    local distance = distance_vec:Length2D()
    local direction = distance_vec:Normalized()
    
    local speed = distance / self:GetRemainingTime()
    
    local next_pos = pos + direction * speed * dt
    me:SetAbsOrigin(next_pos)
    
    if distance < 10 then
        self:Destroy()
    end
end

function modifier_blue_gojo_pull:OnDestroy()
    if not IsServer() then return end
    self:GetParent():RemoveHorizontalMotionController(self)
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
end

function modifier_blue_gojo_pull:CheckState()
    return {
        [MODIFIER_STATE_STUNNED] = true 
    }
end