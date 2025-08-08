-- BLU Module Load Order Manifest
-- This file defines the order in which modules are loaded
-- Modules listed first will load before modules listed later
-- This ensures proper dependency resolution

local addonName, BLU = ...

-- Module load order (dependencies first)
BLU.ModuleLoadOrder = {
    -- Core modules (always loaded first)
    "core",          -- Base framework
    "database",      -- SavedVariables management
    "registry",      -- Sound registry system
    "loader",        -- Module loader
    
    -- Feature modules (loaded in order)
    "levelup",       -- Level up notifications
    "achievement",   -- Achievement notifications
    "quest",         -- Quest complete notifications
    "reputation",    -- Reputation changes
    "honor",         -- Honor/PvP notifications
    "battlepet",     -- Battle pet level ups
    "renown",        -- Renown rank increases
    "tradingpost",   -- Trading post activities
    "delve",         -- Delve-specific events
}

-- Module dependencies (optional, for validation)
BLU.ModuleDependencies = {
    levelup = {"core", "registry"},
    achievement = {"core", "registry"},
    quest = {"core", "registry", "database"},
    reputation = {"core", "registry"},
    honor = {"core", "registry"},
    battlepet = {"core", "registry"},
    renown = {"core", "registry"},
    tradingpost = {"core", "registry"},
    delve = {"core", "registry"},
}

-- Module metadata
BLU.ModuleInfo = {
    levelup = {
        name = "Level Up",
        description = "Plays sounds when you level up",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    achievement = {
        name = "Achievement",
        description = "Plays sounds for achievement unlocks",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    quest = {
        name = "Quest",
        description = "Plays sounds for quest completion",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    reputation = {
        name = "Reputation",
        description = "Plays sounds for reputation changes",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    honor = {
        name = "Honor",
        description = "Plays sounds for honor gains",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    battlepet = {
        name = "Battle Pet",
        description = "Plays sounds for battle pet levels",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    renown = {
        name = "Renown",
        description = "Plays sounds for renown increases",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    tradingpost = {
        name = "Trading Post",
        description = "Plays sounds for trading post events",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    },
    delve = {
        name = "Delve",
        description = "Plays sounds for delve events",
        author = "donniedice",
        version = "6.0.0",
        enabled = true
    }
}

return BLU.ModuleLoadOrder