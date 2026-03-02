--=====================================================================================
-- BLU Level Up Module
-- Handles character level up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local LevelUp = {}
local LEVELUP_EVENT_ID = "player_level_up"

-- Module initialization
function LevelUp:Init()
    BLU:RegisterEvent("PLAYER_LEVEL_UP", function(...) self:OnLevelUp(...) end, LEVELUP_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "LevelUp"))
end

-- Cleanup function
function LevelUp:Cleanup()
    BLU:UnregisterEvent("PLAYER_LEVEL_UP", LEVELUP_EVENT_ID)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "LevelUp"))
end

-- Level up event handler
function LevelUp:OnLevelUp(event, level)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.levelup == false then return end
    
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
