-- modules/core.lua
local addonName = ...
local BLU = _G["BLU"]

function core:OnEnable()
    self.addon:PrintDebug("Core module enabled!")
    self.addon:RegisterEvent("PLAYER_ENTERING_WORLD", function(addon) addon:HaltOperations() end)
    self.addon:RegisterEvent("PLAYER_LEVEL_UP", function(addon) addon:GetModule("Core"):HandlePlayerLevelUp() end)
    self.addon:RegisterEvent("QUEST_ACCEPTED", function(addon) addon:GetModule("Core"):HandleQuestAccepted() end)
    self.addon:RegisterEvent("QUEST_TURNED_IN", function(addon) addon:GetModule("Core"):HandleQuestTurnedIn() end)
    self.addon:RegisterEvent("ACHIEVEMENT_EARNED", function(addon) addon:GetModule("Core"):HandleAchievementEarned() end)
    self.addon:RegisterEvent("HONOR_LEVEL_UPDATE", function(addon) addon:GetModule("Core"):HandleHonorLevelUpdate() end)
    self.addon:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", function(addon) addon:GetModule("Core"):HandleRenownLevelChanged() end)
    self.addon:RegisterEvent("PERKS_ACTIVITY_COMPLETED", function(addon) addon:GetModule("Core"):HandlePerksActivityCompleted() end)
    self:ReputationChatFrameHook()
end

function core:HandleEvent(eventName, soundSelectKey, volumeKey, defaultSound, debugMessage)
    if self.addon.functionsHalted then
        self.addon:PrintDebug("FUNCTIONS_HALTED_EVENT", eventName)
        return
    end
    table.insert(self.addon.eventQueue, { eventName = eventName, soundSelectKey = soundSelectKey, volumeKey = volumeKey, defaultSound = defaultSound, debugMessage = debugMessage })
    if not self.addon.isProcessingQueue then
        self.addon.isProcessingQueue = true
        self.addon:ProcessEventQueue()
    end
end

function core:HandlePlayerLevelUp() self:HandleEvent("PLAYER_LEVEL_UP", "LevelSoundSelect", "LevelVolume", self.addon:GetModule("Sounds").defaultSounds[5], "PLAYER_LEVEL_UP_TRIGGERED") end
function core:HandleQuestAccepted() self:HandleEvent("QUEST_ACCEPTED", "QuestAcceptSoundSelect", "QuestAcceptVolume", self.addon:GetModule("Sounds").defaultSounds[7], "QUEST_ACCEPTED_TRIGGERED") end
function core:HandleQuestTurnedIn() self:HandleEvent("QUEST_TURNED_IN", "QuestSoundSelect", "QuestVolume", self.addon:GetModule("Sounds").defaultSounds[8], "QUEST_TURNED_IN_TRIGGERED") end
function core:HandleAchievementEarned() self:HandleEvent("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume", self.addon:GetModule("Sounds").defaultSounds[1], "ACHIEVEMENT_EARNED_TRIGGERED") end
function core:HandleHonorLevelUpdate() self:HandleEvent("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume", self.addon:GetModule("Sounds").defaultSounds[4], "HONOR_LEVEL_UPDATE_TRIGGERED") end
function core:HandleRenownLevelChanged() self:HandleEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume", self.addon:GetModule("Sounds").defaultSounds[6], "MAJOR_FACTION_RENOWN_LEVEL_CHANGED_TRIGGERED") end
function core:HandlePerksActivityCompleted() self:HandleEvent("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume", self.addon:GetModule("Sounds").defaultSounds[9], "PERKS_ACTIVITY_COMPLETED_TRIGGERED") end

function core:ReputationChatFrameHook()
    if self.addon.chatFrameHooked then return end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg) self:HandleReputationMessage(msg) end)
    self.addon.chatFrameHooked = true
end

function core:HandleReputationMessage(msg)
    self.addon:PrintDebug("INCOMING_CHAT_MESSAGE", msg)
    local rankFound = false
    local ranks = { "Exalted", "Revered", "Honored", "Friendly", "Neutral", "Unfriendly", "Hostile", "Hated", "Acquaintance", "Crony", "Accomplice", "Collaborator", "Accessory", "Abettor", "Conspirator", "Mastermind" }
    for _, rank in ipairs(ranks) do
        if msg:find(rank) then
            self.addon:PrintDebug("Rank found: " .. rank)
            self:ReputationRankIncrease(rank, msg)
            rankFound = true
            break
        end
    end
    if not rankFound then self.addon:PrintDebug("NO_RANK_FOUND") end
    return false
end

function core:ReputationRankIncrease(rank, msg)
    self:HandleEvent("REPUTATION_RANK_INCREASE", "RepSoundSelect", "RepVolume", self.addon:GetModule("Sounds").defaultSounds[6], "REPUTATION_RANK_INCREASE_TRIGGERED")
end

BLULib = BLULib or {}
BLULib.CoreModule = core