-- libs/core.lua
local function print_message(name, message)
    print("|cff05dffa" .. name .. "|r: " .. message)
end

local addon_methods = {
    modules = {},
    enabled_modules = {}
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

-- The factory function to create a new addon object
local function NewAddon(name)
    local addon = {}
    setmetatable(addon, { __index = addon_methods })
    addon.name = name

    -- Create the main frame to handle events
    local frame = CreateFrame("Frame", name .. "CoreFrame")
    frame:RegisterEvent("ADDON_LOADED")

    frame:SetScript("OnEvent", function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == name then
            self:UnregisterEvent("ADDON_LOADED")
            addon:OnInitialize()
            addon:OnEnable()
        end
    end)

    addon.frame = frame
    return addon
end

-- Expose the NewAddon function to the global scope for other files
BLULib = BLULib or {}
BLULib.Core = {
    NewAddon = NewAddon
}
