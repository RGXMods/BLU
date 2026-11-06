-- The per-sound volume slider must re-place its fill and thumb from the control's
-- current width, not the width it had when the value was last applied.
local f = assert(io.open("core/interface/options/sound_panel.lua", "rb"))
local source = f:read("*a")
f:close()
local first = assert(source:find("local function getVolume()", 1, true), "getVolume not found")
local last = assert(source:find("volumeControl:Hide()", first, true), "volumeControl:Hide not found")
local body = source:sub(first, last + #"volumeControl:Hide()" - 1)

local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

-- Minimal widget fixtures
local function region()
  local r = { points = {}, shown = true, width = 0 }
  function r:SetHeight() end
  function r:SetSize() end
  function r:SetPoint(...) self.points[#self.points + 1] = { ... } end
  function r:ClearAllPoints() self.points = {} end
  function r:SetAllPoints() end
  function r:SetColorTexture() end
  function r:SetTexture() end
  function r:SetVertexColor() end
  function r:SetTextColor() end
  function r:SetWidth(w) self.width = w end
  function r:GetWidth() return self.width end
  function r:SetText(t) self.text = t end
  function r:Show() self.shown = true end
  function r:Hide() self.shown = false end
  function r:SetScript(name, fn) self.scripts = self.scripts or {}; self.scripts[name] = fn end
  function r:HookScript(name, fn) self.hooks = self.hooks or {}; self.hooks[name] = fn end
  function r:EnableMouseWheel() end
  function r:CreateFontString() return region() end
  function r:CreateTexture() return region() end
  return r
end
local frames = {}
function CreateFrame() local r = region(); frames[#frames + 1] = r; return r end

local stored = { }
local BLU = { db = { soundVolumes = stored }, PrintDebug = function() end, Modules = { design = { Colors = { Primary = { 0, 1, 1 } } } } }
local chunk = assert(loadstring("local BLU, container, actualEventType, CreateFrame, unpack = ...\n" .. body .. "\nreturn volumeControl, volButton, volFill, volThumb, applyVolume"))
local volumeControl, volButton, volFill, volThumb, applyVolume = chunk(BLU, region(), "levelup", CreateFrame, unpack)

volButton.width = 200
applyVolume("high")
check(math.abs(volFill.width - 170) < 0.01, "fill is 85% of a 200px control, got " .. tostring(volFill.width))

-- The row is re-laid out narrower after the value was applied.
volButton.width = 100
volButton.scripts.OnSizeChanged(volButton)
check(math.abs(volFill.width - 85) < 0.01, "fill must follow the new width, got " .. tostring(volFill.width))
local pt = volThumb.points[#volThumb.points]
check(pt[1] == "CENTER" and math.abs(pt[4] - 85) < 0.01, "thumb must sit at the new fill edge")

-- Re-showing restores the saved value, not the last drawn one.
stored.levelup = "low"
volButton.width = 100
volumeControl.hooks.OnShow(volumeControl)
check(math.abs(volFill.width - 15) < 0.01, "OnShow redraws the saved 'low' value, got " .. tostring(volFill.width))

print("slider-layout-test OK")
