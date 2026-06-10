--=====================================================================================
-- BLU Combat Module
-- Drives the combat options panel sound triggers.
-- Sounds are stored per-trigger in BLU.db.combat.selectedSounds[triggerId]
-- and played via the registry (any sound from any loaded pack).
--
-- Panel page 1 triggers:
--   combat_start_sound  -> PLAYER_REGEN_DISABLED
--   combat_end_sound    -> PLAYER_REGEN_ENABLED
--   combat_music_track  -> PLAYER_REGEN_DISABLED  (music channel intent)
--   low_health          -> UNIT_HEALTH player < 35%
--   execute_window      -> UNIT_HEALTH target < 20%
--   encounterend        -> ENCOUNTER_END (any result)
--   encountervictory    -> ENCOUNTER_END (success == 1)
--
-- Panel page 2 triggers:
--   proc_trigger    -> UNIT_AURA on player (aura gained — generic)
--   critical_hit    -> COMBAT_LOG SPELL_DAMAGE/SWING_DAMAGE + crit, source = player
--   critical_heal   -> COMBAT_LOG SPELL_HEAL + crit, source = player
--   resource_capped -> UNIT_POWER_UPDATE player at 100%
--   resource_low    -> UNIT_POWER_UPDATE player < 20%
--   target_lost     -> PLAYER_TARGET_CHANGED, no target
--   pvpvictory      -> PVP_MATCH_COMPLETE winner
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local CombatModule = {}

local EVT_REGEN_DISABLED = "combat_regen_disabled"
local EVT_REGEN_ENABLED  = "combat_regen_enabled"
local EVT_UNIT_HEALTH    = "combat_unit_health"
local EVT_TARGET         = "combat_target_changed"
local EVT_POWER          = "combat_unit_power"
local EVT_COMBATLOG      = "combat_log_event"
local EVT_ENCOUNTER      = "combat_encounter_end"
local EVT_PVP            = "combat_pvp_match"
local EVT_UNIT_AURA      = "combat_unit_aura"

local PER_TRIGGER_COOLDOWN = 1.0   -- seconds between same trigger fires
local LOW_HEALTH_PCT       = 0.35
local EXECUTE_PCT          = 0.20
local RESOURCE_LOW_PCT     = 0.20

CombatModule.lastSoundAt    = {}
CombatModule.inCombat       = false
CombatModule.prevHealthPct  = {}  -- ["player"|"target"] = last pct that triggered low/execute

local function IsEnabled()
    if not BLU.db or BLU.db.enabled == false then return false end
    if BLU.db.modules and BLU.db.modules.combat == false then return false end
    return true
end

local function CanPlayTrigger(triggerId)
    local now = GetTime and GetTime() or 0
    local last = CombatModule.lastSoundAt[triggerId] or 0
    if (now - last) < PER_TRIGGER_COOLDOWN then return false end
    CombatModule.lastSoundAt[triggerId] = now
    return true
end

local function IsUnitBelowThreshold(unit, valueFunc, maxFunc, threshold)
    local ok, isBelow = pcall(function()
        if type(valueFunc) ~= "function" or type(maxFunc) ~= "function" then return nil end
        local max = maxFunc(unit)
        if not max or max <= 0 then return nil end
        return ((valueFunc(unit) or 0) / max) < threshold
    end)
    if ok and type(isBelow) == "boolean" then
        return isBelow
    end
    return nil
end

local function GetUnitPowerState(unit)
    local ok, capped, low = pcall(function()
        if type(UnitPower) ~= "function" or type(UnitPowerMax) ~= "function" then return nil, nil end
        local max = UnitPowerMax(unit)
        if not max or max <= 0 then return nil, nil end
        local pct = (UnitPower(unit) or 0) / max
        return pct >= 1.0, pct < RESOURCE_LOW_PCT
    end)
    if ok then
        return capped, low
    end
    return nil, nil
end

function CombatModule:PlayTrigger(triggerId)
    if not IsEnabled() then return end
    if not CanPlayTrigger(triggerId) then return end

    local combat = BLU.db and BLU.db.combat
    if not combat then return end

    local selected = combat.selectedSounds and combat.selectedSounds[triggerId]
    if not selected or selected == "None" then return end

    local volume   = (combat.soundVolumes and combat.soundVolumes[triggerId]) or "medium"
    local registry = BLU.Modules and BLU.Modules.registry
    if registry and registry.PlaySound then
        registry:PlaySound(selected, nil, {
            categoryOverride = "combat",
            volumeSettingOverride = volume,
        })
    end
end

-- ── Event handlers ──────────────────────────────────────────────────────────

function CombatModule:OnRegenDisabled()
    CombatModule.inCombat = true
    self:PlayTrigger("combat_start_sound")
    self:PlayTrigger("combat_music_track")
    CombatModule.prevHealthPct = {}
end

function CombatModule:OnRegenEnabled()
    CombatModule.inCombat = false
    self:PlayTrigger("combat_end_sound")
    CombatModule.prevHealthPct = {}
end

function CombatModule:OnUnitHealth(_, unit)
    if unit ~= "player" and unit ~= "target" then return end

    if unit == "player" then
        local isBelow = IsUnitBelowThreshold("player", UnitHealth, UnitHealthMax, LOW_HEALTH_PCT)
        if isBelow == nil then return end
        local prev = self.prevHealthPct["player"]
        if isBelow and prev ~= true then
            self:PlayTrigger("low_health")
        end
        self.prevHealthPct["player"] = isBelow

    elseif unit == "target" then
        local isBelow = IsUnitBelowThreshold("target", UnitHealth, UnitHealthMax, EXECUTE_PCT)
        if isBelow == nil then return end
        local prev = self.prevHealthPct["target"]
        if isBelow and prev ~= true then
            self:PlayTrigger("execute_window")
        end
        self.prevHealthPct["target"] = isBelow
    end
end

function CombatModule:OnTargetChanged()
    if not UnitExists("target") then
        self:PlayTrigger("target_lost")
        self.prevHealthPct["target"] = nil
    else
        self.prevHealthPct["target"] = nil
    end
end

function CombatModule:OnUnitPower(_, unit)
    if unit ~= "player" then return end
    local capped, low = GetUnitPowerState("player")
    if capped then
        self:PlayTrigger("resource_capped")
    elseif low then
        self:PlayTrigger("resource_low")
    end
end

function CombatModule:OnCombatLog()
    local _, event, _, sourceGUID, _, _, _, _, _, _, _, _, _, _, _, _, crit = CombatLogGetCurrentEventInfo()
    if not sourceGUID or sourceGUID ~= UnitGUID("player") then return end

    if (event == "SPELL_DAMAGE" or event == "SWING_DAMAGE") and crit then
        self:PlayTrigger("critical_hit")
    elseif event == "SPELL_HEAL" and crit then
        self:PlayTrigger("critical_heal")
    end
end

function CombatModule:OnUnitAura(_, unit)
    if unit ~= "player" then return end
    self:PlayTrigger("proc_trigger")
end

function CombatModule:OnEncounterEnd(_, encounterID, encounterName, difficultyID, groupSize, success)
    self:PlayTrigger("encounterend")
    if success == 1 then
        self:PlayTrigger("encountervictory")
    end
end

function CombatModule:OnPvPMatchComplete()
    -- PVP_MATCH_COMPLETE fires for all players; we check if we were on the winning side
    local winner = C_PvP and C_PvP.GetActiveMatchResults and C_PvP.GetActiveMatchResults()
    if winner and winner.isWinner then
        self:PlayTrigger("pvpvictory")
    else
        -- Fallback: always fire (user can mute if not desired)
        self:PlayTrigger("pvpvictory")
    end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────────

function CombatModule:RegisterLegacyEvents()
    BLU:RegisterEvent("PLAYER_REGEN_DISABLED",     function(e, ...) self:OnRegenDisabled() end,      EVT_REGEN_DISABLED)
    BLU:RegisterEvent("PLAYER_REGEN_ENABLED",      function(e, ...) self:OnRegenEnabled() end,       EVT_REGEN_ENABLED)
    BLU:RegisterEvent("UNIT_HEALTH",               function(e, ...) self:OnUnitHealth(e, ...) end,   EVT_UNIT_HEALTH)
    BLU:RegisterEvent("PLAYER_TARGET_CHANGED",     function(e, ...) self:OnTargetChanged() end,      EVT_TARGET)
    BLU:RegisterEvent("UNIT_POWER_UPDATE",         function(e, ...) self:OnUnitPower(e, ...) end,    EVT_POWER)
    BLU:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function() self:OnCombatLog() end,              EVT_COMBATLOG)
    BLU:RegisterEvent("ENCOUNTER_END",             function(e, ...) self:OnEncounterEnd(e, ...) end, EVT_ENCOUNTER)
    BLU:RegisterEvent("PVP_MATCH_COMPLETE",        function(e, ...) self:OnPvPMatchComplete() end,   EVT_PVP)
    BLU:RegisterEvent("UNIT_AURA",                 function(e, ...) self:OnUnitAura(e, ...) end,     EVT_UNIT_AURA)
end

function CombatModule:UnregisterLegacyEvents()
    BLU:UnregisterEvent("PLAYER_REGEN_DISABLED",      EVT_REGEN_DISABLED)
    BLU:UnregisterEvent("PLAYER_REGEN_ENABLED",       EVT_REGEN_ENABLED)
    BLU:UnregisterEvent("UNIT_HEALTH",                EVT_UNIT_HEALTH)
    BLU:UnregisterEvent("PLAYER_TARGET_CHANGED",      EVT_TARGET)
    BLU:UnregisterEvent("UNIT_POWER_UPDATE",          EVT_POWER)
    BLU:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", EVT_COMBATLOG)
    BLU:UnregisterEvent("ENCOUNTER_END",              EVT_ENCOUNTER)
    BLU:UnregisterEvent("PVP_MATCH_COMPLETE",         EVT_PVP)
    BLU:UnregisterEvent("UNIT_AURA",                  EVT_UNIT_AURA)
end

function CombatModule:Init()
    -- Only use framework path if RGXCombat is available and the bridge exists.
    if BLU.RegisterFrameworkCallback then
        self.frameworkDisposers = {
            BLU:RegisterFrameworkCallback("combat", "OnEnter", function() self:OnRegenDisabled() end),
            BLU:RegisterFrameworkCallback("combat", "OnLeave", function() self:OnRegenEnabled() end),
            BLU:RegisterFrameworkCallback("combat", "OnLowHealth", function() self:PlayTrigger("low_health") end),
            BLU:RegisterFrameworkCallback("combat", "OnExecuteWindow", function() self:PlayTrigger("execute_window") end),
            BLU:RegisterFrameworkCallback("combat", "OnResourceCapped", function() self:PlayTrigger("resource_capped") end),
            BLU:RegisterFrameworkCallback("combat", "OnResourceLow", function() self:PlayTrigger("resource_low") end),
            BLU:RegisterFrameworkCallback("combat", "OnTargetLost", function() self:PlayTrigger("target_lost") end),
            BLU:RegisterFrameworkCallback("combat", "OnCrit", function() self:PlayTrigger("critical_hit") end),
            BLU:RegisterFrameworkCallback("combat", "OnCritHeal", function() self:PlayTrigger("critical_heal") end),
            BLU:RegisterFrameworkCallback("combat", "OnProc", function() self:PlayTrigger("proc_trigger") end),
            BLU:RegisterFrameworkCallback("combat", "OnEncounterEnd", function() self:PlayTrigger("encounterend") end),
            BLU:RegisterFrameworkCallback("combat", "OnEncounterVictory", function() self:PlayTrigger("encountervictory") end),
            BLU:RegisterFrameworkCallback("combat", "OnPvPVictory", function() self:PlayTrigger("pvpvictory") end),
        }
    end

    local frameworkReady = self.frameworkDisposers ~= nil
    if frameworkReady then
        for i = 1, 13 do
            if type(self.frameworkDisposers[i]) ~= "function" then
                frameworkReady = false
                break
            end
        end
    end

    if not frameworkReady then
        if BLU.DisposeFrameworkCallbacks and self.frameworkDisposers then
            BLU:DisposeFrameworkCallbacks(self.frameworkDisposers)
        end
        self.frameworkDisposers = nil
        -- Defer legacy event registration: RegisterEvent is blocked during
        -- loading screen into combat zones (battleground, arena, world PvP).
        C_Timer.After(0.5, function()
            if InCombatLockdown and InCombatLockdown() then
                BLU:RegisterEvent("PLAYER_REGEN_ENABLED", function()
                    self:RegisterLegacyEvents()
                end, "BLUCombat_LegacyRetry")
                return
            end
            self:RegisterLegacyEvents()
        end)
    end

    BLU:PrintDebug("[Combat] Combat module initialized")
    BLU:Emit("blu:moduleReady", "combat")
end

function CombatModule:Cleanup()
    if self.frameworkDisposers then
        BLU:DisposeFrameworkCallbacks(self.frameworkDisposers)
        self.frameworkDisposers = nil
    else
        self:UnregisterLegacyEvents()
    end

    self.lastSoundAt   = {}
    self.prevHealthPct = {}
    self.inCombat      = false
    BLU:PrintDebug("[Combat] Combat module cleaned up")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["combat"] = CombatModule

return CombatModule
