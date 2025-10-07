-- main.lua
-- The main entry point for the addon

local addonName = ...

-- Create the addon using our new library
local BLU = BLULib.Core.NewAddon(addonName)

function BLU:OnInitialize()
    self:Print("v" .. GetAddOnMetadata(addonName, "Version") .. " - Initialized!")
end
