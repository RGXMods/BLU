local callbacks = {}
local played = {}
local now = 100

local function check(condition, message)
    if not condition then
        error("CHECK FAILED: " .. message, 2)
    end
end

local function register(event, callback, id)
    callbacks[event] = callbacks[event] or {}
    callbacks[event][id] = callback
end

local function unregister(event, id)
    if callbacks[event] then
        callbacks[event][id] = nil
    end
end

local function fire(event, payload)
    for _, callback in pairs(callbacks[event] or {}) do
        callback(event, payload)
    end
end

local function registeredCount()
    local count = 0
    for _, byId in pairs(callbacks) do
        for _ in pairs(byId) do
            count = count + 1
        end
    end
    return count
end

_G.GetTime = function()
    return now
end

_G.BLU = {
    db = {
        enabled = true,
        modules = { collectibles = true },
        debugMode = false,
    },
    Modules = {},
    Loc = function(_, key, ...)
        if select("#", ...) > 0 then
            return string.format(key, ...)
        end
        return key
    end,
    RegisterEvent = function(self, event, callback, id)
        register(event, callback, id)
    end,
    UnregisterEvent = function(self, event, id)
        unregister(event, id)
    end,
    PlayCategorySound = function(self, category)
        played[#played + 1] = category
        return true
    end,
    PrintDebug = function() end,
    Print = function() end,
    RegisterModule = function(self, module, name)
        self.Modules[name] = module
    end,
}

local module = assert(loadfile("modules/Collectibles/Collectibles.lua"))("BLU")

local EXPECTED_EVENTS = {
    "NEW_MOUNT_ADDED",
    "NEW_PET_ADDED",
    "NEW_TOY_ADDED",
    "TRANSMOG_COLLECTION_SOURCE_ADDED",
    "TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED",
}

module:Init()
check(registeredCount() == 5, "Init should register all five acquisition events")

local function countPlays(category)
    local count = 0
    for _, value in ipairs(played) do
        if value == category then
            count = count + 1
        end
    end
    return count
end

-- Each acquisition type plays its category sound.
fire("NEW_MOUNT_ADDED", 1234)
check(countPlays("mount") == 1, "mount acquisition should play the mount category")

fire("NEW_PET_ADDED", 5678)
check(countPlays("pet") == 1, "pet acquisition should play the pet category")

fire("NEW_TOY_ADDED", 9012)
check(countPlays("toy") == 1, "toy acquisition should play the toy category")

fire("TRANSMOG_COLLECTION_SOURCE_ADDED", 3456)
check(countPlays("transmog") == 1, "transmog source acquisition should play the transmog category")

-- Same-category fires inside the cooldown window are deduplicated.
fire("NEW_MOUNT_ADDED", 1235)
check(countPlays("mount") == 1, "mount should be deduplicated inside the cooldown window")

fire("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", 3457)
check(countPlays("transmog") == 1, "cosmetic transmog should share the transmog cooldown")

-- Distinct categories have independent cooldowns.
now = now + 0.5
fire("NEW_TOY_ADDED", 9013)
check(countPlays("toy") == 1, "toy should still be inside its own cooldown")

-- Module toggle gates playback; pet is still inside its own cooldown here.
BLU.db.modules.collectibles = false
fire("NEW_PET_ADDED", 5679)
check(countPlays("pet") == 1, "disabled collectibles module must not play sounds")

BLU.db.modules.collectibles = true
fire("NEW_PET_ADDED", 5680)
check(countPlays("pet") == 1, "re-enabling inside the cooldown still respects the cooldown")

-- After the cooldown, the same category fires again.
now = now + 0.6
fire("NEW_MOUNT_ADDED", 1236)
check(countPlays("mount") == 2, "mount should fire again after the cooldown")

fire("NEW_PET_ADDED", 5681)
check(countPlays("pet") == 2, "pet should fire again once the cooldown has elapsed")

-- Addon-wide disable gates playback.
BLU.db.enabled = false
now = now + 2
fire("NEW_TOY_ADDED", 9014)
check(countPlays("toy") == 1, "disabled addon must not play sounds")
BLU.db.enabled = true

-- Cleanup unregisters everything and re-Init restores the subscriptions.
module:Cleanup()
check(registeredCount() == 0, "Cleanup should unregister every event")
module:Init()
check(registeredCount() == 5, "Init after Cleanup should register every event again")
for _, event in ipairs(EXPECTED_EVENTS) do
    local found = false
    for _ in pairs(callbacks[event] or {}) do
        found = true
    end
    check(found, "expected event missing after re-Init: " .. event)
end

print("BLU COLLECTIBLES TRIGGERS OK (4 categories, cooldown-deduped, module-gated)")
