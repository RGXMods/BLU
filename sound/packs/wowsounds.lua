--=====================================================================================
-- BLU - sound/packs/wowsounds.lua  
-- Comprehensive WoW built-in sounds using soundKit IDs
--=====================================================================================

local addonName, BLU = ...
local WoWSounds = {}

-- Sound definitions using WoW soundKit IDs
-- These are categorized by event type
WoWSounds.sounds = {
    -- Level Up Sounds
    wowsounds_levelup_fanfare = {
        name = "WoW - Level Up Fanfare",
        soundKit = 888, -- gsTitleIntroMovie
        duration = 3.0,
        category = "levelup"
    },
    wowsounds_levelup_ding = {
        name = "WoW - Level Ding",
        soundKit = 569, -- LevelUp
        duration = 2.0,
        category = "levelup"
    },
    wowsounds_levelup_gong = {
        name = "WoW - Gong",
        soundKit = 624, -- GongTrigger
        duration = 3.0,
        category = "levelup"
    },
    
    -- Achievement Sounds
    wowsounds_achievement_default = {
        name = "WoW - Achievement Earned",
        soundKit = 12891, -- UI_Achievement_Alert_Start
        duration = 2.0,
        category = "achievement"
    },
    wowsounds_achievement_guild = {
        name = "WoW - Guild Achievement",
        soundKit = 12889, -- UI_Achievement_Guild_Alert_Start
        duration = 2.5,
        category = "achievement"
    },
    wowsounds_achievement_criteria = {
        name = "WoW - Achievement Progress",
        soundKit = 50029, -- UI_Achievement_Criteria_Earned
        duration = 1.5,
        category = "achievement"
    },
    
    -- Quest Sounds
    wowsounds_quest_complete = {
        name = "WoW - Quest Complete",
        soundKit = 618, -- QuestComplete
        duration = 1.5,
        category = "quest"
    },
    wowsounds_quest_objective = {
        name = "WoW - Quest Objective Complete",
        soundKit = 52241, -- UI_Quest_Objective_Complete
        duration = 1.0,
        category = "quest"
    },
    wowsounds_quest_turnin = {
        name = "WoW - Quest Turn In",
        soundKit = 876, -- igQuestListComplete
        duration = 1.5,
        category = "quest"
    },
    wowsounds_quest_special = {
        name = "WoW - Special Quest Complete",
        soundKit = 64625, -- UI_Quest_Special_Complete
        duration = 2.5,
        category = "quest"
    },
    
    -- Reputation Sounds
    wowsounds_reputation_levelup = {
        name = "WoW - Reputation Level Up",
        soundKit = 12198, -- UI_ReputationLevelUp
        duration = 2.0,
        category = "reputation"
    },
    wowsounds_reputation_paragon = {
        name = "WoW - Paragon Reputation",
        soundKit = 84548, -- UI_ReputationParagonNotification
        duration = 3.0,
        category = "reputation"
    },
    
    -- Honor/PvP Sounds
    wowsounds_honor_rankup = {
        name = "WoW - Honor Rank Up",
        soundKit = 8455, -- PVP Reward
        duration = 2.5,
        category = "honorrank"
    },
    wowsounds_honor_prestige = {
        name = "WoW - Prestige Level Up",
        soundKit = 47292, -- UI_HonorPrestige_LevelUp
        duration = 4.0,
        category = "honorrank"
    },
    wowsounds_honor_battleground = {
        name = "WoW - Battleground Victory",
        soundKit = 8454, -- PVPVictoryAlliance / PVPVictoryHorde
        duration = 3.0,
        category = "honorrank"
    },
    
    -- Renown Sounds
    wowsounds_renown_levelup = {
        name = "WoW - Renown Level Up",
        soundKit = 168610, -- UI_Renown_LevelUp
        duration = 3.0,
        category = "renownrank"
    },
    wowsounds_renown_milestone = {
        name = "WoW - Renown Milestone",
        soundKit = 168611, -- UI_Renown_Milestone
        duration = 3.5,
        category = "renownrank"
    },
    
    -- Trading Post Sounds
    wowsounds_tradingpost_complete = {
        name = "WoW - Trading Post Complete",
        soundKit = 179115, -- UI_Trading_Post_Reward_Fanfare
        duration = 2.5,
        category = "tradingpost"
    },
    wowsounds_tradingpost_progress = {
        name = "WoW - Trading Post Progress",
        soundKit = 179114, -- UI_Trading_Post_Progress
        duration = 1.5,
        category = "tradingpost"
    },
    
    -- Pet Battle Sounds
    wowsounds_battlepet_victory = {
        name = "WoW - Pet Battle Victory",
        soundKit = 65973, -- UI_PetBattle_Victory
        duration = 3.0,
        category = "battlepet"
    },
    wowsounds_battlepet_capture = {
        name = "WoW - Pet Captured",
        soundKit = 68609, -- UI_PetBattle_Capture
        duration = 2.5,
        category = "battlepet"
    },
    wowsounds_battlepet_levelup = {
        name = "WoW - Battle Pet Level Up",
        soundKit = 65972, -- UI_PetBattle_LevelUp
        duration = 2.0,
        category = "battlepet"
    },
    
    -- Delve/Special Sounds
    wowsounds_delve_complete = {
        name = "WoW - Delve Complete",
        soundKit = 182216, -- UI_Delve_Complete
        duration = 2.5,
        category = "delvecompanion"
    },
    wowsounds_delve_bonus = {
        name = "WoW - Bonus Objective Complete",
        soundKit = 52017, -- UI_BonusObjective_Complete
        duration = 2.0,
        category = "delvecompanion"
    },
    
    -- Additional Notable Sounds
    wowsounds_garrison_complete = {
        name = "WoW - Garrison Mission Complete",
        soundKit = 38326, -- UI_Garrison_Mission_Complete
        duration = 2.5,
        category = "quest"
    },
    wowsounds_island_complete = {
        name = "WoW - Island Expedition Complete",
        soundKit = 121436, -- UI_IslandExpedition_Complete
        duration = 3.0,
        category = "quest"
    },
    wowsounds_warfront_complete = {
        name = "WoW - Warfront Complete",
        soundKit = 107658, -- UI_Warfront_Complete
        duration = 3.5,
        category = "quest"
    },
    wowsounds_ready_check = {
        name = "WoW - Ready Check",
        soundKit = 8960, -- ReadyCheck
        duration = 1.5,
        category = "achievement"
    },
    wowsounds_raid_warning = {
        name = "WoW - Raid Warning",
        soundKit = 8959, -- RaidWarning
        duration = 1.0,
        category = "achievement"
    },
    wowsounds_auction_open = {
        name = "WoW - Auction House Bell",
        soundKit = 5274, -- AuctionWindowOpen
        duration = 1.0,
        category = "achievement"
    },
    wowsounds_mail_received = {
        name = "WoW - Mail Received",
        soundKit = 3338, -- igPlayerInviteDecline  
        duration = 1.0,
        category = "achievement"
    },
    
    -- More Level Up Sounds
    wowsounds_levelup_epic = {
        name = "WoW - Epic Victory",
        soundKit = 23426, -- UI_EpicLoot
        duration = 3.5,
        category = "levelup"
    },
    wowsounds_levelup_power = {
        name = "WoW - Power Up",
        soundKit = 10722, -- PowerUpMonoChrome
        duration = 2.0,
        category = "levelup"
    },
    
    -- More Achievement Sounds
    wowsounds_achievement_legendary = {
        name = "WoW - Legendary Alert",
        soundKit = 43848, -- UI_Legendary_Item_Toast
        duration = 4.0,
        category = "achievement"
    },
    wowsounds_achievement_epic = {
        name = "WoW - Epic Loot",
        soundKit = 23426, -- UI_EpicLoot_Toast
        duration = 3.0,
        category = "achievement"
    },
    wowsounds_achievement_rare = {
        name = "WoW - Rare Item",
        soundKit = 73277, -- UI_Garrison_Invasion_Alert
        duration = 2.5,
        category = "achievement"
    },
    
    -- More Quest Sounds
    wowsounds_quest_world = {
        name = "WoW - World Quest Complete",
        soundKit = 51402, -- UI_WorldQuest_Complete
        duration = 2.0,
        category = "quest"
    },
    wowsounds_quest_bonus = {
        name = "WoW - Bonus Objective",
        soundKit = 52017, -- UI_BonusObjective_Complete
        duration = 2.0,
        category = "quest"
    },
    wowsounds_quest_daily = {
        name = "WoW - Daily Quest Complete",
        soundKit = 64580, -- UI_Scenario_Stage_End
        duration = 2.5,
        category = "quest"
    },
    
    -- More Honor/PvP Sounds
    wowsounds_honor_arena = {
        name = "WoW - Arena Victory",
        soundKit = 34485, -- UI_Arena_Victory
        duration = 4.0,
        category = "honorrank"
    },
    wowsounds_honor_rbg = {
        name = "WoW - RBG Victory",
        soundKit = 23663, -- UI_70_PVP_Reward_Toast
        duration = 3.5,
        category = "honorrank"
    },
    
    -- More Pet Battle Sounds
    wowsounds_battlepet_rare = {
        name = "WoW - Rare Pet Captured",
        soundKit = 114572, -- UI_PetCapture_Toasts
        duration = 3.0,
        category = "battlepet"
    },
    wowsounds_battlepet_achievement = {
        name = "WoW - Pet Achievement",
        soundKit = 102275, -- UI_PetBattle_Achievement_Earned
        duration = 3.5,
        category = "battlepet"
    },
    
    -- Trading Post Variations
    wowsounds_tradingpost_unlock = {
        name = "WoW - Trading Post Unlock",
        soundKit = 179116, -- UI_Trading_Post_Unlock
        duration = 2.0,
        category = "tradingpost"
    },
    wowsounds_tradingpost_purchase = {
        name = "WoW - Trading Post Purchase",
        soundKit = 640336, -- Store_Purchase_Deliver
        duration = 2.5,
        category = "tradingpost"
    },
    
    -- Classic UI Sounds
    wowsounds_classic_ding = {
        name = "WoW - Classic Level Ding",
        soundKit = 888, -- gsTitleIntroMovie (classic fanfare)
        duration = 3.0,
        category = "levelup"
    },
    wowsounds_classic_complete = {
        name = "WoW - Classic Quest Complete",
        soundKit = 878, -- igQuestListComplete
        duration = 1.5,
        category = "quest"
    }
}

-- Initialize function
function WoWSounds:Init()
    -- Register sounds with the main addon
    for soundId, soundData in pairs(self.sounds) do
        -- Create registration data for soundKit
        local registrationData = {
            name = soundData.name,
            soundKit = soundData.soundKit,
            duration = soundData.duration,
            category = soundData.category,
            pack = "wowsounds"
        }
        
        -- Register with BLU
        if BLU.RegisterSound then
            BLU:RegisterSound(soundId, registrationData)
        end
    end
    
    BLU:PrintDebug("WoW Sounds pack loaded with " .. self:GetSoundCount() .. " sounds")
end

-- Get sound count
function WoWSounds:GetSoundCount()
    local count = 0
    for _ in pairs(self.sounds) do
        count = count + 1
    end
    return count
end

-- Register the sound pack
if BLU.RegisterSoundPack then
    BLU:RegisterSoundPack("wowsounds", WoWSounds)
end

return WoWSounds