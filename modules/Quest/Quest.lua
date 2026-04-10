--=====================================================================================
-- BLU Quest Module
-- Handles quest accept and turn-in sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local Quest = {}

local QUEST_EVENT_ID_ACCEPTED = "quest_accepted"
local QUEST_EVENT_ID_TURNED_IN = "quest_turned_in"
local QUEST_EVENT_ID_COMPLETE = "quest_complete"
local QUEST_EVENT_ID_PROGRESS = "quest_watch_update"
local QUEST_EVENT_ID_LOG_UPDATE = "quest_log_update"

Quest.progressCooldowns = Quest.progressCooldowns or {}
Quest.objectiveProgressCache = Quest.objectiveProgressCache or {}

local function ResolveQuestID(questRef)
    if type(questRef) ~= "number" or questRef <= 0 then
        return nil
    end

    if C_QuestLog and C_QuestLog.GetLogIndexForQuestID then
        local logIndex = C_QuestLog.GetLogIndexForQuestID(questRef)
        if type(logIndex) == "number" and logIndex > 0 then
            return questRef
        end
    end

    if C_QuestLog and C_QuestLog.GetQuestIDForQuestWatchIndex then
        local watchedQuestID = C_QuestLog.GetQuestIDForQuestWatchIndex(questRef)
        if type(watchedQuestID) == "number" and watchedQuestID > 0 then
            return watchedQuestID
        end
    end

    if C_QuestLog and C_QuestLog.GetInfo then
        local info = C_QuestLog.GetInfo(questRef)
        if info and type(info.questID) == "number" and info.questID > 0 then
            return info.questID
        end
    end

    return questRef
end

local function BuildObjectiveProgressSnapshot(questID)
    if type(questID) ~= "number" or questID <= 0 then
        return nil
    end

    if not (C_QuestLog and C_QuestLog.GetQuestObjectives) then
        return nil
    end

    local objectives = C_QuestLog.GetQuestObjectives(questID)
    if type(objectives) ~= "table" then
        return nil
    end

    local snapshot = {}
    local hasEntries = false

    for index, objective in ipairs(objectives) do
        if type(objective) == "table" then
            local fulfilled = tonumber(objective.numFulfilled) or 0
            local required = tonumber(objective.numRequired) or 0
            local finished = objective.finished == true
            local text = objective.text or ("objective_" .. tostring(index))
            local percent = tonumber(string.match(text, "(%d+)%%")) or nil

            snapshot[index] = {
                fulfilled = fulfilled,
                required = required,
                finished = finished,
                percent = percent,
                text = text,
            }
            hasEntries = true
        end
    end

    if not hasEntries then
        return nil
    end

    return snapshot
end

local function DidObjectiveProgressIncrease(previousSnapshot, currentSnapshot)
    if type(previousSnapshot) ~= "table" or type(currentSnapshot) ~= "table" then
        return false
    end

    for index, current in pairs(currentSnapshot) do
        local previous = previousSnapshot[index]
        if previous then
            if (current.percent or 0) > (previous.percent or 0) then
                return true
            end
            if (current.fulfilled or 0) > (previous.fulfilled or 0) then
                return true
            end
            if current.finished and not previous.finished then
                return true
            end
        end
    end

    return false
end

function Quest:RefreshObjectiveProgressCache()
    if not (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo) then
        return
    end

    local refreshed = {}
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    if type(numEntries) ~= "number" or numEntries <= 0 then
        self.objectiveProgressCache = refreshed
        return
    end

    for logIndex = 1, numEntries do
        local info = C_QuestLog.GetInfo(logIndex)
        local questID = info and info.questID
        if type(questID) == "number" and questID > 0 then
            refreshed[questID] = BuildObjectiveProgressSnapshot(questID)
        end
    end

    self.objectiveProgressCache = refreshed
end

-- Module initialization
function Quest:Init()
    -- Quest events
    BLU:RegisterEvent("QUEST_ACCEPTED", function(...) self:OnQuestAccepted(...) end, QUEST_EVENT_ID_ACCEPTED)
    BLU:RegisterEvent("QUEST_TURNED_IN", function(...) self:OnQuestTurnedIn(...) end, QUEST_EVENT_ID_TURNED_IN)
    BLU:RegisterEvent("QUEST_COMPLETE", function(...) self:OnQuestComplete(...) end, QUEST_EVENT_ID_COMPLETE)
    BLU:RegisterEvent("QUEST_WATCH_UPDATE", function(...) self:OnQuestWatchUpdate(...) end, QUEST_EVENT_ID_PROGRESS)
    BLU:RegisterEvent("QUEST_LOG_UPDATE", function(...) self:OnQuestLogUpdate(...) end, QUEST_EVENT_ID_LOG_UPDATE)
    
    -- Track if we're at a quest giver
    self.atQuestGiver = false
    self:RefreshObjectiveProgressCache()
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Quest"))
end

-- Cleanup function
function Quest:Cleanup()
    BLU:UnregisterEvent("QUEST_ACCEPTED", QUEST_EVENT_ID_ACCEPTED)
    BLU:UnregisterEvent("QUEST_TURNED_IN", QUEST_EVENT_ID_TURNED_IN)
    BLU:UnregisterEvent("QUEST_COMPLETE", QUEST_EVENT_ID_COMPLETE)
    BLU:UnregisterEvent("QUEST_WATCH_UPDATE", QUEST_EVENT_ID_PROGRESS)
    BLU:UnregisterEvent("QUEST_LOG_UPDATE", QUEST_EVENT_ID_LOG_UPDATE)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Quest"))
end

-- Quest accepted handler
function Quest:OnQuestAccepted(event, questId)
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if BLU.db.modules and BLU.db.modules.quest == false then return end
    
    -- Play quest accept sound
    BLU:PlayCategorySound("questaccept")
    if type(questId) == "number" and questId > 0 then
        self.objectiveProgressCache[questId] = BuildObjectiveProgressSnapshot(questId)
    end
    
    if BLU.db.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_ACCEPTED", questTitle))
    end
end

-- Quest turned in handler
function Quest:OnQuestTurnedIn(event, questId, xpReward, moneyReward)
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if BLU.db.modules and BLU.db.modules.quest == false then return end
    
    -- Play quest turn-in sound
    BLU:PlayCategorySound("questturnin")
    if type(questId) == "number" and questId > 0 then
        self.objectiveProgressCache[questId] = nil
        self.progressCooldowns[questId] = nil
    end
    
    if BLU.db.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_COMPLETED", questTitle))
    end
end

-- Quest complete handler (shows complete dialog)
function Quest:OnQuestComplete(event)
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if BLU.db.modules and BLU.db.modules.quest == false then return end

    -- This fires when you reach a quest giver with a completed quest
    self.atQuestGiver = true
    BLU:PlayCategorySound("questcomplete")
    
    -- Reset flag after a short delay
    C_Timer.After(1, function()
        self.atQuestGiver = false
    end)
end

function Quest:OnQuestWatchUpdate(event, questID)
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if BLU.db.modules and BLU.db.modules.quest == false then return end
    questID = ResolveQuestID(questID)
    if type(questID) ~= "number" or questID <= 0 then return end

    local now = GetTime and GetTime() or 0
    local lastAt = self.progressCooldowns[questID]
    if lastAt and (now - lastAt) < 0.25 then
        return
    end
    self.progressCooldowns[questID] = now

    BLU:PlayCategorySound("questprogress")
    self.objectiveProgressCache[questID] = BuildObjectiveProgressSnapshot(questID) or self.objectiveProgressCache[questID]

    if BLU.db.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_PROGRESS", questTitle))
    end
end

function Quest:OnQuestLogUpdate()
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if BLU.db.modules and BLU.db.modules.quest == false then return end
    if not (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetInfo) then return end

    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    if type(numEntries) ~= "number" or numEntries <= 0 then
        return
    end

    for logIndex = 1, numEntries do
        local info = C_QuestLog.GetInfo(logIndex)
        local questID = info and info.questID
        if type(questID) == "number" and questID > 0 then
            local currentSnapshot = BuildObjectiveProgressSnapshot(questID)
            local previousSnapshot = self.objectiveProgressCache[questID]
            self.objectiveProgressCache[questID] = currentSnapshot or previousSnapshot

            if currentSnapshot and previousSnapshot and DidObjectiveProgressIncrease(previousSnapshot, currentSnapshot) then
                self:OnQuestWatchUpdate("QUEST_LOG_UPDATE", questID)
            end
        end
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["quest"] = Quest

-- Export module
return Quest
