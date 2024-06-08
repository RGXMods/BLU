--=====================================================================================
--=====================================================================================
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")
--=====================================================================================
--=====================================================================================
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
--=====================================================================================
--=====================================================================================
local functionsHalted = false
--=====================================================================================
--=====================================================================================
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
--=====================================================================================
--=====================================================================================
function BLU:OnEnable()
    self:RegisterEvent("ACHIEVEMENT_EARNED")
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
--=====================================================================================
--=====================================================================================
function BLU:PLAYER_ENTERING_WORLD(...)
    C_Timer.After(15, function()
        functionsHalted = false
    end)
    functionsHalted = true
    self:MuteSounds()
end
--=====================================================================================
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        MuteSoundFile(soundID)
    end
end
--=====================================================================================
--=====================================================================================
local function RandomSoundID()
    local validSoundIDs = {}
    for soundID, soundList in pairs(sounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = sounds, id = soundID})
        end
    end
    for soundID, soundList in pairs(defaultSounds) do
        for _, _ in pairs(soundList) do
            table.insert(validSoundIDs, {table = defaultSounds, id = soundID})
        end
    end
    if #validSoundIDs == 0 then
        return nil
    end
    local randomIndex = math.random(1, #validSoundIDs)
    return validSoundIDs[randomIndex]
end
--=====================================================================================
--=====================================================================================
local function SelectSound(soundID)
    if not soundID or soundID == 2 then
        return RandomSoundID()
    end
    return {table = sounds, id = soundID}
end
--=====================================================================================
--=====================================================================================
function BLU:ACHIEVEMENT_EARNED(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[1][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestAchievementSound()
    local sound = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[1][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:PET_BATTLE_LEVEL_CHANGED(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[2][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestBattlePetLevelSound()
    local sound = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[2][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:HONOR_LEVEL_UPDATE(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[3][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestHonorSound()
    local sound = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[3][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:PLAYER_LEVEL_UP(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[4][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestLevelSound()
    local sound = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[4][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[5][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestRenownSound()
    local sound = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[5][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
local TrackedFactions = {}
--===============================================
function BLU:UPDATE_FACTION(event, ...)
    if functionsHalted then return end
    for i = 1, GetNumFactions() do
        local _, _, newstanding, _, _, _, _, _, isheader, _, hasrep, _, _, faction = GetFactionInfo(i)
        if not faction then return nil end
        if (not isheader or hasrep) and (newstanding or 0) > 0 then
            local oldstanding = TrackedFactions[faction]
            if oldstanding and oldstanding < newstanding and BLU.db.profile.RepSoundSelect then
                local sound = SelectSound(BLU.db.profile.RepSoundSelect)
                local volumeLevel = BLU.db.profile.RepVolume
                local soundFile
                if volumeLevel == 0 then
                    return
                end
                if sound.id == 1 then
                    soundFile = defaultSounds[6][volumeLevel]
                else
                    soundFile = sound.table[sound.id][volumeLevel]
                end
                PlaySoundFile(soundFile, "MASTER")
            end
            TrackedFactions[faction] = newstanding
        end
    end
end
--===============================================
function TestRepSound()
    local sound = SelectSound(BLU.db.profile.RepSoundSelect)
    local volumeLevel = BLU.db.profile.RepVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[6][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:QUEST_ACCEPTED(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[7][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestQuestAcceptSound()
    local sound = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[7][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:QUEST_TURNED_IN(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[8][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestQuestSound()
    local sound = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[8][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
function BLU:PERKS_ACTIVITY_COMPLETED(event, ...)
    if functionsHalted then return end
    local sound = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[9][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--===============================================
function TestPostSound()
    local sound = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    local soundFile
    if volumeLevel == 0 then
        return
    end
    if sound.id == 1 then
        soundFile = defaultSounds[9][volumeLevel]
    else
        soundFile = sound.table[sound.id][volumeLevel]
    end
    if soundFile then
        PlaySoundFile(soundFile, "MASTER")
    end
end
--=====================================================================================
--=====================================================================================
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
--=====================================================================================
--=====================================================================================