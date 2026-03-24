--=====================================================================================
-- BLU Achievement Module
-- Handles achievement completion sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Achievement = {}
local ACHIEVEMENT_EVENT_ID = "achievement_earned"

-- Module initialization
function Achievement:Init()
    BLU:RegisterEvent("ACHIEVEMENT_EARNED", function(...) self:OnAchievementEarned(...) end, ACHIEVEMENT_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Achievement"))
end

-- Cleanup function
function Achievement:Cleanup()
    BLU:UnregisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Achievement"))
end

-- Achievement earned event handler
function Achievement:OnAchievementEarned(event, achievementID, alreadyEarned)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.achievement == false then return end
    if alreadyEarned then return end
    
    -- Play achievement sound for this category
    BLU:PlayCategorySound("achievement")
    
    if BLU.db.profile.debugMode then
        local _, name = GetAchievementInfo(achievementID)
        BLU:Print(string.format("%s: %s", BLU:Loc("ACHIEVEMENT_EARNED"), name or BLU:Loc("UNKNOWN")))
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["achievement"] = Achievement

-- Export module
return Achievement
