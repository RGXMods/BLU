--=====================================================================================
-- BLU WoW Default Sound Module
-- Uses built-in WoW sounds as placeholders
--=====================================================================================

local addonName, addonTable = ...
local WoWDefault = {}

-- Sound definitions using WoW soundkit IDs
WoWDefault.sounds = {
    -- Level Up
    wowdefault_levelup = {
        name = "WoW - Level Up (Default)",
        soundKit = 888, -- gsTitleIntroMovie
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement
    wowdefault_achievement = {
        name = "WoW - Achievement (Default)",
        soundKit = 12891, -- UI_Achievement_Alert_Start
        duration = 2.0,
        category = "achievement"
    },
    
    -- Quest Complete
    wowdefault_quest = {
        name = "WoW - Quest Complete (Default)", 
        soundKit = 618, -- QuestComplete
        duration = 1.5,
        category = "quest"
    },
    
    -- Reputation
    wowdefault_reputation = {
        name = "WoW - Reputation (Default)",
        soundKit = 12198, -- UI_ReputationLevelUp
        duration = 2.0,
        category = "reputation"
    },
    
    -- Honor Rank
    wowdefault_honorrank = {
        name = "WoW - Honor Rank (Default)",
        soundKit = 8455, -- PVP Reward
        duration = 2.5,
        category = "honorrank"
    },
    
    -- Renown Rank
    wowdefault_renownrank = {
        name = "WoW - Renown (Default)",
        soundKit = 168610, -- UI_Renown_LevelUp
        duration = 3.0,
        category = "renownrank"
    },
    
    -- Trading Post
    wowdefault_tradingpost = {
        name = "WoW - Trading Post (Default)",
        soundKit = 179115, -- UI_Trading_Post_Reward_Fanfare
        duration = 2.5,
        category = "tradingpost"
    },
    
    -- Battle Pet
    wowdefault_battlepet = {
        name = "WoW - Pet Battle Victory (Default)",
        soundKit = 65973, -- UI_PetBattle_Victory
        duration = 3.0,
        category = "battlepet"
    },
    
    -- Delve Companion
    wowdefault_delvecompanion = {
        name = "WoW - Delve Complete (Default)",
        soundKit = 182216, -- UI_Delve_Complete
        duration = 2.5,
        category = "delvecompanion"
    }
}

-- Initialize sound module
function WoWDefault:Init()
    -- Register sounds with the main addon
    -- For soundKit sounds, we need special handling
    for soundId, soundData in pairs(self.sounds) do
        -- Create a modified sound data for soundKit
        local registrationData = {
            name = soundData.name,
            soundKit = soundData.soundKit,
            duration = soundData.duration,
            category = soundData.category,
            isBuiltIn = true
        }
        BLU:RegisterSound(soundId, registrationData)
    end
    
    BLU:PrintDebug("WoW Default sound module loaded")
end

-- Cleanup (if needed)
function WoWDefault:Cleanup()
    -- Unregister sounds
    for soundId in pairs(self.sounds) do
        BLU:UnregisterSound(soundId)
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["WoWDefault"] = WoWDefault

-- Export module
return WoWDefault