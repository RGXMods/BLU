--=====================================================================================
-- Event Registration
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
    self:ReputationChatFrameHook() -- Hook the chat frame here instead of using UPDATE_FACTION
end

--=====================================================================================
-- Utility Functions
--=====================================================================================

-- Function to mute specific sounds by their sound IDs
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do -- Retail
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

function BLU:ACHIEVEMENT_EARNED()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0ACHIEVEMENT_EARNED|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[1])
end

function BLU:PET_BATTLE_LEVEL_CHANGED()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0PET_BATTLE_LEVEL_CHANGED|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

function BLU:HONOR_LEVEL_UPDATE()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0HONOR_LEVEL_UPDATE|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
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

function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0MAJOR_FACTION_RENOWN_LEVEL_CHANGED|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[5])
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

function BLU:PERKS_ACTIVITY_COMPLETED()
    if functionsHalted then return end
    if debugMode then
        self:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0PERKS_ACTIVITY_COMPLETED|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[9])
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
function TestAchievementSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestAchievementSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.AchievementSoundSelect)
    local volumeLevel = BLU.db.profile.AchievementVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[1])
end

function TestBattlePetLevelSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestBattlePetLevelSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.BattlePetLevelSoundSelect)
    local volumeLevel = BLU.db.profile.BattlePetLevelVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

function TestHonorSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestHonorSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.HonorSoundSelect)
    local volumeLevel = BLU.db.profile.HonorVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
end

function TestLevelSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestLevelSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.LevelSoundSelect)
    local volumeLevel = BLU.db.profile.LevelVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[4])
end

function TestRenownSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestRenownSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.RenownSoundSelect)
    local volumeLevel = BLU.db.profile.RenownVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[5])
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

function TestPostSound()
    if debugMode then
        BLU:DebugMessage("[|cff05dffaBLU|r] [|cff808080DEBUG|r] |cffc586c0TestPostSound|r event triggered.")
    end
    local sound = SelectSound(BLU.db.profile.PostSoundSelect)
    local volumeLevel = BLU.db.profile.PostVolume
    PlaySelectedSound(sound, volumeLevel, defaultSounds[9])
end