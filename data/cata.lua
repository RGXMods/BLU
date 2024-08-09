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
    if functionsHalted then return end
    self:PlaySelectedSound("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume")
end

--=====================================================================================
-- Cata-specific Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs_c) do
        MuteSoundFile(soundID)
    end
end
