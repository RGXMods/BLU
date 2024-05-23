--v3.1.6
-- BLU is an addon that provides sound effects for various events in World of Warcraft.
-- This file contains the core functionality of the addon, including event registration and sound playback.
-- The addon uses Ace3 libraries for configuration and database management.
-- The sounds are stored in the "sounds" folder within the addon directory.
-- The addon can be configured using the "/blu" or "/lu" chat commands.
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local functionsHalted = false

function BLU:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
  AC:RegisterOptionsTable("BLU_Options", self.options)
  self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
  profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
  AC:RegisterOptionsTable("BLU_Profiles", profiles)
  ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
  self:RegisterChatCommand("lu", "SlashCommand")
  self:RegisterChatCommand("blu", "SlashCommand")
end

function BLU:OnEnable()
    self:RegisterEvent("ACHIEVEMENT_EARNED")
    self:RegisterEvent("GLOBAL_MOUSE_DOWN")
    self:RegisterEvent("HONOR_LEVEL_UPDATE")
    self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("QUEST_TURNED_IN")
    self:RegisterEvent("UPDATE_FACTION")
end

local sounds = {
    [3] = "Interface\\Addons\\BLU\\sounds\\altered_beast.ogg",
    [4] = "Interface\\Addons\\BLU\\sounds\\assassins_creed.ogg",
    [5] = "Interface\\Addons\\BLU\\sounds\\castlevania.ogg",
    [6] = "Interface\\Addons\\BLU\\sounds\\diablo_2.ogg",
    [7] = "Interface\\Addons\\BLU\\sounds\\dragon_quest.ogg",
    [8] = "Interface\\Addons\\BLU\\sounds\\dota_2.ogg",
    [9] = "Interface\\Addons\\BLU\\sounds\\everquest.ogg",
    [10] = "Interface\\Addons\\BLU\\sounds\\fallout_new_vegas.ogg",
    [11] = "Interface\\Addons\\BLU\\sounds\\fallout_3.ogg",
    [12] = "Interface\\Addons\\BLU\\sounds\\final_fantasy.ogg",
    [13] = "Interface\\Addons\\BLU\\sounds\\fire_emblem.ogg",
    [14] = "Interface\\Addons\\BLU\\sounds\\fire_emblem_awakening.ogg",
    [15] = "Interface\\Addons\\BLU\\sounds\\fly_for_fun.ogg",
    [16] = "Interface\\Addons\\BLU\\sounds\\fortnite.ogg",
    [17] = "Interface\\Addons\\BLU\\sounds\\gta_san_andreas.ogg",
    [18] = "Interface\\Addons\\BLU\\sounds\\kingdom_hearts_3.ogg",
    [19] = "Interface\\Addons\\BLU\\sounds\\kirby-1.ogg",
    [20] = "Interface\\Addons\\BLU\\sounds\\kirby-2.ogg",
    [21] = "Interface\\Addons\\BLU\\sounds\\league_of_legends.ogg",
    [22] = "Interface\\Addons\\BLU\\sounds\\legend_of_zelda.ogg",
    [23] = "Interface\\Addons\\BLU\\sounds\\maplestory.ogg",
    [24] = "Interface\\Addons\\BLU\\sounds\\metalgear_solid.ogg",
    [25] = "Interface\\Addons\\BLU\\sounds\\minecraft.ogg",
    [26] = "Interface\\Addons\\BLU\\sounds\\modern_warfare_2.ogg",
    [27] = "Interface\\Addons\\BLU\\sounds\\morrowind.ogg",
    [28] = "Interface\\Addons\\BLU\\sounds\\old_school_runescape.ogg",
    [29] = "Interface\\Addons\\BLU\\sounds\\palworld.ogg",
    [30] = "Interface\\Addons\\BLU\\sounds\\path_of_exile.ogg",
    [31] = "Interface\\Addons\\BLU\\sounds\\pokemon.ogg",
    [32] = "Interface\\Addons\\BLU\\sounds\\ragnarok_online.ogg",
    [33] = "Interface\\Addons\\BLU\\sounds\\shining_force_2.ogg",
    [34] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-1.ogg",
    [35] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-2.ogg",
    [36] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-3.ogg",
    [37] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-4.ogg",
    [38] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-5.ogg",
    [39] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-6.ogg",
    [40] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-7.ogg",
    [41] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-8.ogg",
    [42] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-9.ogg",
    [43] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-10.ogg",
    [44] = "Interface\\Addons\\BLU\\sounds\\shining_force_3-11.ogg",
    [45] = "Interface\\Addons\\BLU\\sounds\\skyrim.ogg",
    [46] = "Interface\\Addons\\BLU\\sounds\\sonic_the_hedgehog.ogg",
    [47] = "Interface\\Addons\\BLU\\sounds\\spyro_the_dragon.ogg",
    [48] = "Interface\\Addons\\BLU\\sounds\\super_mario_bros_3.ogg",
    [49] = "Interface\\Addons\\BLU\\sounds\\warcraft_3.ogg",
    [50] = "Interface\\Addons\\BLU\\sounds\\witcher_3-1.ogg",
    [51] = "Interface\\Addons\\BLU\\sounds\\witcher_3-2.ogg",
}

local soundFileSettings = {
    [569143] = "MuteAchievementDefault",
    [1489546] = "MuteHonorDefault",
    [569593] = "MuteLevelDefault",
    [642841] = "MuteBattlePetLevelDefault",
    [4745441] = "MuteRenownDefault",
    [568016] = "MuteRepDefault",
    [567400] = "MuteQuestAcceptDefault",
    [567439] = "MuteQuestDefault",
    [2066672] = "MutePostDefault",
}
function BLU:PLAYER_ENTERING_WORLD(...)
    DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cff05dffaThank you for Downloading BLU!|r Enter '|cff05dffa/blu|r' to Select |cff05dffaL|revel |cff05dffaU|rp Sounds!")
    DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cffdc143cNOTE|r: You may have to re-select a previously selected sound after |cffdc143cA|rddon |cffdc143cU|rpdates.")
    C_Timer.After(10, function()
        functionsHalted = false
    end)
    functionsHalted = true
end
local function RandomSoundID()
    return math.random(3, 51)
end
local function PlaySoundByID(soundID)
    local sound = sounds[soundID]
    if sound then
        PlaySoundFile(sound, "MASTER")
    end
end
local function SelectSound(soundID)
    if soundID == 2 then
        soundID = RandomSoundID()
    end
    return soundID
end
function BLU:ACHIEVEMENT_EARNED(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.AchievementSoundSelect
    if soundID == 1 then
        PlaySoundFile(569143, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestAchievementSound()
    local soundID = BLU.db.profile.AchievementSoundSelect
    if soundID == 1 then
        PlaySoundFile(569143, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:PET_BATTLE_LEVEL_CHANGED(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.BattlePetLevelSoundSelect
    if soundID == 1 then 
        PlaySoundFile(642841, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestBattlePetLevelSound()
    local soundID = BLU.db.profile.BattlePetLevelSoundSelect
    if soundID == 1 then 
        PlaySoundFile(642841, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:HONOR_LEVEL_UPDATE(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.HonorSoundSelect
    if soundID == 1 then 
        PlaySoundFile(1489546, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestHonorSound()
    local soundID = BLU.db.profile.HonorSoundSelect
    if soundID == 1 then 
        PlaySoundFile(1489546, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:PLAYER_LEVEL_UP(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.LevelSoundSelect
    if soundID == 1 then
        PlaySoundFile(569593, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestLevelSound()
    local soundID = BLU.db.profile.LevelSoundSelect
    if soundID == 1 then
        PlaySoundFile(569593, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.RenownSoundSelect
    if soundID == 1 then
        PlaySoundFile(4745441, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestRenownSound()
    local soundID = BLU.db.profile.RenownSoundSelect
    if soundID == 1 then
        PlaySoundFile(4745441, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
local TrackedFactions = {}
function BLU:UPDATE_FACTION(event, ...)
    if functionsHalted then return end
    if soundID == 1 then
        PlaySoundFile(568016, "MASTER")
    else
        for i = 1, GetNumFactions() do
            local _, _, newstanding, _, _, _, _, _, isheader, _, hasrep, _, _, faction = GetFactionInfo(i)
            if faction and (not isheader or hasrep) and (newstanding or 0) > 0 then
                local oldstanding = TrackedFactions[faction]
                if oldstanding and oldstanding < newstanding and BLU.db.profile.RepSoundSelect then
                    local soundID = BLU.db.profile.RepSoundSelect
                    PlaySoundByID(SelectSound(soundID))
                end
                TrackedFactions[faction] = newstanding
            end
        end
    end
end
function TestRepSound()
    local soundID = BLU.db.profile.RepSoundSelect
    if soundID == 1 then
        PlaySoundFile(568016, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:QUEST_ACCEPTED(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.QuestAcceptSoundSelect
    if soundID == 1 then
        PlaySoundFile(567400, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestQuestAcceptSound()
    local soundID = BLU.db.profile.QuestAcceptSoundSelect
    if soundID == 1 then
        PlaySoundFile(567400, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:QUEST_TURNED_IN(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.QuestSoundSelect
    if soundID == 1 then
        PlaySoundFile(567439, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestQuestSound()
    local soundID = BLU.db.profile.QuestSoundSelect
    if soundID == 1 then
        PlaySoundFile(567439, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:PERKS_ACTIVITY_COMPLETED(self, event, ...)
    if functionsHalted then return end
    local soundID = BLU.db.profile.PostSoundSelect
    if soundID == 1 then 
        PlaySoundFile(2066672, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function TestPostSound()
    local soundID = BLU.db.profile.PostSoundSelect
    if soundID == 1 then 
        PlaySoundFile(2066672, "MASTER")
    else
        PlaySoundByID(SelectSound(soundID))
    end
end
function BLU:GLOBAL_MOUSE_DOWN(self, event, ...)
    for soundFileID, settingName in pairs(soundFileSettings) do
        if BLU.db.profile[settingName] then
            MuteSoundFile(soundFileID)
        else
            UnmuteSoundFile(soundFileID)
        end
    end
end
function BLU:SlashCommand(input, editbox)
    if input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        self:Disable()
        self:Print("Disabled.")
    else
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    end
end