--=====================================================================================
-- BLU Level Up Module
-- Handles character level up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
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
    if not BLU.db.profile.enabled then return end
    
    -- Play level up sound for this category
    BLU:PlayCategorySound("levelup")
    
    if BLU.db.profile.debugMode then
        BLU:Print(string.format("%s %d", BLU:Loc("LEVEL_UP"), level))
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["levelup"] = LevelUp

-- Export module
return LevelUp
