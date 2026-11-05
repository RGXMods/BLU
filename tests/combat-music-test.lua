-- Combat music must start when combat starts and stop when it ends, for any registered sound
-- (file-based, volume-variant or built-in soundKit), on the Music channel.
local callbacks = {}
local played = {}      -- registry:PlaySound calls
local stopped = {}     -- StopSound(handle) calls
local cvars = { Sound_EnableAmbience = "1" }
local nextHandle = 100
local allowPlay = true
local now = 10

local function check(condition, message)
    if not condition then error("CHECK FAILED: " .. message, 2) end
end

local function capture(name)
    return function(_, callback)
        callbacks[name] = callback
        return function() callbacks[name] = nil end
    end
end

local Combat = {
    OnEnter = capture("enter"), OnLeave = capture("leave"), OnLowHealth = capture("a"),
    OnExecuteWindow = capture("b"), OnTargetLost = capture("c"), OnResourceCapped = capture("d"),
    OnResourceLow = capture("e"), OnCrit = capture("f"), OnCritHeal = capture("g"),
    OnProc = capture("h"), OnEncounterEnd = capture("i"), OnPvPVictory = capture("j"),
}

_G.GetTime = function() return now end
_G.GetCVar = function(name) return cvars[name] end
_G.SetCVar = function(name, value) cvars[name] = value end
_G.StopSound = function(handle) stopped[#stopped + 1] = handle end
_G.StopMusic = function() end
_G.RGXFramework = { GetCombat = function() return Combat end, GetAuras = function() return { HasPlayerAura = function() return false end } end }

local registry = {
    sounds = {
        file_track = { file = "Interface\\AddOns\\BLU\\sounds\\track.ogg" },
        kit_track  = { soundKit = 12345 },
    },
}
function registry:GetSound(id) return self.sounds[id] end
function registry:PlaySound(id, volume, options)
    played[#played + 1] = { id = id, options = options }
    if not allowPlay or not self.sounds[id] then return false, nil, "Music" end
    nextHandle = nextHandle + 1
    return true, nextHandle, "Music"
end

_G.BLU = {
    db = {
        enabled = true, modules = { combat = true },
        combat = { selectedSounds = { combat_music_track = "file_track" }, soundVolumes = {} },
    },
    Modules = { registry = registry },
    PrintDebug = function() end, Emit = function() end,
}

local module = assert(loadfile("modules/Combat/Combat.lua"))("BLU")
module:Init()
check(type(callbacks.enter) == "function" and type(callbacks.leave) == "function", "combat enter/leave callbacks registered")

local function musicCalls()
    local n = 0
    for _, call in ipairs(played) do
        if call.options and call.options.triggerIdOverride == "combat_music_track" then n = n + 1 end
    end
    return n
end

-- 1. File-based track: starts on enter on the combat_music_track trigger, stops on leave.
callbacks.enter()
check(musicCalls() == 1, "entering combat plays the combat music track once")
local call
for _, c in ipairs(played) do if c.options.triggerIdOverride == "combat_music_track" then call = c end end
check(call.id == "file_track", "plays the selected track")
check(call.options.categoryOverride == "combat", "uses the combat category")
check(cvars.Sound_EnableAmbience == "0", "ambience is muted while the track plays")
callbacks.leave()
check(#stopped == 1 and stopped[1] == 101, "leaving combat stops exactly the handle that was started")
check(cvars.Sound_EnableAmbience == "1", "ambience is restored when combat ends")
callbacks.leave()
check(#stopped == 1, "a second leave does not stop anything again")

-- 2. Built-in soundKit track (no .file) must also play and stop.
BLU.db.combat.selectedSounds.combat_music_track = "kit_track"
played, stopped = {}, {}
callbacks.enter()
check(musicCalls() == 1, "a soundKit track plays on combat start")
callbacks.leave()
check(#stopped == 1, "a soundKit track stops on combat end")

-- 3. Re-entering while already playing replaces the old handle instead of stacking.
played, stopped = {}, {}
callbacks.enter(); callbacks.enter()
check(#stopped == 1, "a second enter stops the previous track first")
callbacks.leave()
check(#stopped == 2, "the final leave stops the replacement track")

-- 4. None selected: nothing plays, nothing breaks, ambience untouched.
BLU.db.combat.selectedSounds.combat_music_track = "None"
played, stopped = {}, {}
callbacks.enter(); callbacks.leave()
check(musicCalls() == 0 and #stopped == 0 and cvars.Sound_EnableAmbience == "1", "None selected is a clean no-op")

-- 5. Playback refused by the registry: ambience must not stay muted.
BLU.db.combat.selectedSounds.combat_music_track = "file_track"
allowPlay = false
played, stopped = {}, {}
callbacks.enter()
check(cvars.Sound_EnableAmbience == "1", "ambience is restored when playback fails")
callbacks.leave()
check(#stopped == 0, "no stop is issued for a track that never started")

-- 6. Module disabled: nothing plays.
allowPlay = true
BLU.db.modules.combat = false
played = {}
callbacks.enter()
check(musicCalls() == 0, "a disabled combat module plays no music")

print("COMBAT MUSIC OK  (start, stop, soundKit, re-enter, none, failure, disabled)")
