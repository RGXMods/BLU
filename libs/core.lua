-- libs/core.lua
local function print_message(name, message)
    print("|cff05dffa" .. name .. "|r: " .. message)
end

local addon_methods = {
    modules = {},
    enabled_modules = {},
    eventQueue = {},
    isProcessingQueue = false
}

function addon_methods:Print(message)
    print_message(self.name, message)
end

function addon_methods:OnInitialize()
    self:Print("Initializing.")
    -- This will be overridden by the main addon file
end

function addon_methods:OnEnable()
    self:Print("Enabling.")
    for name, module in pairs(self.modules) do
        if module.OnEnable then
            module:OnEnable()
            self.enabled_modules[name] = true
        end
    end
end

function addon_methods:RegisterModule(name, module)
    self.modules[name] = module
    module.addon = self -- give module access to the parent addon object
end

function addon_methods:ProcessEventQueue()
    if #self.eventQueue == 0 then
        self.isProcessingQueue = false
        return
    end

    local event = table.remove(self.eventQueue, 1)

    if event.debugMessage then
        self:PrintDebugMessage(event.debugMessage)
    else
        self:PrintDebugMessage("DEBUG_MESSAGE_MISSING")
    end

    local sound = self:SelectSound(self.db.profile[event.soundSelectKey])
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end

    local volumeLevel = self.db.profile[event.volumeKey]
    if volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebugMessage("INVALID_VOLUME_LEVEL", tostring(volumeLevel))
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end

    self:PlaySelectedSound(sound, volumeLevel, event.defaultSound)

    C_Timer.After(1, function() self:ProcessEventQueue() end)
end

-- The factory function to create a new addon object
local function NewAddon(name)
    local addon = {}
    setmetatable(addon, { __index = addon_methods })
    addon.name = name

    -- Create the main frame to handle events
    BLULib.Events.Create(addon)

    addon:RegisterEvent("ADDON_LOADED", function(self, event, arg1)
        if arg1 == name then
            self:UnregisterEvent("ADDON_LOADED")
            addon:OnInitialize()
            addon:OnEnable()
        end
    end)

    return addon
end

-- Expose the NewAddon function to the global scope for other files
BLULib = BLULib or {}
BLULib.Core = {
    NewAddon = NewAddon
}
