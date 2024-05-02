--v1.0.12
-- BLU is an addon that provides sound effects for various events in World of Warcraft.
-- This file contains the core functionality of the addon, including event registration and sound playback.
-- The addon uses Ace3 libraries for configuration and database management.
-- The sounds are stored in the "Sounds" folder within the addon directory.
-- The addon can be configured using the "/blu" or "/lu" chat commands.

-- This part of the code initializes the addon and its options.
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")

-- Import AceConfig and AceConfigDialog libraries
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

-- Initialize the addon's functionality during its initialization phase
function BLU:OnInitialize()
  -- Initialize the addon's database using AceDB
  self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)

  -- Register options table for the "BLU_Options" configuration
  AC:RegisterOptionsTable("BLU_Options", self.options)
  
  -- Add the "BLU_Options" configuration to the Blizzard Interface Options
  self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")

  -- Register options table for profiles
  profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  
  -- Register the options table for the database.
  AC:RegisterOptionsTable("BLU_Profiles", profiles)
  
  -- Add the profiles configuration to the Blizzard Interface Options
  ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")

  -- Register chat commands "/lu" and "/blu" to the "SlashCommand" function
  self:RegisterChatCommand("lu", "SlashCommand")
  self:RegisterChatCommand("blu", "SlashCommand")
end

-- This function handles the addon's event registrations when it is enabled
function BLU:OnEnable()

  -- Register various events to trigger sound effects
  self:RegisterEvent("ACHIEVEMENT_EARNED")
  self:RegisterEvent("GLOBAL_MOUSE_DOWN")
  self:RegisterEvent("HONOR_LEVEL_UPDATE")
  self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
  self:RegisterEvent("PLAYER_LEVEL_UP")
  self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("QUEST_ACCEPTED")
  self:RegisterEvent("QUEST_TURNED_IN")
  self:RegisterEvent("UPDATE_FACTION")
  self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
end

-- This function displays a welcome message to the user when they log in
function BLU:PLAYER_ENTERING_WORLD(...)
  DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cff05dffaThank you for Downloading BLU!|r Enter '|cff05dffa/blu|r' to Select |cff05dffaL|revel |cff05dffaU|rp Sounds!")
  DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cffdc143cNOTE|r: You may have to re-select a previously selected sound after |cffdc143cA|rddon |cffdc143cU|rpdates.")
end

-- Table containing the file paths for all of the sound files used by the addon, indexed by a number representing the sound's ID.
local sounds = {
  [2] = "Interface\\Addons\\BLU\\Sounds\\ABLU.ogg",
  [3] = "Interface\\Addons\\BLU\\Sounds\\ACLU.ogg",
  [4] = "Interface\\Addons\\BLU\\Sounds\\CLU.ogg",
  [5] = "Interface\\Addons\\BLU\\Sounds\\D2LU.ogg",
  [6] = "Interface\\Addons\\BLU\\Sounds\\DQLU.ogg",
  [7] = "Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg",
  [8] = "Interface\\Addons\\BLU\\Sounds\\EQLU.ogg",
  [9] = "Interface\\Addons\\BLU\\Sounds\\NVLU.ogg",
  [10] = "Interface\\Addons\\BLU\\Sounds\\FO3LU.ogg",
  [11] = "Interface\\Addons\\BLU\\Sounds\\FFLU.ogg",
  [12] = "Interface\\Addons\\BLU\\Sounds\\FELU.ogg",
  [13] = "Interface\\Addons\\BLU\\Sounds\\FEALU.ogg",
  [14] = "Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg",
  [15] = "Interface\\Addons\\BLU\\Sounds\\FNLU.ogg",
  [16] = "Interface\\Addons\\BLU\\Sounds\\GTASALU.ogg",
  [17] = "Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg",
  [18] = "Interface\\Addons\\BLU\\Sounds\\KLU1.ogg",
  [19] = "Interface\\Addons\\BLU\\Sounds\\KLU2.ogg",
  [20] = "Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg",
  [21] = "Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg",
  [22] = "Interface\\Addons\\BLU\\Sounds\\MSLU.ogg",
  [23] = "Interface\\Addons\\BLU\\Sounds\\MGSLU.ogg",
  [24] = "Interface\\Addons\\BLU\\Sounds\\MCLU.ogg",
  [25] = "Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg",
  [26] = "Interface\\Addons\\BLU\\Sounds\\MWLU.ogg",
  [27] = "Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg",
  [28] = "Interface\\Addons\\BLU\\Sounds\\PoELU.ogg",
  [29] = "Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg",
  [30] = "Interface\\Addons\\BLU\\Sounds\\ROLU.ogg",
  [31] = "Interface\\Addons\\BLU\\Sounds\\SF2LU.ogg",
  [32] = "Interface\\Addons\\BLU\\Sounds\\SFLU1.ogg",
  [33] = "Interface\\Addons\\BLU\\Sounds\\SFLU2.ogg",
  [34] = "Interface\\Addons\\BLU\\Sounds\\SFLU3.ogg",
  [35] = "Interface\\Addons\\BLU\\Sounds\\SFLU4.ogg",
  [36] = "Interface\\Addons\\BLU\\Sounds\\SFLU5.ogg",
  [37] = "Interface\\Addons\\BLU\\Sounds\\SFLU6.ogg",
  [38] = "Interface\\Addons\\BLU\\Sounds\\SFLU7.ogg",
  [39] = "Interface\\Addons\\BLU\\Sounds\\SFLU8.ogg",
  [40] = "Interface\\Addons\\BLU\\Sounds\\SFLU9.ogg",
  [41] = "Interface\\Addons\\BLU\\Sounds\\SFLU10.ogg",
  [42] = "Interface\\Addons\\BLU\\Sounds\\SFLU11.ogg",
  [43] = "Interface\\Addons\\BLU\\Sounds\\SRLU.ogg",
  [44] = "Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg",
  [45] = "Interface\\Addons\\BLU\\Sounds\\STDLU.ogg",
  [46] = "Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg",
  [47] = "Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg",
  [48] = "Interface\\Addons\\BLU\\Sounds\\W3LU.ogg",
  [49] = "Interface\\Addons\\BLU\\Sounds\\W3QLU.ogg",
}
-- The following code defines multiple functions that handle various in-game events
-- and play corresponding sounds based on user configuration.

-- Handle achievement earned event
function BLU:ACHIEVEMENT_EARNED(self, event, ...)
    local sound = sounds[BLU.db.profile.AchievementSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.AchievementSoundSelect then
        PlaySoundFile(569143, "MASTER")
    end
end

-- Function to test achievement sound
function TestAchievementSound()
    local sound = sounds[BLU.db.profile.AchievementSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.AchievementSoundSelect then
        PlaySoundFile(569143, "MASTER")
    end
end

-- Handle pet battle level change event
function BLU:PET_BATTLE_LEVEL_CHANGED(self, event, ...)
    local sound = sounds[BLU.db.profile.BattlePetLevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.BattlePetLevelSoundSelect then
        PlaySoundFile(642841, "MASTER")
    end
end

-- Function to test pet battle level sound
function TestBattlePetLevelSound()
    local sound = sounds[BLU.db.profile.BattlePetLevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.BattlePetLevelSoundSelect then
        PlaySoundFile(642841, "MASTER")
    end
end

-- Handle honor level update event
function BLU:HONOR_LEVEL_UPDATE(self, event, ...)
    local sound = sounds[BLU.db.profile.HonorSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.HonorSoundSelect then
        PlaySoundFile(1489546, "MASTER")
    end
end

-- Function to test honor level sound
function TestHonorSound()
    local sound = sounds[BLU.db.profile.HonorSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.HonorSoundSelect then
        PlaySoundFile(1489546, "MASTER")
    end
end

-- Handle player level up event
function BLU:PLAYER_LEVEL_UP(self, event, ...)
    local sound = sounds[BLU.db.profile.LevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.LevelSoundSelect then
        PlaySoundFile(569593, 'MMASTER')
    end
end

-- Function to test player level up sound
function TestLevelSound()
    local sound = sounds[BLU.db.profile.LevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.LevelSoundSelect then
        PlaySoundFile(569593, "MASTER")
    end
end

-- Handle major faction renown level change event
function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(self, event, ...)
    local sound = sounds[BLU.db.profile.RenownSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.RenownSoundSelect then
        PlaySoundFile(4745441, "MASTER")
    end
end

-- Function to test major faction renown sound
function TestRenownSound()
    local sound = sounds[BLU.db.profile.RenownSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.RenownSoundSelect then
        PlaySoundFile(4745441, "MASTER")
    end
end

-- Create an empty table to track factions
local TrackedFactions = {}

-- Handle faction update event
function BLU:UPDATE_FACTION(event, ...)
    for i = 1, GetNumFactions() do
        local _, _, newstanding, _, _, _, _, _, isheader, _, hasrep, _, _, faction = GetFactionInfo(i)
        if faction and (not isheader or hasrep) and (newstanding or 0) > 0 then
            local oldstanding = TrackedFactions[faction]
            if oldstanding and oldstanding < newstanding and BLU.db.profile.RepSoundSelect then
                local sound = sounds[BLU.db.profile.RepSoundSelect]
                if sound then
                    PlaySoundFile(sound, "MASTER")
                elseif BLU.db.profile.RepSoundSelect then
                    PlaySoundFile(568016, "MASTER")
                end
            end
            TrackedFactions[faction] = newstanding
        end
    end
end

-- Function to test reputation sound
function TestRepSound()
    local sound = sounds[BLU.db.profile.RepSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.RepSoundSelect then
        PlaySoundFile(568016, "MASTER")
    end
end

-- Handle quest accepted event
function BLU:QUEST_ACCEPTED(self, event, ...)
    local sound = sounds[BLU.db.profile.QuestAcceptSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestAcceptSoundSelect then
        PlaySoundFile(567400, "MASTER")
    end
end

-- Function to test quest accepted sound
function TestQuestAcceptSound()
    local sound = sounds[BLU.db.profile.QuestAcceptSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestAcceptSoundSelect then
        PlaySoundFile(567400, "MASTER")
    end
end

-- Handle quest turned in event
function BLU:QUEST_TURNED_IN(self, event, ...)
    local sound = sounds[BLU.db.profile.QuestSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestSoundSelect then
        PlaySoundFile(567439, "MASTER")
    end
end

-- Function to test quest turned in sound
function TestQuestSound()
    local sound = sounds[BLU.db.profile.QuestSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestSoundSelect then
        PlaySoundFile(567439, "MASTER")
    end
end

-- Handle perks activity completed event
function BLU:PERKS_ACTIVITY_COMPLETED(self, event, ...)
    local sound = sounds[BLU.db.profile.PostSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.PostSoundSelect then
        PlaySoundFile(4956064, "MASTER")
    end
end

-- Function to test perks activity completed sound
function TestPostSound()
    local sound = sounds[BLU.db.profile.PostSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.PostSoundSelect then
        PlaySoundFile(4956064, "MASTER")
    end
end

-- Define a table to map sound file IDs to user settings
local soundFileSettings = {
    [569143] = "MuteAchievementDefault",
    [1489546] = "MuteHonorDefault",
    [569593] = "MuteLevelDefault",
    [642841] = "MuteBattlePetLevelDefault",
    [4745441] = "MuteRenownDefault",
    [568016] = "MuteRepDefault",
    [567400] = "MuteQuestAcceptDefault",
    [567439] = "MuteQuestDefault",
    [4956064] = "MutePostDefault",
}

-- Handle global mouse down event to mute/unmute sounds based on user settings
function BLU:GLOBAL_MOUSE_DOWN(self, event, ...)
    for soundFileID, settingName in pairs(soundFileSettings) do
        if BLU.db.profile[settingName] then
            MuteSoundFile(soundFileID)
        else
            UnmuteSoundFile(soundFileID)
        end
    end
end

-- Handle slash command input
function BLU:SlashCommand(input, editbox)
    if input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        self:Disable()
        self:Print("Disabled.")
    else
        -- Open the addon's configuration options in the Interface Options frame
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
end