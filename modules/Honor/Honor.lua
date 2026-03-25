--=====================================================================================
-- BLU Honor Rank Module
-- Handles Honor rank up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local HonorRank = {}

local HONOR_EVENT_ID_LEVEL = "honor_level_update"
local HONOR_EVENT_ID_RANK = "honor_pvp_rank_changed"
local HONOR_EVENT_ID_XP = "honor_xp_update"
local HONOR_EVENT_ID_ENTERING_WORLD = "honor_player_entering_world"
local HONOR_SOUND_COOLDOWN_SECONDS = 0.30
local HONOR_CHECK_DELAY_SECONDS = 0.20

HonorRank.currentHonorLevel = nil
HonorRank.lastSoundAt = 0
HonorRank.pendingCheck = false

local function GetCurrentHonorLevel()
    local level = 0

    if type(UnitHonorLevel) == "function" then
        local ok, value = pcall(UnitHonorLevel, "player")
        if ok and type(value) == "number" then
            level = value
        end
    end

    return math.max(0, math.floor(level or 0))
end

function HonorRank:IsEnabled()
    if not BLU.db or not BLU.db.profile then return false end
    if not BLU.db.profile.enabled then return false end
    if not BLU.db.profile.enableHonorRank then return false end
    if BLU.db.profile.modules and BLU.db.profile.modules.honorrank == false then return false end
    return true
end

function HonorRank:UpdateCurrentHonorLevel()
    local success, err = pcall(function()
        self.currentHonorLevel = GetCurrentHonorLevel()
    end)
    if not success then
        BLU:PrintError("Error in HonorRank:UpdateCurrentHonorLevel: " .. tostring(err))
    end
end

function HonorRank:EvaluateHonorLevelChange(triggerName)
    if not self:IsEnabled() then
        self:UpdateCurrentHonorLevel()
        return
    end

    local newLevel = GetCurrentHonorLevel()
    local oldLevel = self.currentHonorLevel

    if oldLevel == nil then
        self.currentHonorLevel = newLevel
        return
    end

    if newLevel > oldLevel then
        self:PlayHonorSound()

        if BLU.debugMode then
            BLU:Print(string.format("Honor level increased: %d -> %d (%s)", oldLevel, newLevel, tostring(triggerName or "unknown")))
        end
    elseif BLU.debugMode and newLevel < oldLevel then
        BLU:Print(string.format("Honor level resynced downward: %d -> %d (%s)", oldLevel, newLevel, tostring(triggerName or "unknown")))
    end

    self.currentHonorLevel = newLevel
end

function HonorRank:QueueHonorLevelCheck(triggerName, delaySeconds)
    if self.pendingCheck then
        return
    end

    self.pendingCheck = true
    C_Timer.After(delaySeconds or HONOR_CHECK_DELAY_SECONDS, function()
        self.pendingCheck = false
        self:EvaluateHonorLevelChange(triggerName)
    end)
end

function HonorRank:Init()
    BLU:RegisterEvent("HONOR_LEVEL_UPDATE", function(event, ...)
        self:OnHonorLevelUpdate(event, ...)
    end, HONOR_EVENT_ID_LEVEL)
    BLU:RegisterEvent("PLAYER_PVP_RANK_CHANGED", function(event, ...)
        self:OnPvPRankChanged(event, ...)
    end, HONOR_EVENT_ID_RANK)
    BLU:RegisterEvent("HONOR_XP_UPDATE", function(event, ...)
        self:OnHonorXPUpdate(event, ...)
    end, HONOR_EVENT_ID_XP)
    BLU:RegisterEvent("PLAYER_ENTERING_WORLD", function(event, ...)
        self:OnPlayerEnteringWorld(event, ...)
    end, HONOR_EVENT_ID_ENTERING_WORLD)

    self:UpdateCurrentHonorLevel()

    BLU:PrintDebug("HonorRank module initialized")
end

function HonorRank:Cleanup()
    BLU:UnregisterEvent("HONOR_LEVEL_UPDATE", HONOR_EVENT_ID_LEVEL)
    BLU:UnregisterEvent("PLAYER_PVP_RANK_CHANGED", HONOR_EVENT_ID_RANK)
    BLU:UnregisterEvent("HONOR_XP_UPDATE", HONOR_EVENT_ID_XP)
    BLU:UnregisterEvent("PLAYER_ENTERING_WORLD", HONOR_EVENT_ID_ENTERING_WORLD)

    BLU:PrintDebug("HonorRank module cleaned up")
end

function HonorRank:OnHonorLevelUpdate(event, ...)
    self:QueueHonorLevelCheck(event, 0.05)
end

function HonorRank:OnPvPRankChanged(event, ...)
    self:QueueHonorLevelCheck(event, HONOR_CHECK_DELAY_SECONDS)
end

function HonorRank:OnHonorXPUpdate(event, ...)
    self:QueueHonorLevelCheck(event, HONOR_CHECK_DELAY_SECONDS)
end

function HonorRank:OnPlayerEnteringWorld(event, ...)
    self:QueueHonorLevelCheck(event, 1.0)
end

function HonorRank:PlayHonorSound()
    local now = GetTime and GetTime() or 0
    if self.lastSoundAt and (now - self.lastSoundAt) < HONOR_SOUND_COOLDOWN_SECONDS then
        return
    end
    self.lastSoundAt = now
    BLU:PlayCategorySound("honorrank")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["honor"] = HonorRank

return HonorRank
