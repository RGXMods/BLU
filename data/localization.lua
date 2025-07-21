--=====================================================================================
-- BLU Localization Module
-- Handles multi-language support
--=====================================================================================

local addonName, addonTable = ...
local Localization = {}

-- Get current locale
local locale = GetLocale()

-- Localization table
Localization.L = {}

-- Default strings (English)
local enUS = {
    -- Addon info
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s loaded. Type /blu for options.",
    
    -- Commands
    ["SLASH_HELP"] = "Available commands:",
    ["SLASH_DEBUG"] = "Toggle debug mode",
    ["SLASH_RESET"] = "Reset settings to defaults",
    ["SLASH_RELOAD"] = "Reload modules",
    ["SLASH_UNKNOWN"] = "Unknown command. Use /blu to open options.",
    
    -- Debug messages
    ["DEBUG_ENABLED"] = "Debug mode enabled",
    ["DEBUG_DISABLED"] = "Debug mode disabled",
    ["MODULE_LOADED"] = "%s module loaded",
    ["MODULE_FAILED"] = "Failed to load %s module",
    
    -- Features
    ["LEVEL_UP"] = "Level Up!",
    ["ACHIEVEMENT_EARNED"] = "Achievement Earned!",
    ["REPUTATION_INCREASED"] = "Reputation Increased!",
    ["QUEST_ACCEPTED"] = "Quest Accepted!",
    ["QUEST_COMPLETED"] = "Quest Completed!",
    ["BATTLE_PET_LEVEL"] = "Battle Pet Level Up!",
    ["DELVE_COMPANION"] = "Delve Companion Level Up!",
    ["HONOR_RANK"] = "Honor Rank Up!",
    ["RENOWN_RANK"] = "Renown Increased!",
    ["TRADING_POST"] = "Trading Post Activity!",
    
    -- Options
    ["OPTIONS_TITLE"] = "BLU Options",
    ["GENERAL_OPTIONS"] = "General",
    ["SOUND_OPTIONS"] = "Sounds",
    ["MODULE_OPTIONS"] = "Modules",
    ["PROFILES"] = "Profiles",
    
    -- General options
    ["ENABLE"] = "Enable",
    ["DISABLE"] = "Disable",
    ["VOLUME"] = "Volume",
    ["MASTER_VOLUME"] = "Master Volume",
    ["TEST_SOUND"] = "Test Sound",
    ["SOUND_CHANNEL"] = "Sound Channel",
    
    -- Module options
    ["MODULE_ENABLED"] = "%s module enabled",
    ["MODULE_DISABLED"] = "%s module disabled",
    ["ENABLE_MODULE"] = "Enable %s",
    ["MODULE_SETTINGS"] = "%s Settings",
    
    -- Sound selection
    ["SOUND_NONE"] = "None",
    ["SOUND_CUSTOM"] = "Custom",
    ["SOUND_PACK"] = "Sound Pack: %s",
    ["GAME_SOUND"] = "Game: %s",
    
    -- Errors
    ["ERROR_SOUND_NOT_FOUND"] = "Sound not found: %s",
    ["ERROR_MODULE_NOT_FOUND"] = "Module not found: %s",
    ["ERROR_INVALID_VOLUME"] = "Invalid volume: %s",
    
    -- Module messages
    ["MODULE_LOADED"] = "%s module loaded",
    ["MODULE_CLEANED_UP"] = "%s module cleaned up",
    ["SOUND_REGISTERED"] = "Registered sound: %s",
    ["UNKNOWN"] = "Unknown",
    ["SETTINGS_RESET"] = "Settings reset to defaults",
    ["RELOADING_MODULES"] = "Reloading modules...",
    
    -- Reputation ranks
    ["REP_HATED"] = "Hated",
    ["REP_HOSTILE"] = "Hostile",
    ["REP_UNFRIENDLY"] = "Unfriendly",
    ["REP_NEUTRAL"] = "Neutral",
    ["REP_FRIENDLY"] = "Friendly",
    ["REP_HONORED"] = "Honored",
    ["REP_REVERED"] = "Revered",
    ["REP_EXALTED"] = "Exalted",
}

-- German
local deDE = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s geladen. Tippe /blu für Optionen.",
    ["LEVEL_UP"] = "Stufenaufstieg!",
    ["ACHIEVEMENT_EARNED"] = "Erfolg errungen!",
    ["QUEST_ACCEPTED"] = "Quest angenommen!",
    ["QUEST_COMPLETED"] = "Quest abgeschlossen!",
    -- Add more German translations
}

-- French
local frFR = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s chargé. Tapez /blu pour les options.",
    ["LEVEL_UP"] = "Niveau supérieur!",
    ["ACHIEVEMENT_EARNED"] = "Haut fait accompli!",
    ["QUEST_ACCEPTED"] = "Quête acceptée!",
    ["QUEST_COMPLETED"] = "Quête terminée!",
    -- Add more French translations
}

-- Spanish
local esES = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s cargado. Escribe /blu para opciones.",
    ["LEVEL_UP"] = "¡Subida de nivel!",
    ["ACHIEVEMENT_EARNED"] = "¡Logro conseguido!",
    ["QUEST_ACCEPTED"] = "¡Misión aceptada!",
    ["QUEST_COMPLETED"] = "¡Misión completada!",
    -- Add more Spanish translations
}

-- Russian
local ruRU = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s загружен. Введите /blu для настроек.",
    ["LEVEL_UP"] = "Повышение уровня!",
    ["ACHIEVEMENT_EARNED"] = "Достижение получено!",
    ["QUEST_ACCEPTED"] = "Задание принято!",
    ["QUEST_COMPLETED"] = "Задание выполнено!",
    -- Add more Russian translations
}

-- Chinese (Simplified)
local zhCN = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s 已加载。输入 /blu 打开选项。",
    ["LEVEL_UP"] = "升级！",
    ["ACHIEVEMENT_EARNED"] = "获得成就！",
    ["QUEST_ACCEPTED"] = "接受任务！",
    ["QUEST_COMPLETED"] = "完成任务！",
    -- Add more Chinese translations
}

-- Chinese (Traditional)
local zhTW = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s 已載入。輸入 /blu 開啟選項。",
    ["LEVEL_UP"] = "升級！",
    ["ACHIEVEMENT_EARNED"] = "獲得成就！",
    ["QUEST_ACCEPTED"] = "接受任務！",
    ["QUEST_COMPLETED"] = "完成任務！",
    -- Add more Traditional Chinese translations
}

-- Korean
local koKR = {
    ["ADDON_NAME"] = "Better Level-Up!",
    ["ADDON_LOADED"] = "BLU v%s 로드됨. /blu를 입력하여 옵션을 엽니다.",
    ["LEVEL_UP"] = "레벨 업!",
    ["ACHIEVEMENT_EARNED"] = "업적 달성!",
    ["QUEST_ACCEPTED"] = "퀘스트 수락!",
    ["QUEST_COMPLETED"] = "퀘스트 완료!",
    -- Add more Korean translations
}

-- Locale mapping
local localeStrings = {
    ["enUS"] = enUS,
    ["enGB"] = enUS,  -- Use US English for GB
    ["deDE"] = deDE,
    ["frFR"] = frFR,
    ["esES"] = esES,
    ["esMX"] = esES,  -- Use Spain Spanish for Mexico
    ["ruRU"] = ruRU,
    ["zhCN"] = zhCN,
    ["zhTW"] = zhTW,
    ["koKR"] = koKR,
}

-- Initialize localization
function Localization:Init()
    -- Get strings for current locale, fallback to enUS
    local strings = localeStrings[locale] or localeStrings["enUS"]
    
    -- Copy all strings, using enUS as fallback for missing translations
    for key, value in pairs(enUS) do
        Localization.L[key] = strings[key] or value
    end
    
    -- Make localization globally available
    BLU.L = Localization.L
    
    -- Legacy support for old localization format
    BLU_L = Localization.L
    
    BLU:PrintDebug("Localization module initialized for locale: " .. locale)
end

-- Get localized string
function Localization:Get(key, ...)
    local str = self.L[key]
    if not str then
        BLU:PrintDebug("Missing localization for key: " .. key)
        return key
    end
    
    -- Format if arguments provided
    if ... then
        return string.format(str, ...)
    end
    
    return str
end

-- Shorthand function
function BLU:Loc(key, ...)
    return Localization:Get(key, ...)
end

-- Export module
return Localization