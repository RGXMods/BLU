-- main.lua
-- The main entry point for the addon

local addonName = ...

-- Create the addon using our new library
local BLU = BLULib.Core.NewAddon(addonName)

function BLU:OnInitialize()
    self:Print("v" .. GetAddOnMetadata(addonName, "Version") .. " - Initialized!")

    -- Initialize localization
    BLULib.Localization.Create(self)

    -- Initialize the database
    BLULib.Database.Create(self, BLULib.OptionsModule.defaults)

    -- Register modules
    self:RegisterModule("Core", BLULib.CoreModule)
    self:RegisterModule("Options", BLULib.OptionsModule)

    -- Create the options panel
    BLULib.Options.Create(self)

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
    self:RegisterChatCommand("panel", function(self, args)
        if self.optionsFrame:IsShown() then
            self.optionsFrame:Hide()
        else
            self.optionsFrame:Show()
        end
    end)

    -- Display welcome message
    if self.db.profile.showWelcomeMessage then
        self:Print(self.L["WELCOME_MESSAGE"])
        self:Print(self.L["VERSION"] .. ": |cff8080ff" .. GetAddOnMetadata(addonName, "Version") .. "|r")
    end
end
