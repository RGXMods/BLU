--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("QUEST_TURNED_IN")
    self:ReputationChatFrameHook() -- chat frame here instead of using UPDATE_FACTION
end

--=====================================================================================
-- Utility Functions
--=====================================================================================

-- Function to mute specific sounds by their sound IDs
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs_v) do -- Using Vanilla sound IDs
        MuteSoundFile(soundID)
        if debugMode then
            self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] Muting sound with ID: |cff8080ff" .. soundID .. "|r")
        end
    end
end

--=====================================================================================
-- Event Handlers
--=====================================================================================
function BLU:PLAYER_ENTERING_WORLD(...)
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0PLAYER_ENTERING_WORLD|r event triggered.")
    end
    C_Timer.After(15, function()
        functionsHalted = false
    end)
    functionsHalted = true
    self:MuteSounds()
end

function BLU:PLAYER_LEVEL_UP()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0PLAYER_LEVEL_UP|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function BLU:ReputationRankIncrease(factionName, newRank)
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0ReputationRankIncrease|r event triggered for |cff00e012" .. factionName .. "|r (Rank: " .. newRank .. ")")
    end
    local sound = SelectSound(BLU.db.profile.RepSoundSelect)
    local volumeLevel = BLU.db.profile.RepVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

function BLU:QUEST_ACCEPTED()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0QUEST_ACCEPTED|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[7])
end

function BLU:QUEST_TURNED_IN()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0QUEST_TURNED_IN|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[8])
end

--=====================================================================================
-- ChatFrame Hooks
--=====================================================================================
function BLU:ReputationChatFrameHook()
    if not chatFrameHooked then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(self, event, msg)
            for _, rank in ipairs(reputationRanks) do
                local reputationGainPattern = "You are now " .. rank .. " with (.+)%.?"
                local factionName = string.match(msg, reputationGainPattern)
                if factionName then
                    BLU:ReputationRankIncrease(factionName, rank)
                    if debugMode then
                        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] Player gained reputation with |cff00e012" .. factionName .. "|r (Rank: " .. rank .. ")")
                    end
                end
            end
            return false -- Ensure the original message is not blocked
        end)
        chatFrameHooked = true
    end
end

--=====================================================================================
-- Test Functions
--=====================================================================================
function TestLevelSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestLevelSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function TestRepSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestRepSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.RepSoundSelect)
    local volumeLevel = BLU.db.profile.RepVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[6])
end

function TestQuestAcceptSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestQuestAcceptSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.QuestAcceptSoundSelect)
    local volumeLevel = BLU.db.profile.QuestAcceptVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[7])
end

function TestQuestSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestQuestSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.QuestSoundSelect)
    local volumeLevel = BLU.db.profile.QuestVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[8])
end
