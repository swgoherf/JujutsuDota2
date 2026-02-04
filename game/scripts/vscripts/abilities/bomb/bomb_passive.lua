ability_bomb_passive = class({})
LinkLuaModifier("modifier_bomb_passive", "abilities/bomb/bomb_passive", LUA_MODIFIER_MOTION_NONE)

function ability_bomb_passive:GetIntrinsicModifierName()
    return "modifier_bomb_passive"
end

modifier_bomb_passive = class({})

function modifier_bomb_passive:IsHidden() return true end

function modifier_bomb_passive:DeclareFunctions()
    return { MODIFIER_EVENT_ON_DEATH }
end

function modifier_bomb_passive:OnDeath(params)
    if params.unit == self:GetParent() then
        local parent = self:GetParent()
        local ability = self:GetAbility()
        
        local radius = ability:GetSpecialValueFor("radius")
        local damage = ability:GetSpecialValueFor("damage")

        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(pfx, 0, parent:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(pfx)

        local enemies = FindUnitsInRadius(
            parent:GetTeamNumber(),
            parent:GetAbsOrigin(),
            nil,
            radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false
        )

        local attacker = parent:GetOwner()
        if not attacker then
            attacker = parent
        end

        for _, enemy in pairs(enemies) do
            ApplyDamage({
                victim = enemy,
                attacker = attacker,
                damage = damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = ability
            })
        end
    end
end