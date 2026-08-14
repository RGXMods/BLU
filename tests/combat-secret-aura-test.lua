local callbacks = {}
local played = {}
local now = 10
local lustActive = false

local function check(condition, message)
    if not condition then
        error("CHECK FAILED: " .. message, 2)
    end
end

local function capture(name)
    return function(_, callback)
        callbacks[name] = callback
        return function()
            callbacks[name] = nil
        end
    end
end

local Combat = {
    OnEnter = capture("enter"),
    OnLeave = capture("leave"),
    OnLowHealth = capture("lowHealth"),
    OnExecuteWindow = capture("executeWindow"),
    OnTargetLost = capture("targetLost"),
    OnResourceCapped = capture("resourceCapped"),
    OnResourceLow = capture("resourceLow"),
    OnCrit = capture("crit"),
    OnCritHeal = capture("critHeal"),
    OnProc = capture("proc"),
    OnEncounterEnd = capture("encounterEnd"),
    OnPvPVictory = capture("pvpVictory"),
}

local Auras = {}
function Auras:HasPlayerAura(spellId)
    return lustActive and spellId == 2825
end

_G.GetTime = function()
    return now
end

_G.RGXFramework = {
    GetCombat = function()
        return Combat
    end,
    GetAuras = function()
        return Auras
    end,
}

_G.BLU = {
    db = {
        enabled = true,
        modules = { combat = true },
        combat = {
            selectedSounds = {
                proc_trigger = "proc",
                lust_sound = "lust",
            },
            soundVolumes = {},
        },
    },
    Modules = {
        registry = {
            PlaySound = function(_, _, _, options)
                played[#played + 1] = options.triggerIdOverride
            end,
        },
    },
    PrintDebug = function() end,
    Emit = function() end,
    RegisterEvent = function()
        error("Combat must not register or inspect UNIT_AURA directly")
    end,
}

local chunk = assert(loadfile("modules/Combat/Combat.lua"))
local module = assert(chunk("BLU"))
module:Init()

check(type(callbacks.proc) == "function", "RGXCombat proc callback should be registered")

local secretUpdate = setmetatable({}, {
    __index = function()
        error("secret UNIT_AURA payload was accessed")
    end,
})

local function fireProc(hasLust)
    now = now + 2
    lustActive = hasLust
    callbacks.proc("UNIT_AURA", "player", secretUpdate)
end

fireProc(false)
fireProc(true)
fireProc(true)
fireProc(false)
fireProc(true)

local procCount = 0
local lustCount = 0
for _, trigger in ipairs(played) do
    if trigger == "proc_trigger" then procCount = procCount + 1 end
    if trigger == "lust_sound" then lustCount = lustCount + 1 end
end

check(procCount == 5, "generic proc should fire for every RGXCombat proc callback")
check(lustCount == 2, "lust should fire only on false-to-true aura transitions")

module:Cleanup()
check(callbacks.proc == nil, "cleanup should unsubscribe the RGXCombat proc callback")
module:Init()
check(type(callbacks.proc) == "function", "combat should subscribe once after reinitialization")

print("BLU COMBAT SECRET AURA OK (5 proc callbacks, 2 lust gains, clean reinit)")
