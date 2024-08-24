--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")

--=====================================================================================
-- Libraries and Variables
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local BLU_PREFIX = "[|cff05dffaBLU|r] "
local DEBUG_PREFIX = "[|cff808080DEBUG|r] "
BLU.functionsHalted = false
BLU.chatFrameHooked = false
BLU.debugMode = false
BLU.showWelcomeMessage = true
BLU.haltTimerRunning = false

--=====================================================================================
-- Utility Functions
--=====================================================================================
function BLU:DebugMessage(message)
    if BLU.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

function BLU:PrintDebugMessage(key, ...)
    if BLU.debugMode and L[key] then
        BLU:DebugMessage(L[key]:format(...))
    end
end
--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

    -- Load saved states
    BLU.debugMode = self.db.profile.debugMode or false
    BLU.showWelcomeMessage = self.db.profile.showWelcomeMessage

    -- Ensure the value is saved if not present (e.g., on first load)
    if BLU.showWelcomeMessage == nil then
        BLU.showWelcomeMessage = true  -- Default to true on first load
        self.db.profile.showWelcomeMessage = true
    end

    -- Debug messages for loaded states
    self:PrintDebugMessage("DEBUG_MODE_LOADED", tostring(BLU.debugMode))
    self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_LOADED", tostring(BLU.showWelcomeMessage))

    -- Register options
    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
    
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")

    -- Register chat commands
    self:RegisterChatCommand("blu", "SlashCommand")

    -- Register shared events
    self:RegisterSharedEvents()
end

--=====================================================================================
-- Display Welcome Message
--=====================================================================================
function BLU:DisplayWelcomeMessage()
    if BLU.showWelcomeMessage then
        print(BLU_PREFIX .. L["WELCOME_MESSAGE"])
        self:PrintDebugMessage("WELCOME_MESSAGE_DISPLAYED")
    end
end
--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:RegisterSharedEvents()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "HandlePlayerEnteringWorld")
    self:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
    self:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
    self:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "ReputationChatFrameHook")
end

--=====================================================================================
-- Sound Selection Functions
--=====================================================================================
function BLU:RandomSoundID()
    self:PrintDebugMessage("SELECTING_RANDOM_SOUND_ID")

    local validSoundIDs = {}

    -- Collect all custom sound IDs
    for soundID, soundList in pairs(sounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end

    -- Collect all default sound IDs
    for soundID, soundList in pairs(defaultSounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end

    -- Return nil if no valid sound IDs are found
    if #validSoundIDs == 0 then
        self:PrintDebugMessage("NO_VALID_SOUND_IDS")
        return nil
    end

    -- Select a random sound ID from the list
    local randomIndex = math.random(1, #validSoundIDs)
    local selectedSoundID = validSoundIDs[randomIndex]

    self:PrintDebugMessage("RANDOM_SOUND_ID_SELECTED", selectedSoundID.id)

    return selectedSoundID
end
--=====================================================================================

-- Function to select a sound based on the provided sound ID
function BLU:SelectSound(soundID)
    self:PrintDebugMessage("SELECTING_SOUND", tostring(soundID))

    -- If the sound ID is not provided or is set to random (2), return a random sound ID
    if not soundID or soundID == 2 then
        local randomSoundID = self:RandomSoundID()
        if randomSoundID then
            self:PrintDebugMessage("USING_RANDOM_SOUND_ID", randomSoundID.id)
            return randomSoundID
        end
    end

    -- Otherwise, return the specified sound ID
    self:PrintDebugMessage("USING_SPECIFIED_SOUND_ID", soundID)
    return {table = sounds, id = soundID}
end

--=====================================================================================
-- Function to play the selected sound with the specified volume level
function BLU:PlaySelectedSound(sound, volumeLevel, defaultTable)
    self:PrintDebugMessage("PLAYING_SOUND", sound.id, volumeLevel)

    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        self:PrintDebugMessage("VOLUME_LEVEL_ZERO")
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]

    self:PrintDebugMessage("SOUND_FILE_TO_PLAY", tostring(soundFile))

    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    else
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", sound.id)
    end
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:HandlePlayerEnteringWorld(...)
    if BLU.haltTimerRunning then
        self:PrintDebugMessage("Halt timer already running. No new timer started.")
        return
    end

    self:PrintDebugMessage("PLAYER_LOGIN")
    self:PrintDebugMessage("COUNTDOWN_START")
    local countdownTime = 15
    BLU.functionsHalted = true
    BLU.haltTimerRunning = true -- Mark the timer as running

    C_Timer.NewTicker(1, function()
        countdownTime = countdownTime - 1
        self:PrintDebugMessage("COUNTDOWN_TICK", countdownTime)

        if countdownTime <= 0 then
            BLU.functionsHalted = false
            BLU.haltTimerRunning = false -- Reset the flag when timer ends
            self:PrintDebugMessage("FUNCTIONS_RESUMED")
        end
    end, 15)

    self:MuteSounds()

    -- Check the welcome message setting before displaying
    if BLU.showWelcomeMessage then
        self:DisplayWelcomeMessage()
    end
end

function BLU:HandlePlayerLevelUp()
    if BLU.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PLAYER_LEVEL_UP")
    local sound = self:SelectSound(self.db.profile["LevelSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["LevelVolume"], defaultSounds[4])
end

function BLU:HandleQuestAccepted()
    if BLU.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_ACCEPTED")
    local sound = self:SelectSound(self.db.profile["QuestAcceptSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["QuestAcceptVolume"], defaultSounds[7])
end

function BLU:HandleQuestTurnedIn()
    if BLU.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("QUEST_TURNED_IN")
    local sound = self:SelectSound(self.db.profile["QuestSoundSelect"])
    self:PlaySelectedSound(sound, self.db.profile["QuestVolume"], defaultSounds[8])
end
--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    if input == "debug" then
        BLU.debugMode = not BLU.debugMode
        self.db.profile.debugMode = BLU.debugMode
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(BLU.debugMode))
        local status = BLU.debugMode and "DEBUG_MODE_ENABLED" or "DEBUG_MODE_DISABLED"
        self:PrintDebugMessage(status)
    elseif input == "welcome" then
        BLU.showWelcomeMessage = not BLU.showWelcomeMessage
        self.db.profile.showWelcomeMessage = BLU.showWelcomeMessage
        self:PrintDebugMessage("SHOW_WELCOME_MESSAGE_TOGGLED", tostring(BLU.showWelcomeMessage))
        local status = BLU.showWelcomeMessage and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        print(BLU_PREFIX .. "Welcome message " .. status)
    elseif input == "enable" then
        self:Enable()
        print(BLU_PREFIX .. L["ADDON_ENABLED"])
    elseif input == "disable" then
        self:Disable()
        print(BLU_PREFIX .. L["ADDON_DISABLED"])
    elseif input == "help" then
        print(L["SLASH_COMMAND_HELP"])
    else
        Settings.OpenToCategory(self.optionsFrame.name)
        if BLU.debugMode then
            self:PrintDebugMessage("OPTIONS_PANEL_OPENED")
        end
    end
end


--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================
function BLU:ReputationChatFrameHook()
    -- Ensure this hook is only added once
    if BLU.chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_FACTION_CHANGE", function(_, _, msg)
        BLU:DebugMessage("|cffffff00Incoming chat message:|r " .. msg)
        local rankFound = false
        if string.match(msg, "You are now Exalted with") then
            BLU:DebugMessage("|cff00ff00Rank found: Exalted|r")
            BLU:ReputationRankIncrease("Exalted")
            rankFound = true
        elseif string.match(msg, "You are now Revered with") then
            BLU:DebugMessage("|cff00ff00Rank found: Revered|r")
            BLU:ReputationRankIncrease("Revered")
            rankFound = true
        elseif string.match(msg, "You are now Honored with") then
            BLU:DebugMessage("|cff00ff00Rank found: Honored|r")
            BLU:ReputationRankIncrease("Honored")
            rankFound = true
        elseif string.match(msg, "You are now Friendly with") then
            BLU:DebugMessage("|cff00ff00Rank found: Friendly|r")
            BLU:ReputationRankIncrease("Friendly")
            rankFound = true
        elseif string.match(msg, "You are now Neutral with") then
            BLU:DebugMessage("|cff00ff00Rank found: Neutral|r")
            BLU:ReputationRankIncrease("Neutral")
            rankFound = true
        elseif string.match(msg, "You are now Unfriendly with") then
            BLU:DebugMessage("|cff00ff00Rank found: Unfriendly|r")
            BLU:ReputationRankIncrease("Unfriendly")
            rankFound = true
        elseif string.match(msg, "You are now Hostile with") then
            BLU:DebugMessage("|cff00ff00Rank found: Hostile|r")
            BLU:ReputationRankIncrease("Hostile")
            rankFound = true
        elseif string.match(msg, "You are now Hated with") then
            BLU:DebugMessage("|cff00ff00Rank found: Hated|r")
            BLU:ReputationRankIncrease("Hated")
            rankFound = true
        end

        if not rankFound then
            BLU:PrintDebugMessage("NO_RANK_FOUND")
        end

        return false
    end)

    BLU.chatFrameHooked = true
end

function BLU:ReputationRankIncrease(rank)
    if BLU.functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("REPUTATION_RANK_INCREASE", rank)
    local sound = self:SelectSound(self.db.profile.RepSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    local volumeLevel = self.db.profile.RepVolume
    self:PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

--=====================================================================================
-- End of Core Code
--=====================================================================================
