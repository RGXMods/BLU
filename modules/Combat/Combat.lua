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
--   lust_sound      -> UNIT_AURA on player, Bloodlust/Heroism/Time Warp/
--                       Ancient Hysteria/Primal Rage specifically gained
--   critical_hit    -> COMBAT_LOG SPELL_DAMAGE/SWING_DAMAGE + crit, source = player
--   critical_heal   -> COMBAT_LOG SPELL_HEAL + crit, source = player
--   resource_capped -> UNIT_POWER_UPDATE player at 100%
--   resource_low    -> UNIT_POWER_UPDATE player < 20%
--   target_lost     -> PLAYER_TARGET_CHANGED, no target
--   pvpvictory      -> PVP_MATCH_COMPLETE winner
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Combat = _G.RGXCombat
local CombatModule = {}

local PER_TRIGGER_COOLDOWN = 1.0   -- seconds between same trigger fires

-- Spell IDs for the current bloodlust-class raid buffs. Matched by ID
-- (locale-independent) rather than name.
local LUST_SPELL_IDS = {
    [2825]   = true, -- Bloodlust (Shaman)
    [32182]  = true, -- Heroism (Shaman)
    [80353]  = true, -- Time Warp (Mage)
    [90355]  = true, -- Ancient Hysteria (Hunter exotic pet ability)
    [264667] = true, -- Primal Rage (Evoker)
}

CombatModule.lastSoundAt          = {}
CombatModule.hadLust              = false -- edge-detect Bloodlust-class buffs on player
CombatModule.savedAmbienceEnabled = nil

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

function CombatModule:PlayTrigger(triggerId)
    if not IsEnabled() then return end
    if not CanPlayTrigger(triggerId) then return end

    local combat = BLU.db and BLU.db.combat
    if not combat then return end

    local selected = combat.selectedSounds and combat.selectedSounds[triggerId]
    if not selected or selected == "None" or selected == "none" then return end

    local volume   = (combat.soundVolumes and combat.soundVolumes[triggerId]) or "medium"
    local registry = BLU.Modules and BLU.Modules.registry
    if registry and registry.PlaySound then
        registry:PlaySound(selected, nil, {
            categoryOverride = "combat",
            volumeSettingOverride = volume,
            triggerIdOverride = triggerId,
        })
    end
end

function CombatModule:MuteAmbientForCombatMusic()
    if type(GetCVar) ~= "function" or type(SetCVar) ~= "function" then
        return
    end

    if self.savedAmbienceEnabled == nil then
        self.savedAmbienceEnabled = GetCVar("Sound_EnableAmbience")
    end

    SetCVar("Sound_EnableAmbience", "0")
end

function CombatModule:RestoreAmbientAfterCombatMusic()
    if self.savedAmbienceEnabled == nil or type(SetCVar) ~= "function" then
        return
    end

    SetCVar("Sound_EnableAmbience", self.savedAmbienceEnabled)
    self.savedAmbienceEnabled = nil
end

function CombatModule:StopCombatMusic()
    if StopMusic then
        pcall(StopMusic)
    end
    self:RestoreAmbientAfterCombatMusic()
end

function CombatModule:PlayCombatMusic()
    if not IsEnabled() then return end

    local combat = BLU.db and BLU.db.combat
    if not combat then return end

    local selected = combat.selectedSounds and combat.selectedSounds["combat_music_track"]
    if not selected or selected == "None" or selected == "none" then
        self:RestoreAmbientAfterCombatMusic()
        return
    end

    local registry = BLU.Modules and BLU.Modules.registry
    if not (registry and registry.GetSound) then return end

    local soundInfo = registry:GetSound(selected)
    local filePath  = soundInfo and (soundInfo.file or soundInfo.path)
    if not filePath then return end

    self:StopCombatMusic()
    self:MuteAmbientForCombatMusic()

    if PlayMusic then
        pcall(PlayMusic, filePath)
    end
end

-- Player lust presence via C_UnitAuras.GetPlayerAuraBySpellID (AllowedWhenTainted).
-- Avoids UNIT_AURA updateInfo.addedAuras, which is ConditionalSecretContents and
-- errors under addon taint: "ipairs (table expected, got secret)".
local function PlayerHasLustAura()
    if not C_UnitAuras or type(C_UnitAuras.GetPlayerAuraBySpellID) ~= "function" then
        return false
    end
    for spellId in pairs(LUST_SPELL_IDS) do
        local ok, aura = pcall(C_UnitAuras.GetPlayerAuraBySpellID, spellId)
        if ok and aura then
            return true
        end
    end
    return false
end

function CombatModule:OnUnitAura(_, unit, updateInfo)
    if unit ~= "player" then return end
    -- Lust detection via safe C_UnitAuras fallback when addedAuras is secret.
    local lustGained = false
    local added = updateInfo and updateInfo.addedAuras
    local addedReadable = added ~= nil
        and type(added) == "table"
        and (type(canaccesstable) ~= "function" or canaccesstable(added))
        and (type(issecrettable) ~= "function" or not issecrettable(added))

    if addedReadable then
        for _, aura in ipairs(added) do
            local spellId = aura and aura.spellId
            if type(spellId) == "number" and LUST_SPELL_IDS[spellId] then
                lustGained = true
                break
            end
        end
        -- Keep hadLust in sync so a later secret update does not re-fire.
        if lustGained then
            self.hadLust = true
        elseif updateInfo and updateInfo.removedAuraInstanceIDs then
            self.hadLust = PlayerHasLustAura()
        end
    else
        local hasLust = PlayerHasLustAura()
        if hasLust and not self.hadLust then
            lustGained = true
        end
        self.hadLust = hasLust
    end

    if lustGained then
        self:PlayTrigger("lust_sound")
    end
end

-- ── Lifecycle ────────────────────────────────────────────────────────────────

function CombatModule:Init()
    if not Combat then return end

    Combat:OnEnter(function()
        self:PlayTrigger("combat_start_sound")
        self:PlayCombatMusic()
    end)

    Combat:OnLeave(function()
        self:StopCombatMusic()
        self:PlayTrigger("combat_end_sound")
    end)

    Combat:OnLowHealth(function()
        self:PlayTrigger("low_health")
    end)

    Combat:OnExecuteWindow(function()
        self:PlayTrigger("execute_window")
    end)

    Combat:OnTargetLost(function()
        self:PlayTrigger("target_lost")
    end)

    Combat:OnResourceCapped(function()
        self:PlayTrigger("resource_capped")
    end)

    Combat:OnResourceLow(function()
        self:PlayTrigger("resource_low")
    end)

    Combat:OnCrit(function(amount, spellName, isMelee)
        self:PlayTrigger("critical_hit")
    end)

    Combat:OnCritHeal(function(amount, spellName)
        self:PlayTrigger("critical_heal")
    end)

    Combat:OnProc(function()
        self:PlayTrigger("proc_trigger")
    end)

    Combat:OnEncounterEnd(function(encounterID, encounterName, difficultyID, groupSize, success)
        self:PlayTrigger("encounterend")
        if success == 1 then
            self:PlayTrigger("encountervictory")
        end
    end)

    Combat:OnPvPVictory(function()
        self:PlayTrigger("pvpvictory")
    end)

    -- Lust detection still needs UNIT_AURA because OnProc does not expose
    -- aura data; guard against secret addedAuras.
    BLU:RegisterEvent("UNIT_AURA", function(_, unit, updateInfo)
        self:OnUnitAura(_, unit, updateInfo)
    end, "combat_unit_aura")

    BLU:PrintDebug("[Combat] Combat module initialized")
    if BLU.Emit then BLU:Emit("blu:moduleReady", "combat") end
end

function CombatModule:Cleanup()
    self:StopCombatMusic()
    self.lastSoundAt = {}
    self.hadLust = false
    BLU:PrintDebug("[Combat] Combat module cleaned up")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["combat"] = CombatModule

return CombatModule
