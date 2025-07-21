--=====================================================================================
-- BLU Game Sound Browser Module
-- Provides access to in-game WoW sound files
--=====================================================================================

local addonName, addonTable = ...
local GameSoundBrowser = {}

-- Sound categories from WoW game files
GameSoundBrowser.categories = {
    -- Interface sounds
    interface = {
        name = "Interface Sounds",
        sounds = {
            ["Sound\\Interface\\LevelUp.ogg"] = "Level Up",
            ["Sound\\Interface\\QuestActivate.ogg"] = "Quest Accept",
            ["Sound\\Interface\\QuestComplete.ogg"] = "Quest Complete",
            ["Sound\\Interface\\AchievementSound.ogg"] = "Achievement",
            ["Sound\\Interface\\RaidWarning.ogg"] = "Raid Warning",
            ["Sound\\Interface\\ReadyCheck.ogg"] = "Ready Check",
            ["Sound\\Interface\\PvPFlagTaken.ogg"] = "PvP Flag Taken",
            ["Sound\\Interface\\PvPVictory.ogg"] = "PvP Victory",
            ["Sound\\Interface\\ItemRepair.ogg"] = "Item Repair",
            ["Sound\\Interface\\GuildBankOpen.ogg"] = "Guild Bank Open",
            ["Sound\\Interface\\MapPing.ogg"] = "Map Ping",
            ["Sound\\Interface\\FriendJoin.ogg"] = "Friend Online"
        }
    },
    
    -- Spell sounds
    spells = {
        name = "Spell Sounds",
        sounds = {
            ["Sound\\Spells\\LevelUp.ogg"] = "Spell Level Up",
            ["Sound\\Spells\\Achievement_Reward.ogg"] = "Achievement Reward",
            ["Sound\\Spells\\GainExperience.ogg"] = "Gain Experience",
            ["Sound\\Spells\\Tradeskills\\LevelUp.ogg"] = "Profession Level Up",
            ["Sound\\Spells\\Valentine_Achievement.ogg"] = "Special Achievement",
            ["Sound\\Spells\\Achievement_Boss_Kill.ogg"] = "Boss Kill",
            ["Sound\\Spells\\PvP_Alliance_Wins.ogg"] = "Alliance Victory",
            ["Sound\\Spells\\PvP_Horde_Wins.ogg"] = "Horde Victory"
        }
    },
    
    -- Creature sounds
    creatures = {
        name = "Creature Sounds",
        sounds = {
            ["Sound\\Creature\\Blingtron5000\\VO_60_Blingtron_5000_01.ogg"] = "Blingtron Hello",
            ["Sound\\Creature\\HeadlessHorseman\\Horseman_Laugh_01.ogg"] = "Headless Horseman Laugh",
            ["Sound\\Creature\\Illidan\\BLACK_Illidan_04.ogg"] = "You Are Not Prepared",
            ["Sound\\Creature\\Peon\\PeonYes1.ogg"] = "Work Work",
            ["Sound\\Creature\\Murloc\\MurlocAggro.ogg"] = "Murloc Aggro"
        }
    },
    
    -- Music stingers
    music = {
        name = "Music Stingers",
        sounds = {
            ["Sound\\Music\\Events\\Event_DalaranKarazhan.ogg"] = "Dalaran Kharazan",
            ["Sound\\Music\\Events\\Event_DeathKnightStart.ogg"] = "Death Knight Start",
            ["Sound\\Music\\Events\\Event_DemonHunterStart.ogg"] = "Demon Hunter Start",
            ["Sound\\Music\\Events\\Event_GarrisonAlliance.ogg"] = "Garrison Alliance",
            ["Sound\\Music\\Events\\Event_GarrisonHorde.ogg"] = "Garrison Horde",
            ["Sound\\Music\\Events\\Event_Tournament.ogg"] = "Tournament Fanfare"
        }
    },
    
    -- Zone music
    zones = {
        name = "Zone Music",
        sounds = {
            ["Sound\\Music\\Zone\\Stormwind\\Stormwind01.ogg"] = "Stormwind Theme",
            ["Sound\\Music\\Zone\\Orgrimmar\\Orgrimmar01.ogg"] = "Orgrimmar Theme",
            ["Sound\\Music\\Zone\\IronForge\\IronForge01.ogg"] = "Ironforge Theme",
            ["Sound\\Music\\Zone\\Dalaran\\Dalaran01.ogg"] = "Dalaran Theme",
            ["Sound\\Music\\Zone\\Elwynn\\ElwynnForest01.ogg"] = "Elwynn Forest"
        }
    }
}

-- Popular sounds for quick access
GameSoundBrowser.popularSounds = {
    {id = "game_levelup", path = "Sound\\Interface\\LevelUp.ogg", name = "WoW - Level Up"},
    {id = "game_achievement", path = "Sound\\Interface\\AchievementSound.ogg", name = "WoW - Achievement"},
    {id = "game_questcomplete", path = "Sound\\Interface\\QuestComplete.ogg", name = "WoW - Quest Complete"},
    {id = "game_pvpvictory", path = "Sound\\Interface\\PvPVictory.ogg", name = "WoW - PvP Victory"},
    {id = "game_readycheck", path = "Sound\\Interface\\ReadyCheck.ogg", name = "WoW - Ready Check"},
    {id = "game_raidwarning", path = "Sound\\Interface\\RaidWarning.ogg", name = "WoW - Raid Warning"},
    {id = "game_murloc", path = "Sound\\Creature\\Murloc\\MurlocAggro.ogg", name = "WoW - Murloc"},
    {id = "game_notprepared", path = "Sound\\Creature\\Illidan\\BLACK_Illidan_04.ogg", name = "WoW - Not Prepared"}
}

-- Initialize game sound browser
function GameSoundBrowser:Init()
    -- Register popular sounds with BLU
    for _, sound in ipairs(self.popularSounds) do
        local soundData = {
            name = sound.name,
            file = sound.path,
            duration = 2.0,
            category = "game",
            source = "wow"
        }
        BLU:RegisterSound(sound.id, soundData)
    end
    
    BLU:PrintDebug("Game Sound Browser initialized with " .. #self.popularSounds .. " popular sounds")
end

-- Search for game sounds
function GameSoundBrowser:SearchSounds(query)
    local results = {}
    query = query:lower()
    
    for categoryId, category in pairs(self.categories) do
        for path, name in pairs(category.sounds) do
            if name:lower():find(query) or path:lower():find(query) then
                table.insert(results, {
                    path = path,
                    name = name,
                    category = category.name
                })
            end
        end
    end
    
    return results
end

-- Get all sounds in a category
function GameSoundBrowser:GetCategorySounds(categoryId)
    local category = self.categories[categoryId]
    if not category then return {} end
    
    local sounds = {}
    for path, name in pairs(category.sounds) do
        table.insert(sounds, {
            path = path,
            name = name,
            category = category.name
        })
    end
    
    return sounds
end

-- Register a game sound with BLU
function GameSoundBrowser:RegisterGameSound(soundPath, soundName)
    local soundId = "game_custom_" .. soundName:lower():gsub("%s+", "_")
    
    local soundData = {
        name = "WoW - " .. soundName,
        file = soundPath,
        duration = 2.0,
        category = "game",
        source = "wow"
    }
    
    BLU:RegisterSound(soundId, soundData)
    
    return soundId
end

-- Play preview of game sound
function GameSoundBrowser:PreviewSound(soundPath)
    PlaySoundFile(soundPath, "Master")
end

-- Get sound file ID from path (for newer API)
function GameSoundBrowser:GetSoundKitID(soundPath)
    -- This would need a lookup table of sound paths to sound kit IDs
    -- For now, we'll use PlaySoundFile which works with paths
    return nil
end

-- Create browser UI frame
function GameSoundBrowser:CreateBrowserFrame()
    -- This would create a browsable UI for selecting game sounds
    -- Implementation would include:
    -- - Category dropdown
    -- - Search box
    -- - Sound list with preview buttons
    -- - Add to BLU button
end

-- Export module
return GameSoundBrowser