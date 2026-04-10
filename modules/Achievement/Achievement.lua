--=====================================================================================
-- BLU Achievement Module
-- Handles achievement completion sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Achievement = {}
local ACHIEVEMENT_EVENT_ID = "achievement_earned"
local ACHIEVEMENT_PROGRESS_EVENT_ID = "achievement_criteria_earned"

-- Module initialization
function Achievement:Init()
    BLU:RegisterEvent("ACHIEVEMENT_EARNED", function(...) self:OnAchievementEarned(...) end, ACHIEVEMENT_EVENT_ID)
    BLU:RegisterEvent("CRITERIA_EARNED", function(...) self:OnCriteriaEarned(...) end, ACHIEVEMENT_PROGRESS_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Achievement"))
end

-- Cleanup function
function Achievement:Cleanup()
    BLU:UnregisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EVENT_ID)
    BLU:UnregisterEvent("CRITERIA_EARNED", ACHIEVEMENT_PROGRESS_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Achievement"))
end

-- Achievement earned event handler
function Achievement:OnAchievementEarned(event, achievementID, alreadyEarned)
    BLU:Trace("Achievement", "OnAchievementEarned called for achievementID=" .. tostring(achievementID))
    if not BLU.db then
        BLU:Trace("Achievement", "Skipped achievement handling; profile not ready")
        return
    end
    if not BLU.db.enabled then
        BLU:Trace("Achievement", "Skipped achievement handling; addon disabled")
        return
    end
    if BLU.db.modules and BLU.db.modules.achievement == false then
        BLU:Trace("Achievement", "Skipped achievement handling; module disabled")
        return
    end
    if alreadyEarned then
        BLU:Trace("Achievement", "Skipped achievement handling; achievement already earned")
        return
    end
    
    -- Play achievement sound for this category
    BLU:PlayCategorySound("achievement")
    BLU:Trace("Achievement", "Triggered achievement sound playback")
    
    if BLU.db.debugMode then
        local _, name = GetAchievementInfo(achievementID)
        BLU:Print(string.format("%s: %s", BLU:Loc("ACHIEVEMENT_EARNED"), name or BLU:Loc("UNKNOWN")))
    end
end

function Achievement:OnCriteriaEarned(event, achievementID, description, achievementAlreadyEarnedOnAccount)
    BLU:Trace("Achievement", "OnCriteriaEarned called for achievementID=" .. tostring(achievementID))
    if not BLU.db then
        BLU:Trace("Achievement", "Skipped criteria handling; profile not ready")
        return
    end
    if not BLU.db.enabled then
        BLU:Trace("Achievement", "Skipped criteria handling; addon disabled")
        return
    end
    if BLU.db.modules and BLU.db.modules.achievement == false then
        BLU:Trace("Achievement", "Skipped criteria handling; module disabled")
        return
    end
    if achievementAlreadyEarnedOnAccount then
        BLU:Trace("Achievement", "Skipped criteria handling; achievement already earned on account")
        return
    end

    BLU:PlayCategorySound("achievementprogress")
    BLU:Trace("Achievement", "Triggered achievement progress sound playback")

    if BLU.db.debugMode then
        local _, name = GetAchievementInfo(achievementID)
        BLU:Print(BLU:Loc("DEBUG_ACHIEVEMENT_PROGRESS", name or BLU:Loc("UNKNOWN"), description or BLU:Loc("UNKNOWN")))
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["achievement"] = Achievement

-- Export module
return Achievement
