--=====================================================================================
-- BLU Level Up Module
-- Handles character level up sounds
--=====================================================================================

local addonName, addonTable = ...
local LevelUp = {}

-- Module initialization
function LevelUp:Init()
    BLU:RegisterEvent("PLAYER_LEVEL_UP", function(...) self:OnLevelUp(...) end)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "LevelUp"))
end

-- Cleanup function
function LevelUp:Cleanup()
    BLU:UnregisterEvent("PLAYER_LEVEL_UP")
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "LevelUp"))
end

-- Level up event handler
function LevelUp:OnLevelUp(event, level)
    if not BLU.db.profile.enableLevelUp then return end
    
    local soundName = BLU.db.profile.levelUpSound
    local volume = BLU.db.profile.levelUpVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
    
    if BLU.debugMode then
        BLU:Print(string.format("%s %d", BLU:Loc("LEVEL_UP"), level))
    end
end

-- Export module
return LevelUp