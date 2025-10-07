-- libs/localization.lua
local L = {}

function L:Create(addon)
    addon.L = setmetatable({}, { __index = function(t, k)
        local locale = GetLocale()
        if BLULib.locale and BLULib.locale[locale] and BLULib.locale[locale][k] then
            return BLULib.locale[locale][k]
        elseif BLULib.locale and BLULib.locale["enUS"] and BLULib.locale["enUS"][k] then
            return BLULib.locale["enUS"][k]
        else
            return k
        end
    end })
end

BLULib = BLULib or {}
BLULib.Localization = L
