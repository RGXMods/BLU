--=====================================================================================
-- BLU Event Manager Module
-- Centralized event handling system
--=====================================================================================

local addonName, addonTable = ...
local EventManager = {}

-- Event storage
EventManager.events = {}
EventManager.frame = CreateFrame("Frame")

-- Initialize
function EventManager:Init()
    self.frame:SetScript("OnEvent", function(frame, event, ...)
        self:FireEvent(event, ...)
    end)
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "EventManager"))
end

-- Register event
function EventManager:RegisterEvent(event, callback, id)
    id = id or "anonymous"
    
    -- Register with WoW if first listener
    if not self.events[event] then
        self.events[event] = {}
        self.frame:RegisterEvent(event)
    end
    
    -- Store callback
    self.events[event][id] = callback
end

-- Unregister event
function EventManager:UnregisterEvent(event, id)
    id = id or "anonymous"
    
    if self.events[event] then
        self.events[event][id] = nil
        
        -- Unregister from WoW if no more listeners
        if not next(self.events[event]) then
            self.frame:UnregisterEvent(event)
            self.events[event] = nil
        end
    end
end

-- Fire event
function EventManager:FireEvent(event, ...)
    if self.events[event] then
        for id, callback in pairs(self.events[event]) do
            local success, err = pcall(callback, event, ...)
            if not success then
                BLU:PrintError(string.format("Event error in %s for %s: %s", event, id, err))
            end
        end
    end
end

-- Unregister all events for an ID
function EventManager:UnregisterAllEvents(id)
    for event, callbacks in pairs(self.events) do
        if callbacks[id] then
            callbacks[id] = nil
            
            if not next(callbacks) then
                self.frame:UnregisterEvent(event)
                self.events[event] = nil
            end
        end
    end
end

-- Export API to BLU
function BLU:RegisterEvent(event, callback, id)
    return EventManager:RegisterEvent(event, callback, id)
end

function BLU:UnregisterEvent(event, id)
    return EventManager:UnregisterEvent(event, id)
end

function BLU:FireEvent(event, ...)
    return EventManager:FireEvent(event, ...)
end

-- Export module
return EventManager