--=====================================================================================
-- BLU Delve Companion Module
-- Handles Delve Companion level up sounds (TWW feature)
--=====================================================================================

local addonName, BLU = ...
local DelveCompanion = {}

-- Module initialization
function DelveCompanion:Init()
    -- Hook into system messages for Delve Companion
    -- ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(...) return self:OnSystemMessage(...) end)
    
    -- Register for Delve-specific events if they exist
    -- if C_DelvesUI then
    --     BLU:RegisterEvent("DELVES_COMPANION_LEVEL_UP", function(...) self:OnCompanionLevelUp(...) end)
    -- end
    
    BLU:PrintDebug("DelveCompanion module initialized")
end

-- Cleanup function
function DelveCompanion:Cleanup()
    -- ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.OnSystemMessage)
    
    -- if C_DelvesUI then
    --     BLU:UnregisterEvent("DELVES_COMPANION_LEVEL_UP")
    -- end
    
    BLU:PrintDebug("DelveCompanion module cleaned up")
end

-- System message handler
function DelveCompanion:OnSystemMessage(chatFrame, event, msg)
    if not BLU.db.profile.enableDelveCompanion then return false end
    
    -- Check for Delve Companion level up messages
    -- These patterns may need adjustment based on actual game messages
    local patterns = {
        "Your Delve Companion has reached level",
        "Delve Companion level increased",
        "gains a level!.*Delve",
        "has leveled up!.*Delve"
    }
    
    for _, pattern in ipairs(patterns) do
        if msg:find(pattern) then
            self:PlayDelveSound()
            
            if BLU.debugMode then
                BLU:Print("Delve Companion leveled up!")
            end
            
            break
        end
    end
    
    return false
end

-- Delve companion level up handler (if API exists)
function DelveCompanion:OnCompanionLevelUp(event, companionID, newLevel)
    if not BLU.db.profile.enableDelveCompanion then return end
    
    self:PlayDelveSound()
    
    if BLU.debugMode then
        BLU:Print(string.format("Delve Companion reached level %d!", newLevel))
    end
end

-- Play Delve Companion sound
function DelveCompanion:PlayDelveSound()
    local soundName = BLU.db.profile.delveCompanionSound
    local volume = BLU.db.profile.delveCompanionVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["DelveCompanion"] = DelveCompanion

-- Export module
return DelveCompanion
