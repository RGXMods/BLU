-- main.lua
print("BLU main.lua loaded")

local addonName = ...
local BLU = BLULib.Core.NewAddon(addonName)

function BLU:OnInitialize()
    BLULib.Localization.Create(self)
    self:RegisterModule("Sounds", BLULib.SoundsModule)
    BLULib.Database.Create(self, BLULib.OptionsModule.defaults)
    self:RegisterModule("Core", BLULib.CoreModule)
    self:RegisterModule("Options", BLULib.OptionsModule)
    self:RegisterModule("BattlePets", BLULib.BattlePetsModule)

    self:RegisterChatCommand("debug", BLULib.Utils.ToggleDebugMode)
    self:RegisterChatCommand("welcome", BLULib.Utils.ToggleWelcomeMessage)
    self:RegisterChatCommand("help", BLULib.Utils.DisplayBLUHelp)
    self:RegisterChatCommand("panel", function(self) self.optionsFrame:Show() end)

    self:Print("v" .. GetAddOnMetadata(addonName, "Version") .. " Initialized!")

    if self.db.profile.showWelcomeMessage then
        self:Print(self.L["WELCOME_MESSAGE"])
    end
end
