-- libs/utils.lua
local utils = {}

function utils:ToggleDebugMode()
    self.addon.debugMode = not self.addon.debugMode
    self.addon.db.profile.debugMode = self.addon.debugMode

    local statusMessage = self.addon.debugMode and BLU_L["DEBUG_MODE_ENABLED"] or BLU_L["DEBUG_MODE_DISABLED"]

    print(BLU_PREFIX .. statusMessage)

    if self.addon.debugMode then
        self:PrintDebugMessage("DEBUG_MODE_TOGGLED", tostring(self.addon.debugMode))
    end
end

function utils:PrintDebugMessage(key, ...)
    if self.addon.debugMode and BLU_L[key] then
        self:DebugMessage(BLU_L[key]:format(...))
    end
end

function utils:DebugMessage(message)
    if self.addon.debugMode then
        print(BLU_PREFIX .. DEBUG_PREFIX .. message)
    end
end

BLULib = BLULib or {}
BLULib.Utils = utils
