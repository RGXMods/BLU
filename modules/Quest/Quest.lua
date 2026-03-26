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

Quest.progressCooldowns = Quest.progressCooldowns or {}

-- Module initialization
function Quest:Init()
    -- Quest events
    BLU:RegisterEvent("QUEST_ACCEPTED", function(...) self:OnQuestAccepted(...) end, QUEST_EVENT_ID_ACCEPTED)
    BLU:RegisterEvent("QUEST_TURNED_IN", function(...) self:OnQuestTurnedIn(...) end, QUEST_EVENT_ID_TURNED_IN)
    BLU:RegisterEvent("QUEST_COMPLETE", function(...) self:OnQuestComplete(...) end, QUEST_EVENT_ID_COMPLETE)
    BLU:RegisterEvent("QUEST_WATCH_UPDATE", function(...) self:OnQuestWatchUpdate(...) end, QUEST_EVENT_ID_PROGRESS)
    
    -- Track if we're at a quest giver
    self.atQuestGiver = false
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Quest"))
end

-- Cleanup function
function Quest:Cleanup()
    BLU:UnregisterEvent("QUEST_ACCEPTED", QUEST_EVENT_ID_ACCEPTED)
    BLU:UnregisterEvent("QUEST_TURNED_IN", QUEST_EVENT_ID_TURNED_IN)
    BLU:UnregisterEvent("QUEST_COMPLETE", QUEST_EVENT_ID_COMPLETE)
    BLU:UnregisterEvent("QUEST_WATCH_UPDATE", QUEST_EVENT_ID_PROGRESS)
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Quest"))
end

-- Quest accepted handler
function Quest:OnQuestAccepted(event, questId)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.quest == false then return end
    
    -- Play quest accept sound
    BLU:PlayCategorySound("questaccept")
    
    if BLU.db.profile.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_ACCEPTED", questTitle))
    end
end

-- Quest turned in handler
function Quest:OnQuestTurnedIn(event, questId, xpReward, moneyReward)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.quest == false then return end
    
    -- Play quest turn-in sound
    BLU:PlayCategorySound("questturnin")
    
    if BLU.db.profile.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_COMPLETED", questTitle))
    end
end

-- Quest complete handler (shows complete dialog)
function Quest:OnQuestComplete(event)
    -- This fires when you reach a quest giver with a completed quest
    self.atQuestGiver = true
    
    -- Reset flag after a short delay
    C_Timer.After(1, function()
        self.atQuestGiver = false
    end)
end

function Quest:OnQuestWatchUpdate(event, questID)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.quest == false then return end
    if type(questID) ~= "number" or questID <= 0 then return end

    local now = GetTime and GetTime() or 0
    local lastAt = self.progressCooldowns[questID]
    if lastAt and (now - lastAt) < 0.25 then
        return
    end
    self.progressCooldowns[questID] = now

    BLU:PlayCategorySound("questprogress")

    if BLU.db.profile.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or BLU:Loc("UNKNOWN")
        BLU:Print(BLU:Loc("DEBUG_QUEST_PROGRESS", questTitle))
    end
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["quest"] = Quest

-- Export module
return Quest
