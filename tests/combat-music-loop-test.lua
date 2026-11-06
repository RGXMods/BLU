-- A long fight must not outlast the combat music track: while still in combat the track
-- starts again when it ends; leaving combat cancels the restart. Runs the real module.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local callbacks, played, stopped, timers = {}, {}, {}, {}
local inCombat = false
local function capture(name) return function(_, cb) callbacks[name] = cb; return function() callbacks[name] = nil end end end
local Combat = {
  OnEnter = capture("enter"), OnLeave = capture("leave"), OnLowHealth = capture("a"), OnExecuteWindow = capture("b"),
  OnTargetLost = capture("c"), OnResourceCapped = capture("d"), OnResourceLow = capture("e"), OnCrit = capture("f"),
  OnCritHeal = capture("g"), OnProc = capture("h"), OnEncounterEnd = capture("i"), OnPvPVictory = capture("j"),
  IsInCombat = function() return inCombat end,
}
local now = 10
_G.GetTime = function() return now end
_G.GetCVar = function() return "1" end
local cvarWrites = 0
_G.SetCVar = function() cvarWrites = cvarWrites + 1 end
_G.StopSound = function(h) stopped[#stopped + 1] = h end
_G.StopMusic = function() end
_G.RGXFramework = {
  GetCombat = function() return Combat end,
  GetAuras = function() return { HasPlayerAura = function() return false end } end,
  After = function(_, delay, fn) timers[#timers + 1] = { delay = delay, fn = fn } end,
}
local handle = 100
local registry = { sounds = { long = { duration = 100 }, short = { duration = 2 } } }
function registry:GetSound(id) return self.sounds[id] end
function registry:PlaySound(id) played[#played + 1] = id; handle = handle + 1; return true, handle, "Music" end
_G.BLU = { db = { enabled = true, modules = { combat = true },
  combat = { selectedSounds = { combat_music_track = "long" }, soundVolumes = {} } },
  Modules = { registry = registry }, PrintDebug = function() end, Emit = function() end }

local module = assert(loadfile("modules/Combat/Combat.lua"))("BLU")
module:Init()

inCombat = true
callbacks.enter()
check(#played >= 1 and played[#played] == "long", "music starts with combat")
local musicStarts = 0
for _, id in ipairs(played) do if id == "long" then musicStarts = musicStarts + 1 end end
check(musicStarts == 1, "started once")
check(#timers == 1 and timers[1].delay > 100 and timers[1].delay < 102, "restart scheduled after the track length")

-- The track ends while still in combat: it starts again.
timers[1].fn()
musicStarts = 0
for _, id in ipairs(played) do if id == "long" then musicStarts = musicStarts + 1 end end
check(musicStarts == 2, "track restarts when it ends during combat")
check(cvarWrites == 1, "a restart leaves the ambience muted instead of toggling the CVar again (writes: " .. cvarWrites .. ")")
check(#timers == 2, "and the next restart is scheduled")

-- Combat ends: a pending restart must do nothing.
inCombat = false
callbacks.leave()
local before = #played
timers[2].fn()
check(#played == before, "no restart after combat ended")

-- A restart left over from a previous fight must not start music in the next one.
inCombat = true
callbacks.enter()
local fresh = #played
timers[2].fn()   -- stale timer from the earlier fight
check(#played == fresh, "stale timer from an earlier fight does nothing")

-- Short sounds never loop.
BLU.db.combat.selectedSounds.combat_music_track = "short"
timers = {}
callbacks.leave(); inCombat = true; callbacks.enter()
check(#timers == 0, "a short placeholder-length sound is never restarted")

print("combat-music-loop-test OK")
