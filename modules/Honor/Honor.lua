--=====================================================================================
-- BLU Honor Rank Module
-- Handles Honor rank up sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local honor = {}

-- Module variables
honor.currentHonorLevel = nil

-- Module initialization
function honor:Init()
    -- Honor events
    BLU:RegisterEvent("HONOR_LEVEL_UPDATE", function(...) self:OnHonorLevelUpdate(...) end)
    BLU:RegisterEvent("PLAYER_PVP_RANK_CHANGED", function(...) self:OnPvPRankChanged(...) end)
    
    -- Chat message filter for honor gains
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(...) return self:OnSystemMessage(...) end)
    
    -- Get current honor level
    self:UpdateCurrentHonorLevel()
    
    BLU:PrintDebug("HonorRank module initialized")
end

-- Cleanup function
function honor:Cleanup()
    BLU:UnregisterEvent("HONOR_LEVEL_UPDATE")
    BLU:UnregisterEvent("PLAYER_PVP_RANK_CHANGED")
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnSystemMessage)
    
    BLU:PrintDebug("HonorRank module cleaned up")
end

-- Update current honor level
function honor:UpdateCurrentHonorLevel()
    if UnitLevel("player") >= 10 then
        self.currentHonorLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
    end
end

-- Honor level update handler
function honor:OnHonorLevelUpdate(event, isLevelUp)
    if not BLU.db.profile.enableHonorRank then return end
    if not isLevelUp then return end
    
    self:PlayHonorSound()
    
    if BLU.debugMode then
        local newLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
        BLU:Print(string.format("Honor level increased to %d!", newLevel))
    end
end

-- PvP rank changed handler
function honor:OnPvPRankChanged(event)
    if not BLU.db.profile.enableHonorRank then return end
    
    -- Check if honor level actually increased
    local newLevel = UnitHonorLevel and UnitHonorLevel("player") or 0
    
    if self.currentHonorLevel and newLevel > self.currentHonorLevel then
        self:PlayHonorSound()
        
        if BLU.debugMode then
            BLU:Print(string.format("PvP Honor rank increased: %d -> %d", self.currentHonorLevel, newLevel))
        end
    end
end
-- System message handler
function honor:OnSystemMessage(chatFrame, event, msg)
    if not BLU.db or not BLU.db.profile or not BLU.db.profile.enableHonorRank then return false end
    
    -- Check for honor rank messages
    local patterns = {
        "You have earned the rank of",
        "You've advanced to Honor Level",
        "Honor Level %d+ achieved",
        "New Honor Rank:"
    }
    
    for _, pattern in ipairs(patterns) do
        if msg:find(pattern) then
            self:PlayHonorSound()
            
            if BLU.debugMode then
                BLU:Print("Honor rank increased!")
            end
            
            break
        end
    end
    
    return false
end

-- Play honor rank sound
function honor:PlayHonorSound()
    BLU:PlayCategorySound("honorrank")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["honor"] = honor
