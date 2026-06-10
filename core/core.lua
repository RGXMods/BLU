--=====================================================================================
-- BLU | Core — v8.0.0-alpha
-- Powered by RGX-Framework v2.0.0
--=====================================================================================

local addonName, addonTable = ...
local RGX = _G.RGXFramework
if not RGX then error("BLU requires RGX-Framework v2.0.0+") end

local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"

-- ── Spin up the addon ────────────────────────────────────────────────────────

local BLU = RGX.Addon("BLU", {
    db      = true,         -- defaults merged by config:ApplySettings() after load
    dbName  = "BLUDB",
    slash   = "blu",
    minimap = ADDON_PATH .. "media\\Textures\\icon.tga",
    brand   = "05dffa",
    welcome = "BLU loaded. /blu to configure.",
    onInit  = function(self)
        _G.BLU = self
        BLU.Modules = {}
        BLU.LoadedModules = {}
        self:InitDebugSystem()
        self:InitializeModules()
    end,
})

-- ── BLU globals — compatibility for existing modules ─────────────────────────

_G.BLU = BLU
BLU.Modules = {}
BLU.LoadedModules = {}
BLU.events = {}
BLU.hooks = {}
BLU.timers = {}
BLU.debugMode = false

-- ── Event bridge — BLU:RegisterEvent delegates to RGX ────────────────────────

BLU.eventFrame = CreateFrame("Frame")

function BLU:RegisterEvent(event, callback, id)
    if not RGX then return end
    RGX:RegisterEvent(event, function(...) callback(event, ...) end, id)
end

function BLU:UnregisterEvent(event, id)
    if not RGX then return end
    RGX:UnregisterEvent(event, id)
end

function BLU:FireEvent(event, ...)
    -- Kept for modules that call BLU:FireEvent directly
end

-- ── Timer bridge ─────────────────────────────────────────────────────────────

function BLU:After(delay, callback)
    return RGX and RGX:After(delay, callback)
end

function BLU:CancelTimer(timer)
    if RGX then RGX:CancelTimer(timer) end
end

-- ── Print bridge — compatibility for modules using BLU:Print ──────────────────

BLU.GetMetadata = function(name, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(name, key)
    elseif GetAddOnMetadata then
        return GetAddOnMetadata(name, key)
    end
end

-- ── Debug system ─────────────────────────────────────────────────────────────

local CHAT_DEBUG_PREFIX = "|T" .. ADDON_PATH .. "media\\Textures\\icon.tga:16:16:0:0|t - |cff05dffa[BLU]|r |cff808080[DEBUG]|r"
local CHAT_ERROR_PREFIX  = "|T" .. ADDON_PATH .. "media\\Textures\\icon.tga:16:16:0:0|t - |cff05dffa[BLU]|r |cffff0000[ERROR]|r"

function BLU:PrintDebug(message)
    if not self.debugMode then return end
    if not self:IsDebugScopeEnabledForMessage(message) then return end
    print(CHAT_DEBUG_PREFIX .. " " .. message)
end

function BLU:PrintError(message)
    print(CHAT_ERROR_PREFIX .. " " .. message)
end

function BLU:Trace(scope, message)
    if not self.debugMode then return end
    if not self:IsDebugScopeEnabled(scope) then return end
    self:PrintDebug("[" .. tostring(scope) .. "] " .. tostring(message))
end

function BLU:NormalizeDebugScope(scope)
    if type(scope) ~= "string" or scope == "" then return "core" end
    local n = scope:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if n:find("^tabs") then return "tabs"
    elseif n:find("^options") then return "options"
    elseif n:find("^registry") or n:find("^soundregistry") then return "registry"
    elseif n:find("^soundpanel") or n:find("^sounds") or n:find("^usersounds") or n:find("^sharedmedia") then return "sounds"
    elseif n:find("^loader") or n:find("^init") then return "loader"
    elseif n:find("^database") or n:find("^config") then return "database"
    elseif n:find("^profiles") then return "profiles"
    elseif n:find("^modules") then return "modules"
    elseif n:find("^events") or n:find("^combat") or n:find("^timer") or n:find("^hooks") or n:find("^slash") then return "events"
    elseif n:find("^achievement") or n:find("^levelup") or n:find("^quest") or n:find("^reputation") or n:find("^battlepet") or n:find("^honor") or n:find("^renown") or n:find("^delve") or n:find("^housing") or n:find("^tradingpost") then return "features"
    end
    return "core"
end

function BLU:IsDebugScopeEnabled(scope)
    local scopes = self.db and self.db.debugScopes
    if type(scopes) ~= "table" then return true end
    local n = self:NormalizeDebugScope(scope)
    if scopes[n] == nil then return true end
    return scopes[n] ~= false
end

function BLU:IsDebugScopeEnabledForMessage(message)
    if type(message) ~= "string" then return self:IsDebugScopeEnabled("core") end
    local rawScope = message:match("^%[([^%]]+)%]")
    return self:IsDebugScopeEnabled(rawScope or "core")
end

function BLU:InitDebugSystem()
    -- Debug mode is read from db in config:ApplySettings()
end

-- ── Module system ────────────────────────────────────────────────────────────

function BLU:RegisterModule(module, name, description)
    if type(module) == "string" then
        local temp = module; module = name; name = temp
    end
    self.Modules[name] = module
    self.LoadedModules[name] = module
    self:PrintDebug("Module registered: " .. name)
end

function BLU:GetModule(name)
    return self.Modules[name]
end

-- ── Module enable/disable ────────────────────────────────────────────────────

function BLU:EnableModule(moduleId)
    if self.db and self.db.modules then self.db.modules[moduleId] = true end
    return true
end

function BLU:DisableModule(moduleId)
    if self.db and self.db.modules then self.db.modules[moduleId] = false end
    return true
end

-- ── PLAYER_LOGOUT cleanup ────────────────────────────────────────────────────

function BLU:OnDisable()
    for _, module in pairs(self.LoadedModules) do
        if module and module.OnDisable then module:OnDisable() end
    end
end

RGX:RegisterEvent("PLAYER_LOGOUT", function() BLU:OnDisable() end, "BLU_Logout")

-- ── Play test sound ──────────────────────────────────────────────────────────

function BLU:PlayTestSound(category, volume)
    local testSounds = {
        levelup      = ADDON_PATH .. "media\\sounds\\level_default.ogg",
        achievement  = ADDON_PATH .. "media\\sounds\\achievement_default.ogg",
        quest        = ADDON_PATH .. "media\\sounds\\quest_default.ogg",
    }
    local file = testSounds[category] or testSounds.levelup
    local channel = self.db and self.db.soundChannel or "Master"
    PlaySoundFile(file, channel)
    return true
end

-- ── Module init — runs after ADDON_LOADED ───────────────────────────────────

function BLU:InitializeModules()
    -- Loaded by core/initialization.lua (phased init)
    -- This function exists for addons that call BLU:InitializeModules() directly
end

print("BLU v8.0.0-alpha — core loaded.")
