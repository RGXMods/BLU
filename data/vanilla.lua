--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:OnEnable()
    self:PrintDebugMessage("ENABLING_ADDON")
    self:RegisterSharedEvents()
end

--=====================================================================================
-- Vanilla-specific Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs_v) do
        self:PrintDebugMessage("MUTE_SOUND", soundID)
        MuteSoundFile(soundID)
    end
end

--=====================================================================================
-- Vanilla Event Handlers
--=====================================================================================
