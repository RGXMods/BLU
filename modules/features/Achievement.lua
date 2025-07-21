--=====================================================================================
-- BLU Achievement Module
-- Handles achievement completion sounds
--=====================================================================================

local addonName, addonTable = ...
local Achievement = {}

-- Module initialization
function Achievement:Init()
    BLU:RegisterEvent("ACHIEVEMENT_EARNED", function(...) self:OnAchievementEarned(...) end)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Achievement"))
end

-- Cleanup function
function Achievement:Cleanup()
    BLU:UnregisterEvent("ACHIEVEMENT_EARNED")
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Achievement"))
end

-- Achievement earned event handler
function Achievement:OnAchievementEarned(event, achievementID, alreadyEarned)
    if not BLU.db.profile.enableAchievement then return end
    if alreadyEarned then return end
    
    local soundName = BLU.db.profile.achievementSound
    local volume = BLU.db.profile.achievementVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
    
    if BLU.debugMode then
        local _, name = GetAchievementInfo(achievementID)
        BLU:Print(string.format("%s: %s", BLU:Loc("ACHIEVEMENT_EARNED"), name or BLU:Loc("UNKNOWN")))
    end
end

-- Export module
return Achievement