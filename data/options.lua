--=====================================================================================
-- BLU Options Module
-- Handles the options panel UI
--=====================================================================================

local addonName, addonTable = ...
local Options = {}

-- Libraries
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

-- Initialize options module
function Options:Init()
    self:CreateOptionsTable()
    self:RegisterOptions()
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Options"))
end

-- Create the options table structure
function Options:CreateOptionsTable()
    self.optionsTable = {
        name = BLU:Loc("OPTIONS_TITLE"),
        type = "group",
        childGroups = "tree",
        args = {
            general = self:CreateGeneralOptions(),
            sounds = self:CreateSoundOptions(),
            modules = self:CreateModuleOptions(),
            profiles = self:CreateProfileOptions()
        }
    }
end

-- General options
function Options:CreateGeneralOptions()
    return {
        name = BLU:Loc("GENERAL_OPTIONS"),
        type = "group",
        order = 1,
        args = {
            header = {
                type = "header",
                name = BLU:Loc("GENERAL_OPTIONS"),
                order = 1
            },
            showWelcomeMessage = {
                type = "toggle",
                name = BLU:Loc("SHOW_WELCOME_MESSAGE"),
                desc = BLU:Loc("SHOW_WELCOME_MESSAGE_DESC"),
                get = function() return BLU.db.profile.showWelcomeMessage end,
                set = function(_, val) BLU.db.profile.showWelcomeMessage = val end,
                order = 2
            },
            debugMode = {
                type = "toggle",
                name = BLU:Loc("DEBUG_MODE"),
                desc = BLU:Loc("DEBUG_MODE_DESC"),
                get = function() return BLU.db.profile.debugMode end,
                set = function(_, val) 
                    BLU.db.profile.debugMode = val
                    BLU.debugMode = val
                end,
                order = 3
            },
            spacer1 = {
                type = "description",
                name = "\n",
                order = 4
            },
            masterVolume = {
                type = "range",
                name = BLU:Loc("MASTER_VOLUME"),
                desc = BLU:Loc("MASTER_VOLUME_DESC"),
                min = 0,
                max = 1,
                step = 0.05,
                isPercent = true,
                get = function() return BLU.db.profile.masterVolume end,
                set = function(_, val) BLU.db.profile.masterVolume = val end,
                order = 5
            },
            soundChannel = {
                type = "select",
                name = BLU:Loc("SOUND_CHANNEL"),
                desc = BLU:Loc("SOUND_CHANNEL_DESC"),
                values = {
                    ["Master"] = "Master",
                    ["SFX"] = "Sound Effects",
                    ["Music"] = "Music",
                    ["Ambience"] = "Ambience",
                    ["Dialog"] = "Dialog"
                },
                get = function() return BLU.db.profile.soundChannel end,
                set = function(_, val) BLU.db.profile.soundChannel = val end,
                order = 6
            }
        }
    }
end

-- Sound options
function Options:CreateSoundOptions()
    return {
        name = BLU:Loc("SOUND_OPTIONS"),
        type = "group",
        order = 2,
        args = {
            levelUp = self:CreateSoundOptionGroup("levelUp", BLU:Loc("LEVEL_UP"), 1),
            achievement = self:CreateSoundOptionGroup("achievement", BLU:Loc("ACHIEVEMENT_EARNED"), 2),
            reputation = self:CreateSoundOptionGroup("reputation", BLU:Loc("REPUTATION_INCREASED"), 3),
            questAccept = self:CreateSoundOptionGroup("questAccept", BLU:Loc("QUEST_ACCEPTED"), 4),
            questTurnIn = self:CreateSoundOptionGroup("questTurnIn", BLU:Loc("QUEST_COMPLETED"), 5),
            battlePet = self:CreateSoundOptionGroup("battlePet", BLU:Loc("BATTLE_PET_LEVEL"), 6),
            delveCompanion = self:CreateSoundOptionGroup("delveCompanion", BLU:Loc("DELVE_COMPANION"), 7),
            honorRank = self:CreateSoundOptionGroup("honorRank", BLU:Loc("HONOR_RANK"), 8),
            renownRank = self:CreateSoundOptionGroup("renownRank", BLU:Loc("RENOWN_RANK"), 9),
            tradingPost = self:CreateSoundOptionGroup("tradingPost", BLU:Loc("TRADING_POST"), 10)
        }
    }
end

-- Create individual sound option group
function Options:CreateSoundOptionGroup(key, name, order)
    local soundKey = key .. "Sound"
    local volumeKey = key .. "Volume"
    
    return {
        name = name,
        type = "group",
        order = order,
        args = {
            sound = {
                type = "select",
                name = BLU:Loc("SOUND_SELECTION"),
                desc = string.format(BLU:Loc("SOUND_SELECTION_DESC"), name),
                values = function() return self:GetSoundList(key) end,
                get = function() return BLU.db.profile[soundKey] end,
                set = function(_, val) BLU.db.profile[soundKey] = val end,
                order = 1,
                width = "full"
            },
            volume = {
                type = "range",
                name = BLU:Loc("VOLUME"),
                desc = string.format(BLU:Loc("VOLUME_DESC"), name),
                min = 0,
                max = 1,
                step = 0.05,
                isPercent = true,
                get = function() return BLU.db.profile[volumeKey] end,
                set = function(_, val) BLU.db.profile[volumeKey] = val end,
                order = 2
            },
            test = {
                type = "execute",
                name = BLU:Loc("TEST_SOUND"),
                desc = BLU:Loc("TEST_SOUND_DESC"),
                func = function() self:TestSound(soundKey, volumeKey) end,
                order = 3
            }
        }
    }
end

-- Module options
function Options:CreateModuleOptions()
    return {
        name = BLU:Loc("MODULE_OPTIONS"),
        type = "group",
        order = 3,
        args = {
            header = {
                type = "header",
                name = BLU:Loc("MODULE_OPTIONS"),
                order = 1
            },
            enableLevelUp = self:CreateModuleToggle("LevelUp", 2),
            enableAchievement = self:CreateModuleToggle("Achievement", 3),
            enableReputation = self:CreateModuleToggle("Reputation", 4),
            enableQuest = self:CreateModuleToggle("Quest", 5),
            enableBattlePet = self:CreateModuleToggle("BattlePet", 6),
            enableDelveCompanion = self:CreateModuleToggle("DelveCompanion", 7),
            enableHonorRank = self:CreateModuleToggle("HonorRank", 8),
            enableRenownRank = self:CreateModuleToggle("RenownRank", 9),
            enableTradingPost = self:CreateModuleToggle("TradingPost", 10)
        }
    }
end

-- Create module toggle
function Options:CreateModuleToggle(module, order)
    local key = "enable" .. module
    local name = BLU:Loc(module:upper())
    
    return {
        type = "toggle",
        name = string.format(BLU:Loc("ENABLE_MODULE"), name),
        desc = string.format(BLU:Loc("ENABLE_MODULE_DESC"), name),
        get = function() return BLU.db.profile[key] end,
        set = function(_, val) 
            BLU.db.profile[key] = val
            BLU:UpdateModuleLoading(module:sub(1,1):lower() .. module:sub(2), val)
        end,
        order = order
    }
end

-- Profile options
function Options:CreateProfileOptions()
    if not BLU.db then return {} end
    
    local profiles = AceDBOptions:GetOptionsTable(BLU.db)
    profiles.order = 4
    
    return profiles
end

-- Get sound list for dropdown
function Options:GetSoundList(category)
    local sounds = {
        ["None"] = BLU:Loc("SOUND_NONE")
    }
    
    -- Add all registered sounds
    for soundId, soundData in pairs(BLU.soundRegistry or {}) do
        if not soundData.category or soundData.category == category or soundData.category == "all" then
            sounds[soundId] = soundData.name
        end
    end
    
    return sounds
end

-- Test sound
function Options:TestSound(soundKey, volumeKey)
    local soundId = BLU.db.profile[soundKey]
    local volume = BLU.db.profile[volumeKey] * BLU.db.profile.masterVolume
    
    if soundId and soundId ~= "None" then
        BLU:PlaySound(soundId, volume)
    end
end

-- Register options
function Options:RegisterOptions()
    AceConfig:RegisterOptionsTable("BLU", self.optionsTable)
    
    -- Add to Blizzard options
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("BLU", "BLU")
    
    -- Register slash command
    AceConfig:RegisterOptionsTable("BLU_CMD", self.optionsTable, {"blu"})
end

-- Open options panel
function Options:Open()
    AceConfigDialog:Open("BLU")
end

-- Export module
return Options