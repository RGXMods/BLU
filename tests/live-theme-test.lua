-- BLU follows the framework's beta global theme override: its own colours unchanged while the override is off,
-- the framework palette and main colour while it is on, live (the options body is rebuilt on a change).
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local override, listener = false, nil
local GOLD = { 1, 0.843, 0 }
local PALETTE = { surface = { 0.2, 0.2, 0.2 }, background = { 0.1, 0.1, 0.1 }, panelAlt = { 0.3, 0.3, 0.3 }, hover = { 0.4, 0.4, 0.4 },
  border = { 0.5, 0.5, 0.5 }, text = { 0.9, 0.9, 0.9 }, subtext = { 0.6, 0.6, 0.6 }, label = { 0.35, 0.35, 0.35 } }
_G.RGXDesign = {
  IsThemeOverride = function() return override end,
  GetColor = function(_, key) return PALETTE[key] end,
  RegisterBrand = function(_, id, own, style)
    return { id = id, style = style, OnChange = function(_, fn) listener = fn end, Build = function(_, fn) return fn() end,
      Resolve = function() if override then return { primary = GOLD, accent = GOLD }, "materialround" end return own, style end }
  end,
}
local rebuilt = 0
BLU = { Modules = {}, PrintDebug = function() end, PrintError = function() end, RebuildOptionsBody = function() rebuilt = rebuilt + 1 end }
_G.BLU = BLU
assert(loadfile("core/interface/design.lua"))("BLU")
local Design = BLU.Design
local held = Design.Colors.Primary

-- Override off: BLU's own colours, exactly.
Design:RefreshBrand()
local r, g, b, a = BLU.Color("fill", 0.06, 0.10, 0.16, 0.95)
check(r == 0.06 and g == 0.10 and b == 0.16 and a == 0.95, "override off: fills are BLU's own")
check(select("#", BLU.Color("text", 0.7, 0.7, 0.7)) == 3, "no alpha in, no alpha out")
check(held[1] == 0.02 and BLU.Hex() == "|cff05dffa", "override off: BLU cyan")
check(Design.ListSkin.surface ~= nil, "override off: dropdown lists keep BLU's palette")
check(Design:GetBrand() and Design:GetBrand().style == "framework", "BLU registers its brand in its own square style")

-- Override on: the framework's palette and main colour; status colours keep their meaning.
override = true
listener()
check(rebuilt == 1, "a theme change rebuilds the options body")
check(held[1] == 1 and BLU.Hex() == "|cffffd700", "override on: the live primary follows the framework colour")
r, g, b = BLU.Color("fill", 0.06, 0.10, 0.16, 0.95)
check(r == PALETTE.surface[1], "override on: navy fills become the framework surface")
r = BLU.Color("border", 0.14, 0.20, 0.28, 1)
check(r == PALETTE.border[1], "override on: borders become the framework border")
r = BLU.Color("text", 0.84, 0.84, 0.84, 1)
check(r == PALETTE.text[1], "override on: light text becomes the framework text colour")
r = BLU.Color("text", 0.02, 0.87, 0.98)
check(r == 1, "override on: BLU cyan text becomes the main colour")
r, g, b = BLU.Color("fill", 0.15, 0.05, 0.05, 0.95)
check(r == 0.15 and g == 0.05, "override on: red warning fills keep their colour")
r, g = BLU.Color("text", 1.0, 0.82, 0.18)
check(r == 1.0 and g == 0.82, "override on: gold highlights keep their colour")
check(Design.ListSkin.surface == nil and Design.ListSkin.border == nil, "override on: dropdown lists take the brand colours")

override = false
listener()
check(held[1] == 0.02 and Design.ListSkin.surface ~= nil and rebuilt == 2, "override off again: BLU's own look, rebuilt")

-- Tabs take the framework's tab look while the override is on.
do
  local fh = assert(io.open("core/interface/options/tabs.lua")); local tabsSrc = fh:read("*a"); fh:close()
  check(tabsSrc:find("D:IsThemeOverride() and UIfw and UIfw.SkinTab", 1, true) and tabsSrc:find("UIfw:SkinTab(button)", 1, true), "under the override the tabs use the framework's tab skin")
  check(tabsSrc:find('UIfw:PaintTab(self, active and "active" or "idle", Primary())', 1, true), "the tab states are painted by the framework")
end
io.write("live-theme OK\n")
