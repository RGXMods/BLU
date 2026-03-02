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

-- Module initialization
function Quest:Init()
    -- Quest events
    BLU:RegisterEvent("QUEST_ACCEPTED", function(...) self:OnQuestAccepted(...) end, QUEST_EVENT_ID_ACCEPTED)
    BLU:RegisterEvent("QUEST_TURNED_IN", function(...) self:OnQuestTurnedIn(...) end, QUEST_EVENT_ID_TURNED_IN)
    BLU:RegisterEvent("QUEST_COMPLETE", function(...) self:OnQuestComplete(...) end, QUEST_EVENT_ID_COMPLETE)
    
    -- Track if we're at a quest giver
    self.atQuestGiver = false
    
    BLU:PrintDebug("Quest module initialized")
end

-- Cleanup function
function Quest:Cleanup()
    BLU:UnregisterEvent("QUEST_ACCEPTED", QUEST_EVENT_ID_ACCEPTED)
    BLU:UnregisterEvent("QUEST_TURNED_IN", QUEST_EVENT_ID_TURNED_IN)
    BLU:UnregisterEvent("QUEST_COMPLETE", QUEST_EVENT_ID_COMPLETE)
    BLU:PrintDebug("Quest module cleaned up")
end

-- Quest accepted handler
function Quest:OnQuestAccepted(event, questId)
    if not BLU.db or not BLU.db.profile then return end
    if not BLU.db.profile.enabled then return end
    if BLU.db.profile.modules and BLU.db.profile.modules.quest == false then return end
    
    -- Play quest accept sound
    BLU:PlayCategorySound("questaccept")
    
    if BLU.db.profile.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or "Unknown Quest"
        BLU:Print(string.format("Quest accepted: %s", questTitle))
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
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or "Unknown Quest"
        BLU:Print(string.format("Quest completed: %s", questTitle))
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

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["quest"] = Quest

-- Export module
return Quest
