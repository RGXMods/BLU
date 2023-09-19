--v1.0.4
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
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
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("UPDATE_FACTION")
end
function BLU:PLAYER_LOGIN(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cff05dffaThank you for Downloading BLU!|r Enter '|cff05dffa/blu|r' to Select |cff05dffaL|revel |cff05dffaU|rp Sounds!");
	DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cffdc143cNOTE|r: You may have to re-select a previously selected sound after |cffdc143cA|rddon |cffdc143cU|rpdates.");
end
local sounds = {
	[2] = "Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg",
	[3] = "Interface\\Addons\\BLU\\Sounds\\EQLU.ogg",
	[4] = "Interface\\Addons\\BLU\\Sounds\\FFLU.ogg",
	[5] = "Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg",
	[6] = "Interface\\Addons\\BLU\\Sounds\\FNLU.ogg",
	[7] = "Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg",
  [8] = "Interface\\Addons\\BLU\\Sounds\\KLU1.ogg",
  [9] = "Interface\\Addons\\BLU\\Sounds\\KLU2.ogg",
	[10] = "Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg",
	[11] = "Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg",
	[12] = "Interface\\Addons\\BLU\\Sounds\\MSLU.ogg",
  [13] = "Interface\\Addons\\BLU\\Sounds\\MGSLU.ogg",
	[14] = "Interface\\Addons\\BLU\\Sounds\\MCLU.ogg",
	[15] = "Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg",
	[16] = "Interface\\Addons\\BLU\\Sounds\\MWLU.ogg",
	[17] = "Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg",
	[18] = "Interface\\Addons\\BLU\\Sounds\\PoELU.ogg",
	[19] = "Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg",
	[20] = "Interface\\Addons\\BLU\\Sounds\\SRLU.ogg",
	[21] = "Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg",
  [22] = "Interface\\Addons\\BLU\\Sounds\\STDLU.ogg",
	[23] = "Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg",
	[24] = "Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg",
	[25] = "Interface\\Addons\\BLU\\Sounds\\W3LU.ogg",
}
function BLU:ACHIEVEMENT_EARNED(self, event, ...)
    local sound = sounds[BLU.db.profile.AchievementSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.AchievementSoundSelect then
        PlaySoundFile(569143, "MASTER")
    end
end
function TestAchievementSound()
    local sound = sounds[BLU.db.profile.AchievementSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.AchievementSoundSelect then
        PlaySoundFile(569143, "MASTER")
    end
end
function BLU:PLAYER_LEVEL_UP(self, event, ...)
    local sound = sounds[BLU.db.profile.LevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.LevelSoundSelect then
        PlaySoundFile(569593, "MASTER")
    end
end
function TestLevelSound()
    local sound = sounds[BLU.db.profile.LevelSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.LevelSoundSelect then
        PlaySoundFile(569593, "MASTER")
    end
end
local TrackedFactions = {}
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
function TestRepSound()
    local sound = sounds[BLU.db.profile.RepSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.RepSoundSelect then
        PlaySoundFile(568016, "MASTER")
    end
end
function BLU:QUEST_ACCEPTED(self, event, ...)
    local sound = sounds[BLU.db.profile.QuestAcceptSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestAcceptSoundSelect then
        PlaySoundFile(567400, "MASTER")
    end
end
function TestQuestAcceptSound()
    local sound = sounds[BLU.db.profile.QuestAcceptSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestAcceptSoundSelect then
        PlaySoundFile(567400, "MASTER")
    end
end
function BLU:QUEST_TURNED_IN(self, event, ...)
    local sound = sounds[BLU.db.profile.QuestSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestSoundSelect then
        PlaySoundFile(567439, "MASTER")
    end
end
function TestQuestSound()
    local sound = sounds[BLU.db.profile.QuestSoundSelect]
    if sound then
        PlaySoundFile(sound, "MASTER")
    elseif BLU.db.profile.QuestSoundSelect then
        PlaySoundFile(567439, "MASTER")
    end
end
local soundFileSettings = {
    [569143] = "MuteAchievementDefault",
    [569593] = "MuteLevelDefault",
    [568016] = "MuteRepDefault",
    [567400] = "MuteQuestAcceptDefault",
    [567439] = "MuteQuestDefault",
}
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
