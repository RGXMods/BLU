-- modules/core.lua
local core = {}

function core:OnEnable()
    self.addon:Print("Core module enabled!")
end

BLULib = BLULib or {}
BLULib.CoreModule = core
