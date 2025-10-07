-- modules/core.lua
local core = {}

function core:OnEnable()
    self.addon:Print("Core module enabled!")
    self.addon:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
    self.addon:RegisterEvent("QUEST_ACCEPTED", "HandleQuestAccepted")
    self.addon:RegisterEvent("QUEST_TURNED_IN", "HandleQuestTurnedIn")
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
