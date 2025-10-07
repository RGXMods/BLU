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
    self.addon:RegisterEvent("PERKS_ACTIVITY_COMPLETED", "HandlePerksActivityCompleted")
    self:ReputationChatFrameHook()
end

function core:HandlePlayerLevelUp()
    self.addon:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", self.addon:GetModule("Sounds").defaultSounds[5], "PLAYER_LEVEL_UP_TRIGGERED")
end

function core:HandleQuestAccepted()
    self.addon:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", self.addon:GetModule("Sounds").defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED")
end

function core:HandleQuestTurnedIn()
    self.addon:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", self.addon:GetModule("Sounds").defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED")
end

function core:HandleAchievementEarned()
    self.addon:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", self.addon:GetModule("Sounds").defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED")
end

function core:HandleHonorLevelUpdate()
    self.addon:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", self.addon:GetModule("Sounds").defaultSounds[4], "HONOR_LEVEL_UPDATE_TRIGGERED")
end

function core:HandleRenownLevelChanged()
    self.addon:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", self.addon:GetModule("Sounds").defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED")
end

function core:HandlePerksActivityCompleted()
    self.addon:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", self.addon:GetModule("Sounds").defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED")
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

function core:ReputationChatFrameHook()
    if self.addon.chatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self.addon:PrintDebugMessage("INCOMING_CHAT_MESSAGE: " .. msg)

        local rankFound = false
        if string.match(msg, "You are now Exalted with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Exalted|r")
            self:ReputationRankIncrease("Exalted", msg)
            rankFound = true
        elseif string.match(msg, "You are now Revered with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Revered|r")
            self:ReputationRankIncrease("Revered", msg)
            rankFound = true
        elseif string.match(msg, "You are now Honored with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Honored|r")
            self:ReputationRankIncrease("Honored", msg)
            rankFound = true
        elseif string.match(msg, "You are now Friendly with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Friendly|r")
            self:ReputationRankIncrease("Friendly", msg)
            rankFound = true
        elseif string.match(msg, "You are now Neutral with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Neutral|r")
            self:ReputationRankIncrease("Neutral", msg)
            rankFound = true
        elseif string.match(msg, "You are now Unfriendly with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Unfriendly|r")
            self:ReputationRankIncrease("Unfriendly", msg)
            rankFound = true
        elseif string.match(msg, "You are now Hostile with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Hostile|r")
            self:ReputationRankIncrease("Hostile", msg)
            rankFound = true
        elseif string.match(msg, "You are now Hated with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Hated|r")
            self:ReputationRankIncrease("Hated", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then -- start of new shit
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Acquaintance|r")
            self:ReputationRankIncrease("Acquaintance", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Crony|r")
            self:ReputationRankIncrease("Crony", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Accomplice|r")
            self:ReputationRankIncrease("Accomplice", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Collaborator|r")
            self:ReputationRankIncrease("Collaborator", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Accessory|r")
            self:ReputationRankIncrease("Accessory", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Abettor|r")
            self:ReputationRankIncrease("Abettor", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Conspirator|r")
            self:ReputationRankIncrease("Conspirator", msg)
            rankFound = true
        elseif string.match(msg, "Your standing with") then
            self.addon:PrintDebugMessage("|cff00ff00Rank found: Mastermind|r")
            self:ReputationRankIncrease("Hated", msg)
            rankFound = true
        end

        if not rankFound then
            self.addon:PrintDebugMessage("NO_RANK_FOUND")
        end

        return false
    end)

    self.addon.chatFrameHooked = true
end

function core:ReputationRankIncrease(rank, msg)
    local factionName = string.match(msg, "with (.+)")
    self.addon:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", self.addon:GetModule("Sounds").defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
end

BLULib = BLULib or {}
BLULib.CoreModule = core
