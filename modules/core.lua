-- modules/core.lua
local core = {}

function core:OnEnable()
    self.addon:Print("Core module enabled!")
    self.addon:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
    self.addon:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
    self.addon:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
    self.addon:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
    self.addon:RegisterEvent("HONOR_LEVEL_UPDATE", "HandleHonorLevelUpdate")
    self.addon:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "HandleRenownLevelChanged")
end

function core:HandlePlayerLevelUp()
    self.addon:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
end

function core:HandleQuestAccepted()
    self.addon:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
end

function core:HandleQuestTurnedIn()
    self.addon:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function core:HandleAchievementEarned()
    self.addon:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function core:HandleHonorLevelUpdate()
    self.addon:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", defaultSounds[5], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function core:HandleRenownLevelChanged()
    self.addon:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function core:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)
    if self.addon.functionsHalted then
        self.addon:PrintDebugMessage("FUNCTIONS_HALTED")
        return
    end

    table.insert(self.addon.eventQueue, {
        eventName = eventName,
        soundSelectKey = soundSelectKey,
        volumeKey = volumeKey,
        defaultSound = defaultSound,
        debugMessage = debugMessage
    })

    if not self.addon.isProcessingQueue then
        self.addon.isProcessingQueue = true
        self.addon:ProcessEventQueue()
    end
end

BLULib = BLULib or {}
BLULib.CoreModule = core
