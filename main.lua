-- main.lua
-- The main entry point for the addon

local addonName = ...

-- Create the addon using our new library
local BLU = BLULib.Core.NewAddon(addonName)

function BLU:OnInitialize()
    self:Print("v" .. GetAddOnMetadata(addonName, "Version") .. " - Initialized!")

    -- Register modules
    self:RegisterModule("Core", BLULib.CoreModule)

    -- Register slash commands
    self:RegisterChatCommand("debug", function(self, args)
        BLULib.Utils.ToggleDebugMode(self)
    end)
    self:RegisterChatCommand("welcome", function(self, args)
        BLULib.Utils.ToggleWelcomeMessage(self)
    end)
    self:RegisterChatCommand("help", function(self, args)
        BLULib.Utils.DisplayBLUHelp(self)
    end)
end
