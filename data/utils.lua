--=====================================================================================
-- BLU | Better Level Up!
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

--=====================================================================================
-- Version Number
--=====================================================================================
VersionNumber = C_AddOns.GetAddOnMetadata("BLU", "Version")

--=====================================================================================
-- Libraries
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
functionsHalted = false
chatFrameHooked = false
reputationRanks = {
    "Exalted",
    "Revered",
    "Honored",
    "Friendly",
    "Neutral",
    "Unfriendly",
    "Hostile",
    "Hated"
}

--=====================================================================================
-- Initialization
--=====================================================================================
function BLU:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
    
    -- Register options
    AC:RegisterOptionsTable("BLU_Options", self.options)
    self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
    
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    AC:RegisterOptionsTable("BLU_Profiles", profiles)
    ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
    
    -- Register chat commands
    self:RegisterChatCommand("lu", "SlashCommand")
    self:RegisterChatCommand("blu", "SlashCommand")
end

--=====================================================================================
-- Utility Functions
--=====================================================================================

-- Function to select a random sound ID from the list of available sounds
function RandomSoundID()
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
        return nil
    end
    
    -- Select a random sound ID from the list
    local randomIndex = math.random(1, #validSoundIDs)
    return validSoundIDs[randomIndex]
end

-- Function to select a sound based on the provided sound ID
function SelectSound(soundID)
    -- If the sound ID is not provided or is set to random (2), return a random sound ID
    if not soundID or soundID == 2 then
        return RandomSoundID()
    end
    -- Otherwise, return the specified sound ID
    return {table = sounds, id = soundID}
end

-- Function to play the selected sound with the specified volume level
function PlaySelectedSound(sound, volumeLevel, defaultTable)
    -- Do not play the sound if the volume level is set to 0
    if volumeLevel == 0 then
        return
    end

    -- Determine the sound file to play based on the sound ID and volume level
    local soundFile = sound.id == 1 and defaultTable[volumeLevel] or sound.table[sound.id][volumeLevel]
    -- Play the sound file using the "MASTER" sound channel
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end

--=====================================================================================
-- Slash Command
--=====================================================================================
function BLU:SlashCommand(input)
    if input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        self:Disable()
        self:Print("Disabled.")
    else
        Settings.OpenToCategory(self.optionsFrame.name)
    end
end
