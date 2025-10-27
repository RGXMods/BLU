--=====================================================================================
-- BLU | Localization - English (US)
-- Author: donniedice
-- Description: English localization strings
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

-- Initialize localization table
BLU.L = BLU.L or {}
local L = BLU.L

-- Localization function with fallback
function BLU:Loc(key, ...)
    local str = L[key] or key
    if select("#", ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

-- General strings
L["ADDON_LOADED"] = "BLU loaded successfully. Type /blu for options."
L["ADDON_NAME"] = "Better Level-Up!"
L["VERSION"] = "Version"

-- Command strings
L["CMD_HELP"] = "Shows this help message"
L["CMD_OPTIONS"] = "Opens the options panel"
L["CMD_TEST"] = "Plays a test sound"
L["CMD_RELOAD"] = "Reloads the addon"
L["CMD_DEBUG"] = "Toggles debug mode"
L["CMD_VERSION"] = "Shows addon version"

-- Settings panel strings
L["SETTINGS_TITLE"] = "BLU Settings"
L["GENERAL_TAB"] = "General"
L["SOUNDS_TAB"] = "Sounds"
L["MODULES_TAB"] = "Modules"
L["PROFILES_TAB"] = "Profiles"
L["ADVANCED_TAB"] = "Advanced"
L["ABOUT_TAB"] = "About"

-- General panel
L["ENABLE_ADDON"] = "Enable BLU Sound System"
L["MASTER_VOLUME"] = "Master Volume"
L["VOLUME_SETTINGS"] = "Volume Settings"
L["QUICK_SETTINGS"] = "Quick Settings"
L["PLAY_IN_BACKGROUND"] = "Play sounds when game is in background"
L["RANDOM_VARIATIONS"] = "Enable random sound variations"
L["DEBUG_MODE"] = "Enable debug messages"
L["PERFORMANCE"] = "Performance"
L["PRELOAD_SOUNDS"] = "Preload sounds on startup (uses more memory)"
L["SOUND_CACHE_SIZE"] = "Sound cache size:"
L["TEST_BUTTON"] = "Test"

-- Sounds panel
L["SOUND_CONFIGURATION"] = "Sound Configuration"
L["EVENT_SOUNDS"] = "Event Sounds"
L["SOUND_BROWSER"] = "Sound Browser"
L["SEARCH"] = "Search:"
L["ALL_CATEGORIES"] = "All Categories"
L["DEFAULT_SOUND"] = "Default"
L["ENABLE"] = "Enable"

-- Event types
L["EVENT_LEVELUP"] = "Level Up"
L["EVENT_ACHIEVEMENT"] = "Achievement"
L["EVENT_QUEST"] = "Quest Complete"
L["EVENT_REPUTATION"] = "Reputation"
L["EVENT_HONOR"] = "Honor Gain"
L["EVENT_BATTLEPET"] = "Pet Level"
L["EVENT_RENOWN"] = "Renown"
L["EVENT_TRADINGPOST"] = "Trading Post"
L["EVENT_DELVE"] = "Delve Complete"

-- Modules panel
L["MODULE_MANAGEMENT"] = "Module Management"
L["TOTAL_MEMORY"] = "Total Memory Usage: %s"
L["ENABLE_ALL"] = "Enable All"
L["DISABLE_ALL"] = "Disable All"
L["RELOAD_MODULES"] = "Reload Modules"
L["MODULE_ENABLED"] = "Enabled"
L["MODULE_NAME"] = "Module"
L["MODULE_MEMORY"] = "Memory"
L["MODULE_STATUS"] = "Status"
L["MODULE_LOAD_ORDER"] = "Load Order"
L["MODULE_CONFIG"] = "Config"
L["MODULE_ACTIVE"] = "|cff00ff00Active|r"
L["MODULE_DISABLED"] = "|cffff0000Disabled|r"

-- Profiles panel
L["PROFILE_MANAGEMENT"] = "Profile Management"
L["CURRENT_PROFILE"] = "Current Profile"
L["SAVE_PROFILE"] = "Save"
L["NEW_PROFILE"] = "New"
L["DELETE_PROFILE"] = "Delete"
L["RENAME_PROFILE"] = "Rename"
L["PROFILE_PRESETS"] = "Profile Presets"
L["LOAD_PRESET"] = "Load Preset"
L["IMPORT_EXPORT"] = "Import / Export"
L["EXPORT_PROFILE"] = "Export Profile"
L["IMPORT_PROFILE"] = "Import Profile"
L["COPY_FROM_CHARACTER"] = "Copy from Character"
L["SHOW_PROFILE_DIFF"] = "Show profile differences when switching"
L["AUTO_SAVE_PROFILE"] = "Auto-save profile changes"

-- Advanced panel
L["ADVANCED_SETTINGS"] = "Advanced Settings"
L["WARNING_ADVANCED"] = "Warning: These settings are for advanced users"
L["SOUND_ENGINE"] = "Sound Engine"
L["MODULE_SYSTEM"] = "Module System"
L["DEBUGGING"] = "Debugging"
L["EXPERIMENTAL_FEATURES"] = "Experimental Features"
L["INTEGRATION"] = "Integration"
L["MAINTENANCE"] = "Maintenance"
L["CLEAR_CACHE"] = "Clear Sound Cache"
L["RESET_ADVANCED"] = "Reset Advanced Settings"
L["REBUILD_DATABASE"] = "Rebuild Database"

-- About panel
L["FEATURES"] = "Features"
L["CREDITS"] = "Credits"
L["SUPPORT_LINKS"] = "Support & Links"
L["ADDON_STATISTICS"] = "Addon Statistics"
L["MEMORY_USAGE"] = "Memory: %.2f MB"
L["MODULES_COUNT"] = "Modules: %d"
L["SOUNDS_COUNT"] = "Sounds: %d+"
L["LOAD_TIME"] = "Load Time: %s sec"
L["EVENTS_REGISTERED"] = "Events Registered: %d"

-- Messages
L["SETTINGS_SAVED"] = "Settings saved!"
L["PROFILE_SAVED"] = "Profile saved: %s"
L["PROFILE_LOADED"] = "Loaded profile: %s"
L["PROFILE_CREATED"] = "Created new profile: %s"
L["PROFILE_DELETED"] = "Deleted profile: %s"
L["PROFILE_RENAMED"] = "Renamed profile: %s to %s"
L["PROFILE_IMPORTED"] = "Profile imported as: %s"
L["CANNOT_DELETE_DEFAULT"] = "Cannot delete Default profile"
L["CANNOT_RENAME_DEFAULT"] = "Cannot rename Default profile"
L["INVALID_PROFILE_DATA"] = "Invalid profile data"
L["ALL_MODULES_ENABLED"] = "All modules enabled"
L["ALL_MODULES_DISABLED"] = "All modules disabled"
L["MODULES_RELOADED"] = "Modules reloaded"
L["CACHE_CLEARED"] = "Sound cache cleared"
L["DATABASE_REBUILT"] = "Database rebuilt"
L["SETTINGS_RESET"] = "Advanced settings reset to defaults"
L["TEST_MODE_ENABLED"] = "Test mode enabled - Click sounds to preview"
L["TEST_MODE_DISABLED"] = "Test mode disabled"
L["OPENING_CONFIG"] = "Opening config for %s"

-- Errors
L["ERROR_SOUND_NOT_FOUND"] = "Sound not found: %s"
L["ERROR_MODULE_LOAD_FAILED"] = "Failed to load module: %s"
L["ERROR_PROFILE_NOT_FOUND"] = "Profile '%s' not found, switching to Default"
L["ERROR_EVENT_CALLBACK"] = "Error in event %s for %s: %s"
L["ERROR_TIMER_CALLBACK"] = "Error in timer callback: %s"
L["ERROR_HOOK_CALLBACK"] = "Error in hook %s: %s"

-- Module initialization
local Localization = {}
function Localization:Init()
    BLU:PrintDebug("Localization module initialized")
end

-- Register the module
BLU.Modules = BLU.Modules or {}
BLU.Modules["localization"] = Localization
L["ERROR_OPTIONS_PANEL"] = "Cannot register options panel - unsupported WoW version"

-- Debug messages
L["DEBUG_MODULE_LOADED"] = "Module loaded: %s"
L["DEBUG_MODULE_UNLOADED"] = "Module unloaded: %s"
L["DEBUG_EVENT_REGISTERED"] = "Event registered: %s"
L["DEBUG_EVENT_UNREGISTERED"] = "Event unregistered: %s"
L["DEBUG_SOUND_PLAYING"] = "Playing sound: %s (volume: %.2f)"
L["DEBUG_PROFILE_CHANGED"] = "Profile changed to: %s"
L["DEBUG_COMBAT_ENTERED"] = "Entered combat - UI operations queued"
L["DEBUG_COMBAT_LEFT"] = "Left combat - processing queued operations"
L["DEBUG_OPERATION_QUEUED"] = "Operation queued for after combat"
L["DEBUG_TIMER_EXPIRED"] = "Removed expired combat queue operation"
