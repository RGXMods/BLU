--=====================================================================================
-- BLU Honor Rank Module
-- Handles Honor rank up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local HonorRank = {}

local HONOR_EVENT_ID_LEVEL = "honor_level_update"
local HONOR_EVENT_ID_RANK = "honor_pvp_rank_changed"
local HONOR_SOUND_COOLDOWN_SECONDS = 0.30

-- Module variables
HonorRank.currentHonorLevel = nil
HonorRank.lastSoundAt = 0

-- Module initialization
function HonorRank:Init()
    -- Honor events
    BLU:RegisterEvent("HONOR_LEVEL_UPDATE", function(...) self:OnHonorLevelUpdate(...) end, HONOR_EVENT_ID_LEVEL)
    BLU:RegisterEvent("PLAYER_PVP_RANK_CHANGED", function(...) self:OnPvPRankChanged(...) end, HONOR_EVENT_ID_RANK)
    
    -- Get current honor level
    self:UpdateCurrentHonorLevel()
    
    BLU:PrintDebug("HonorRank module initialized")
end

-- Cleanup function
function HonorRank:Cleanup()
    BLU:UnregisterEvent("HONOR_LEVEL_UPDATE", HONOR_EVENT_ID_LEVEL)
    BLU:UnregisterEvent("PLAYER_PVP_RANK_CHANGED", HONOR_EVENT_ID_RANK)
    
    BLU:PrintDebug("HonorRank module cleaned up")
end

-- Update current honor level
function HonorRank:UpdateCurrentHonorLevel()
    local success, err = pcall(function()
        if UnitLevel("player") >= 10 then
            self.currentHonorLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
        end
    end)
    if not success then
        BLU:PrintError("Error in HonorRank:UpdateCurrentHonorLevel: " .. tostring(err))
    end
end

-- Honor level update handler
function HonorRank:OnHonorLevelUpdate(event, isLevelUp)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableHonorRank then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.honorrank == false then return end
    if not isLevelUp then return end
    
    self:PlayHonorSound()
    
    if BLU.debugMode then
        local newLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
        BLU:Print(string.format("Honor level increased to %d!", newLevel))
    end

    self:UpdateCurrentHonorLevel()
end

-- PvP rank changed handler
function HonorRank:OnPvPRankChanged(event)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if not BLU.db.profile.enableHonorRank then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.honorrank == false then return end
    
    -- Check if honor level actually increased
    local newLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
    
    if self.currentHonorLevel and newLevel > self.currentHonorLevel then
        self:PlayHonorSound()
        
        if BLU.debugMode then
            BLU:Print(string.format("PvP Honor rank increased: %d -> %d", self.currentHonorLevel, newLevel))
        end
    end

    self.currentHonorLevel = newLevel
end

-- Play honor rank sound
function HonorRank:PlayHonorSound()
    local now = GetTime and GetTime() or 0
    if self.lastSoundAt and (now - self.lastSoundAt) < HONOR_SOUND_COOLDOWN_SECONDS then
        return
    end
    self.lastSoundAt = now
    BLU:PlayCategorySound("honorrank")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["honor"] = HonorRank

-- Export module
return HonorRank
