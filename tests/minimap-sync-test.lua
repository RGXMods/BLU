-- Every way of hiding or showing the minimap icon must leave the saved value, the
-- button and the options checkbox in agreement. Runs the real core/interface/minimap.lua.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local created
local button = { visible = true }
function button:SetVisible(v) self.visible = v end
local MM = { Create = function(_, opts) created = opts; return button end }
_G.RGXFramework = { GetMinimap = function() return MM end }
local printed = {}
local BLU = { Modules = {}, db = { minimapIconEnabled = true }, Print = function(_, m) printed[#printed + 1] = m end, PrintDebug = function() end }
_G.BLU = BLU

local chunk = assert(loadfile("core/interface/minimap.lua"))
chunk("BLU")
local Minimap = BLU.Modules.minimap
Minimap:Init()
check(created and created.onCtrlRight, "button created with a Ctrl+Right handler")

local checkbox = { checked = true }
function checkbox:SetChecked(v) self.checked = v end
Minimap.optionCheckbox = checkbox

created.onCtrlRight(button)
check(BLU.db.minimapIconEnabled == false, "Ctrl+Right-click saves hidden")
check(button.visible == false, "Ctrl+Right-click hides the button")
check(checkbox.checked == false, "the options checkbox follows Ctrl+Right-click")

Minimap:SetIconVisible(true)
check(BLU.db.minimapIconEnabled == true and button.visible == true and checkbox.checked == true, "showing updates value, button and checkbox together")

-- Works before the options panel has ever been built.
Minimap.optionCheckbox = nil
Minimap:SetIconVisible(false)
check(BLU.db.minimapIconEnabled == false and button.visible == false, "works without an options panel")

-- A profile switch replaces BLU.db: the next toggle must write the active profile.
BLU.db = { minimapIconEnabled = true }
Minimap:SetIconVisible(false)
check(BLU.db.minimapIconEnabled == false, "writes go to the current profile table")

print("minimap-sync-test OK")
