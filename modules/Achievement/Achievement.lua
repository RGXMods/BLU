--=====================================================================================
-- BLU Achievement Module
-- Handles achievement completion sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local achievement = {}

-- Module initialization
function achievement:Init()
    BLU:RegisterEvent("ACHIEVEMENT_EARNED", function(...) self:OnAchievementEarned(...) end)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Achievement"))
end

-- Cleanup function
function achievement:Cleanup()
    BLU:UnregisterEvent("ACHIEVEMENT_EARNED")
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Achievement"))
end

-- Achievement earned event handler
function achievement:OnAchievementEarned(event, achievementID, alreadyEarned)
    if not BLU.db.profile.enabled then return end
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
BLU.Modules["achievement"] = achievement
