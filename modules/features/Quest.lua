--=====================================================================================
-- BLU Quest Module
-- Handles quest accept and turn-in sounds
--=====================================================================================

local addonName, addonTable = ...
local Quest = {}

-- Module initialization
function Quest:Init()
    -- Quest events
    BLU:RegisterEvent("QUEST_ACCEPTED", function(...) self:OnQuestAccepted(...) end)
    BLU:RegisterEvent("QUEST_TURNED_IN", function(...) self:OnQuestTurnedIn(...) end)
    BLU:RegisterEvent("QUEST_COMPLETE", function(...) self:OnQuestComplete(...) end)
    
    -- Track if we're at a quest giver
    self.atQuestGiver = false
    
    BLU:PrintDebug("Quest module initialized")
end

-- Cleanup function
function Quest:Cleanup()
    BLU:UnregisterEvent("QUEST_ACCEPTED")
    BLU:UnregisterEvent("QUEST_TURNED_IN")
    BLU:UnregisterEvent("QUEST_COMPLETE")
    BLU:PrintDebug("Quest module cleaned up")
end

-- Quest accepted handler
function Quest:OnQuestAccepted(event, questId)
    if not BLU.db.profile.enableQuest then return end
    
    local soundName = BLU.db.profile.questAcceptSound
    local volume = BLU.db.profile.questVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
    
    if BLU.debugMode then
        local questTitle = C_QuestLog.GetTitleForQuestID(questId) or "Unknown Quest"
        BLU:Print(string.format("Quest accepted: %s", questTitle))
    end
end

-- Quest turned in handler
function Quest:OnQuestTurnedIn(event, questId, xpReward, moneyReward)
    if not BLU.db.profile.enableQuest then return end
    
    local soundName = BLU.db.profile.questTurnInSound
    local volume = BLU.db.profile.questVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
    
    if BLU.debugMode then
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

-- Export module
return Quest