-- libs/events.lua
local function create_event_handler(addon)
    local frame = CreateFrame("Frame", addon.name .. "EventFrame")

    local registered_events = {}

    frame:SetScript("OnEvent", function(self, event, ...)
        if registered_events[event] then
            for _, callback in ipairs(registered_events[event]) do
                local success, err = pcall(callback, addon, ...)
                if not success then
                    addon:Print("Error in event handler for " .. event .. ": " .. tostring(err))
                end
            end
        end
    end)

    function addon:RegisterEvent(event, callback)
        if not registered_events[event] then
            registered_events[event] = {}
            frame:RegisterEvent(event)
        end
        table.insert(registered_events[event], callback)
    end

    function addon:UnregisterEvent(event)
        if registered_events[event] then
            registered_events[event] = nil
            frame:UnregisterEvent(event)
        end
    end
end

BLULib = BLULib or {}
BLULib.Events = {
    Create = create_event_handler
}
