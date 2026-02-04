if JD2 == nil then
    JD2 = class({})
end

require('libraries/timers')

function Precache( context )
end

function Activate()
    GameRules.AddonTemplate = JD2()
    GameRules.AddonTemplate:InitGameMode()
end

function JD2:InitGameMode()
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 1)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 5)

    GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
    GameRules:SetHeroRespawnEnabled(true)
    GameRules:SetSameHeroSelectionEnabled(false)
    GameRules:SetGoldTickTime(0.6)
    GameRules:SetGoldPerTick(2)
    local gameMode = GameRules:GetGameModeEntity()
    gameMode:SetFreeCourierModeEnabled(true)
    gameMode:SetModifyGoldFilter(Dynamic_Wrap(JD2, "GoldFilter"), self)
    gameMode:SetThink("OnThink", self, "GlobalThink", 2)
	GameRules:SetCustomGameSetupAutoLaunchDelay(5) 
    GameRules:SetHeroSelectionTime(30)            
    GameRules:SetStrategyTime(5)                   
    -- GameRules:SetShowcaseTime()                   
    GameRules:SetPreGameTime(15) --крипы 
end

function JD2:GoldFilter(filterTable)
    local playerID = filterTable["player_id_const"]
    local gold = filterTable["gold"]
	local multiple_gold = 5

    if playerID == -1 then return true end

    local team = PlayerResource:GetTeam(playerID)

    if team == DOTA_TEAM_GOODGUYS then
        filterTable["gold"] = gold * multiple_gold
    end

    return true
end

function JD2:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end