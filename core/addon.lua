--=====================================================================================
-- BLU - core/addon.lua
-- Main addon initialization and core functions
--=====================================================================================

local addonName, BLU = ...

-- Constants
local ADDON_NAME = "Better Level-Up!"
local ADDON_SHORT = "BLU"
local ADDON_PREFIX = "|cff05dffaBLU|r"
local ADDON_ICON = "|TInterface\\AddOns\\BLU\\media\\images\\icon:0|t"
local DISCORD_LINK = "discord.gg/rgxmods"

-- Store constants
BLU.ADDON_NAME = ADDON_NAME
BLU.ADDON_SHORT = ADDON_SHORT
BLU.ADDON_PREFIX = ADDON_PREFIX
BLU.ADDON_ICON = ADDON_ICON

-- Default settings
local DEFAULTS = {
    profile = {
        -- General
        enabled = true,
        showWelcomeMessage = true,
        debugMode = false,
        
        -- Sounds
        soundVolume = 100,
        soundChannel = "Master",
        
        -- Features
        modules = {
            levelup = true,
            achievement = true,
            quest = true,
            reputation = true,
            honorrank = true,
            renownrank = true,
            tradingpost = true,
            battlepet = true,
            delvecompanion = true
        },
        
        -- Sound selections
        selectedSounds = {}
    }
}

-- Load settings
function BLU:LoadSettings()
    BLUDB = BLUDB or {}
    BLUDB.profile = BLUDB.profile or {}
    
    -- Merge defaults
    for key, value in pairs(DEFAULTS.profile) do
        if BLUDB.profile[key] == nil then
            BLUDB.profile[key] = value
        end
    end
    
    -- Handle nested tables
    BLUDB.profile.modules = BLUDB.profile.modules or {}
    for key, value in pairs(DEFAULTS.profile.modules) do
        if BLUDB.profile.modules[key] == nil then
            BLUDB.profile.modules[key] = value
        end
    end
    
    BLUDB.profile.selectedSounds = BLUDB.profile.selectedSounds or {}
    
    -- Set reference
    BLU.db = BLUDB
end

-- Save settings
function BLU:SaveSettings()
    -- WoW handles this automatically
end

-- Print message
function BLU:Print(message)
    if message then
        print(format("%s %s %s", ADDON_ICON, ADDON_PREFIX, message))
    end
end

-- Debug print
function BLU:PrintDebug(message)
    -- Always print during development
    self:Print("|cff00ff00Debug:|r " .. message)
end

-- Enable addon
function BLU:Enable()
    self.db.profile.enabled = true
    self:Print("Enabled")
end

-- Disable addon
function BLU:Disable()
    self.db.profile.enabled = false
    self:Print("Disabled")
end