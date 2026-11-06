--=====================================================================================
-- BLU - interface/minimap.lua
-- Minimap button via RGX-Framework, with profile-backed visibility and angle
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local Minimap = {}
BLU.Modules["minimap"] = Minimap

local MINIMAP_ICON_TEXTURE = "Interface\\AddOns\\BLU\\media\\Textures\\icon.tga"
local CHAT_PREFIX = "|cff00ccffBLU:|r"

-- Proxy so the framework button reads and writes the active profile even
-- after a profile switch, instead of holding a stale table reference.
local minimapStorage = setmetatable({}, {
    __index = function(_, key)
        if BLU.db then return BLU.db[key] end
    end,
    __newindex = function(_, key, value)
        if BLU.db then BLU.db[key] = value end
    end,
})

-- Single owner of the icon's visible state: every path (options checkbox,
-- /blu icon, Ctrl+Right-click, login) goes through here so the saved value, the
-- button and the options checkbox can never disagree.
function Minimap:SetIconVisible(show)
    show = show and true or false
    if BLU.db then BLU.db.minimapIconEnabled = show end
    if self.button then
        self.button:SetVisible(show)
    end
    if self.optionCheckbox and self.optionCheckbox.SetChecked then
        self.optionCheckbox:SetChecked(show)
    end
end

function Minimap:Init()
    if self.button then
        self:SetIconVisible(BLU.db and BLU.db.minimapIconEnabled ~= false)
        return
    end

    local RGX = _G.RGXFramework
    if not RGX or not RGX.GetMinimap or not BLU.db then
        return
    end

    local MM = RGX:GetMinimap()
    self.button = MM:Create({
        name = "BLU_MinimapButton",
        icon = MINIMAP_ICON_TEXTURE,
        defaultAngle = 220,
        storage = minimapStorage,
        angleKey = "minimapAngle",
        enabledKey = "minimapIconEnabled",
        tooltip = {
            title = "|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel-|r |cff05dffaU|r|cffffffffp|r|cff05dffa!|r",
            getLines = function()
                local enabled = BLU.db and BLU.db.enabled ~= false
                return {
                    { left = "|cffffffffStatus|r", right = enabled and "|cff00ff00Enabled|r" or "|cffff0000Disabled|r" },
                    { left = "|cff05dffaLeft-Click|r", right = "|cffffffffOpen options|r" },
                    { left = "|cff4ecdc4Left-Drag|r", right = "|cffffffffMove around minimap|r" },
                    { left = "|cffe74c3cCtrl+Right-Click|r", right = "|cffffffffHide minimap icon|r" },
                }
            end,
        },
        onLeftClick = function()
            if BLU.OpenOptions then
                BLU:OpenOptions()
            end
        end,
        onCtrlRight = function()
            Minimap:SetIconVisible(false)
            BLU:Print("Minimap icon |cffff0000hidden|r. Use |cffffffff/blu icon on|r to show it again.")
        end,
    })

    self:SetIconVisible(BLU.db.minimapIconEnabled ~= false)
end
