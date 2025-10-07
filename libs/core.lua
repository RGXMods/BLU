-- libs/core.lua
local addon_methods = {
    modules = {},
    enabled_modules = {},
    eventQueue = {},
    isProcessingQueue = false,
    slashCommands = {},
    prefix = "|cff05dffaBLU|r: ",
    debugPrefix = "|cffff0000[DEBUG]|r "
}

function addon_methods:Print(message)
    print(self.prefix .. message)
end

function addon_methods:PrintDebug(key, ...)
    if self.db and self.db.profile.debugMode and self.L[key] then
        print(self.prefix .. self.debugPrefix .. self.L[key]:format(...))
    end
end

function addon_methods:OnInitialize()
    self:Print("Initializing.")
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
    module.addon = self
end

function addon_methods:GetModule(name)
    return self.modules[name]
end

function addon_methods:RegisterChatCommand(command, handler)
    self.slashCommands[command] = handler
end

function addon_methods:HandleSlashCommands(input)
    input = input:trim():lower()
    local command, args = input:match("^(%S*)%s*(.*)$")

    if command == "" then
        if self.optionsFrame:IsShown() then
            self.optionsFrame:Hide()
        else
            self.optionsFrame:Show()
        end
        return
    end

    if self.slashCommands[command] then
        self.slashCommands[command](self, args)
    else
        self:Print(self.L["UNKNOWN_SLASH_COMMAND"])
    end
end

function addon_methods:ProcessEventQueue()
    if #self.eventQueue == 0 then
        self.isProcessingQueue = false
        return
    end
    local event = table.remove(self.eventQueue, 1)
    self:PrintDebug("Processing event: " .. event.eventName)
    local sound = BLULib.Utils.SelectSound(self, self.db.profile[event.soundSelectKey])
    if not sound then
        self:PrintDebug("ERROR_SOUND_NOT_FOUND", tostring(event.soundSelectKey))
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end
    local volumeLevel = self.db.profile[event.volumeKey]
    if volumeLevel < 0 or volumeLevel > 3 then
        self:PrintDebug("INVALID_VOLUME_LEVEL", tostring(volumeLevel))
        C_Timer.After(1, function() self:ProcessEventQueue() end)
        return
    end
    BLULib.Utils.PlaySelectedSound(self, sound, volumeLevel, event.defaultSound)
    C_Timer.After(1, function() self:ProcessEventQueue() end)
end

local function NewAddon(name)
    local addon = {}
    setmetatable(addon, { __index = addon_methods })
    addon.name = name

    BLULib.Events.Create(addon)

    addon:RegisterEvent("ADDON_LOADED", function(self, event, arg1)
        if arg1 == name then
            self:UnregisterEvent("ADDON_LOADED")
            addon:OnInitialize()
            addon:OnEnable()
        end
    end)

    SLASH_BLU1 = "/blu"
    SlashCmdList["BLU"] = function(input)
        addon:HandleSlashCommands(input)
    end

    return addon
end

BLULib = BLULib or {}
BLULib.Core = { NewAddon = NewAddon }
