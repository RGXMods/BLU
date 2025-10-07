-- modules/options.lua
local options = {}

function options:OnEnable()
    self.addon:Print("Options module enabled!")
end

BLULib = BLULib or {}
BLULib.OptionsModule = options
