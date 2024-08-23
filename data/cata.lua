--=====================================================================================
-- BLU | Better Level Up! - cata.lua
--=====================================================================================

--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:OnEnable()
    self:PrintDebugMessage("ENABLING_ADDON")
    self:RegisterSharedEvents()
    self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
end

--=====================================================================================
-- Event Handlers for Cata-specific Events
--=====================================================================================
function BLU:HandleAchievementEarned()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("ACHIEVEMENT_EARNED")
    local sound = SelectSound(self.db.profile["AchievementSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["AchievementVolume"], defaultSounds[1])
end

--=====================================================================================
-- Cata-specific Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs_c) do
        self:PrintDebugMessage("MUTE_SOUND", soundID)
        MuteSoundFile(soundID)
    end
end
