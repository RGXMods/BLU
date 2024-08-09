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
        MuteSoundFile(soundID)
    end
end

--=====================================================================================
-- Vanilla Event Handlers
--=====================================================================================
function BLU:HandlePlayerLevelUp()
    if functionsHalted then return end
    self:PlaySelectedSound("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume")
end

function BLU:HandleQuestAccepted()
    if functionsHalted then return end
    self:PlaySelectedSound("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume")
end

function BLU:HandleQuestTurnedIn()
    if functionsHalted then return end
    self:PlaySelectedSound("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume")
end
