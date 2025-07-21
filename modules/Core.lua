--=====================================================================================
-- BLU Core Module
-- Essential functionality that is always loaded
--=====================================================================================

local addonName, addonTable = ...
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

-- Core addon info
BLU.VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")
BLU.Author = C_AddOns.GetAddOnMetadata("BLU", "Author")

-- Core variables
BLU.functionsHalted = false
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.isInitialized = false

-- Libraries
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Initialize the addon
function BLU:OnInitialize()
    -- Load saved variables
    self.db = AceDB:New("BLUDB", self:GetDefaults(), true)
    
    -- Register slash commands
    self:RegisterChatCommand("blu", "SlashCommand")
    
    -- Set up options
    self:SetupOptions()
    
    -- Initialize sound registry
    self.soundRegistry = {}
    
    -- Load core modules
    self:LoadCoreModules()
    
    -- Load modules based on settings
    self:LoadModulesFromSettings()
    
    self.isInitialized = true
end

-- Called when addon is enabled
function BLU:OnEnable()
    if self.showWelcomeMessage and self.db.profile.showWelcomeMessage then
        self:Print(string.format("|cff05dffaBLU v%s|r loaded. Type |cff05dffa/blu|r for options.", self.VersionNumber))
    end
end

-- Called when addon is disabled
function BLU:OnDisable()
    -- Cleanup modules
    for moduleName, module in pairs(self.LoadedModules or {}) do
        self:UnloadModule(moduleName)
    end
end

-- Slash command handler
function BLU:SlashCommand(input)
    if not input or input:trim() == "" then
        self:OpenOptions()
    else
        local command = input:match("^(%S*)%s*(.-)$")
        command = command:lower()
        
        if command == "debug" then
            self.debugMode = not self.debugMode
            self:Print("Debug mode " .. (self.debugMode and "enabled" or "disabled"))
        elseif command == "reset" then
            self.db:ResetProfile()
            self:Print("Settings reset to defaults")
            ReloadUI()
        elseif command == "reload" then
            self:Print("Reloading modules...")
            self:ReloadAllModules()
        else
            self:Print("Unknown command. Use |cff05dffa/blu|r to open options.")
        end
    end
end

-- Open options panel
function BLU:OpenOptions()
    ACD:Open("BLU")
end

-- Get default settings
function BLU:GetDefaults()
    return {
        profile = {
            -- General settings
            showWelcomeMessage = true,
            masterVolume = 0.5,
            
            -- Feature toggles
            enableLevelUp = true,
            enableAchievement = true,
            enableReputation = true,
            enableQuest = true,
            enableBattlePet = true,
            enableDelveCompanion = true,
            enableHonorRank = true,
            enableRenownRank = true,
            enableTradingPost = true,
            
            -- Sound selections
            levelUpSound = "finalfantasy_victory",
            achievementSound = "zelda_secret",
            reputationSound = "warcraft_questcomplete",
            questAcceptSound = "skyrim_queststart",
            questTurnInSound = "skyrim_questcomplete",
            battlePetSound = "pokemon_levelup",
            delveCompanionSound = "finalfantasy_victory",
            honorRankSound = "warcraft_pvpvictory",
            renownRankSound = "warcraft_reputation",
            tradingPostSound = "mario_coin",
            
            -- Volume settings
            levelUpVolume = 1.0,
            achievementVolume = 1.0,
            reputationVolume = 1.0,
            questVolume = 1.0,
            battlePetVolume = 1.0,
            delveCompanionVolume = 1.0,
            honorRankVolume = 1.0,
            renownRankVolume = 1.0,
            tradingPostVolume = 1.0
        }
    }
end

-- Reload all modules
function BLU:ReloadAllModules()
    -- Unload all feature modules
    for moduleName in pairs(self.LoadedModules or {}) do
        self:UnloadModule(moduleName)
    end
    
    -- Reload based on current settings
    self:LoadModulesFromSettings()
    
    self:Print("Modules reloaded successfully")
end

-- Sound registration API
function BLU:RegisterSound(soundId, soundData)
    self.soundRegistry[soundId] = soundData
    self:PrintDebug("Registered sound: " .. soundId)
end

function BLU:UnregisterSound(soundId)
    self.soundRegistry[soundId] = nil
end

function BLU:GetSound(soundId)
    return self.soundRegistry[soundId]
end

function BLU:PlaySound(soundId, volume)
    local sound = self.soundRegistry[soundId]
    if not sound then
        self:PrintDebug("Sound not found: " .. soundId)
        return
    end
    
    volume = volume or 1.0
    PlaySoundFile(sound.file, "Master")
end

-- Load core modules
function BLU:LoadCoreModules()
    -- These modules are always loaded
    local coreModules = {"SoundPakBridge", "GameSoundBrowser"}
    
    for _, moduleName in ipairs(coreModules) do
        self:LoadModule("core", moduleName)
    end
end

-- Export core module
return BLU