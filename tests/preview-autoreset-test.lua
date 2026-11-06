-- The Test/Play button must go back from "Stop" when the previewed sound has finished.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local timers = {}
_G.C_Timer = { After = function(delay, fn) timers[#timers + 1] = { delay = delay, fn = fn } end }
_G.StopSound = function() end
_G.BLU = { Modules = {}, db = {}, PrintDebug = function() end, PrintError = function() end }

assert(loadfile("core/systems/registry.lua"))("BLU")
local registry = BLU.SoundRegistry

registry.sounds.short = { name = "Short", file = "x.ogg", duration = 3 }
registry.sounds.noduration = { name = "NoDur", file = "y.ogg" }
registry.PlaySound = function() return true, 77, "Master" end

local notifications = 0
registry:RegisterPreviewListener(function() notifications = notifications + 1 end)

local ok, status = registry:PreviewSound("short", { previewKey = "k1" })
check(ok and status == "playing", "preview starts")
check(registry:IsPreviewPlaying("short", "k1"), "reports playing")
check(#timers == 1 and timers[1].delay >= 3 and timers[1].delay < 4, "timer follows the sound duration")

local before = notifications
timers[1].fn()
check(not registry:IsPreviewPlaying("short", "k1"), "state clears when the sound has finished")
check(notifications == before + 1, "listeners are told so the button label refreshes")

-- A stale timer from a replaced preview must not clear the newer one.
timers = {}
registry:PreviewSound("short", { previewKey = "k1" })
local oldTimer = timers[1]
registry:StopPreview()
registry:PreviewSound("noduration", { previewKey = "k2" })
oldTimer.fn()
check(registry:IsPreviewPlaying("noduration", "k2"), "stale timer must not end a newer preview")
check(timers[2].delay > 5, "sounds without a duration fall back to a long-enough window")
timers[2].fn()
check(not registry:IsPreviewPlaying("noduration", "k2"), "fallback timer clears the state")

print("preview-autoreset-test OK")
