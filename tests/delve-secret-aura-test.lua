-- Delve lives tracking must survive retail secret aura data: a secret count
-- cannot be compared, so a restricted tick keeps the cached count.

local function check(condition, message)
    if not condition then
        error("CHECK FAILED: " .. message, 2)
    end
end

-- A secret stand-in: comparing or doing arithmetic on it throws, like the client.
local SecretMT = {
    __lt = function() error("attempt to compare a secret value") end,
    __le = function() error("attempt to compare a secret value") end,
    __eq = function() error("attempt to compare a secret value") end,
}
local function Secret()
    return setmetatable({}, SecretMT)
end
local function IsSecret(value)
    return type(value) == "table" and getmetatable(value) == SecretMT
end

local auraResult
local played = {}
local now = 100

_G.GetTime = function() return now end
_G.GetBuildInfo = function() return "12.1.5", "70783", "", 120105 end

_G.RGXFramework = {
    API = {
        GetPlayerAuraBySpellID = function()
            return auraResult
        end,
        CanAccessValue = function(value)
            return type(value) ~= "nil" and not IsSecret(value)
        end,
        CanAccessTable = function(tbl)
            return type(tbl) == "table" and not IsSecret(tbl)
        end,
    },
    RegisterUnitEvent = function() end,
    UnregisterUnitEvent = function() end,
    After = function() end,
}

_G.BLU = {
    db = { enabled = true },
    RegisterEvent = function() end,
    UnregisterEvent = function() end,
    PrintDebug = function() end,
    Print = function() end,
    Loc = function(_, key) return key end,
    PlayCategorySound = function(_, category)
        played[#played + 1] = category
    end,
}

local chunk = assert(loadfile("modules/Delve/Delve.lua"))
local Delve = chunk("BLU")
Delve:Init()

-- Inside a delve with 3 lives.
auraResult = { applications = 3 }
Delve:RefreshLivesState()
check(Delve.cachedLivesRemaining == 3, "readable count is cached")

-- Combat restriction: the count field is secret. Must not error or clear the cache.
auraResult = { applications = Secret() }
local ok, err = pcall(Delve.RefreshLivesState, Delve)
check(ok, "secret count does not throw: " .. tostring(err))
check(Delve.cachedLivesRemaining == 3, "secret count keeps the cached value")
check(#played == 0, "secret count plays nothing")

-- Whole aura table restricted.
auraResult = Secret()
ok, err = pcall(Delve.RefreshLivesState, Delve)
check(ok, "secret aura table does not throw: " .. tostring(err))
check(Delve.cachedLivesRemaining == 3, "secret aura table keeps the cached value")
ok, err = pcall(Delve.UpdateLivesCache, Delve)
check(ok and Delve.cachedLivesRemaining == 3, "cache refresh skips restricted data")

-- Getter itself raising (restricted call) is treated as restricted.
_G.RGXFramework.API.GetPlayerAuraBySpellID = function() error("restricted") end
ok, err = pcall(Delve.RefreshLivesState, Delve)
check(ok and Delve.cachedLivesRemaining == 3, "throwing getter keeps the cached value")
_G.RGXFramework.API.GetPlayerAuraBySpellID = function() return auraResult end

-- Restriction lifts and a life was lost meanwhile.
auraResult = { applications = 2 }
Delve:RefreshLivesState()
check(played[1] == "delvelifelost", "life lost is detected after restriction lifts")
check(Delve.cachedLivesRemaining == 2, "cache follows the readable count")

-- Leaving the delve: aura absent resets the cache.
auraResult = nil
Delve:RefreshLivesState()
check(Delve.cachedLivesRemaining == nil, "absent aura clears the cache")

print("delve-secret-aura-test: ok")
