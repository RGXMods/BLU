-- modules/core.lua
local core = {}

function core:OnEnable()
    self.addon:Print("Core module enabled!")
    self.addon:RegisterEvent("PLAYER_LEVEL_UP", "HandlePlayerLevelUp")
end

function core:HandlePlayerLevelUp()
    self.addon:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", defaultSounds[4], "PLAYER_LEVEL_UP_TRIGGERED")
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
