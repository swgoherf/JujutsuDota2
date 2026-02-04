modifier_red_gojo = class({})

function modifier_red_gojo:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        if parent:GetUnitName() == "npc_dota_custom_bomb_unit" then
            parent:Kill(self:GetAbility(), self:GetCaster())
        end
        self:Destroy()
    end
end

ability_red_gojo = class({})

function ability_red_gojo:OnSpellStart()
    local caster = self:GetCaster()
    local target_pos = self:GetCursorPosition()
    local direction = (target_pos - caster:GetAbsOrigin()):Normalized()

    local info = {
        Ability = self,
        EffectName = "particles/units/heroes/hero_magnataur/magnataur_shockwave.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self:GetSpecialValueFor("distance"),
        fStartRadius = self:GetSpecialValueFor("radius"),
        fEndRadius = self:GetSpecialValueFor("radius"),
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_BOTH,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        vVelocity = direction * self:GetSpecialValueFor("speed"),
    }

    ProjectileManager:CreateLinearProjectile(info)
end

function ability_red_gojo:OnProjectileHit(target, location)
    if not target then return end

    local caster = self:GetCaster()

    if target:GetTeamNumber() == caster:GetTeamNumber() then
        target:AddNewModifier(caster, self, "modifier_red_gojo", {
            duration = self:GetSpecialValueFor("detonation_delay")
        })
    else
        ApplyDamage({
            victim = target,
            attacker = caster,
            damage = self:GetSpecialValueFor("damage"),
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        })
    end

    return false 
end