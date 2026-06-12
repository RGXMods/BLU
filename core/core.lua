--=====================================================================================
-- BLU Framework
-- Powered by RGX-Framework v2.0
--=====================================================================================

local addonName, addonTable = ...
local RGX = _G.RGXFramework
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local CORE_EVENT_ID_LOGOUT = "core_player_logout"
local CHAT_ICON = "|T" .. ADDON_PATH .. "media\\Textures\\icon.tga:16:16:0:0|t"
local CHAT_PREFIX = CHAT_ICON .. " - |cffffffff[|r|cff05dffaBLU|r|cffffffff]|r"
local CHAT_DEBUG_PREFIX = CHAT_PREFIX .. " |cffffffff[|r|cff808080DEBUG|r|cffffffff]|r"
local CHAT_ERROR_PREFIX = CHAT_PREFIX .. " |cffffffff[|r|cffff0000ERROR|r|cffffffff]|r"

local function GetAddOnMetadataSafe(self, addonName, key)
    if type(self) == "string" and key == nil then
        key = addonName
        addonName = self
    end
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, value = pcall(C_AddOns.GetAddOnMetadata, addonName, key)
        return ok and value or nil
    elseif GetAddOnMetadata then
        local ok, value = pcall(GetAddOnMetadata, addonName, key)
        return ok and value or nil
    end
    return nil
end

print("BLU: Core loading started.")

-- ── Bootstrap via RGX-Framework ──────────────────────────────────────────────

if RGX then
    BLU = RGX.Addon("BLU", {
        db      = true,
        dbName  = "BLUDB",
        slash   = "blu",
        minimap = ADDON_PATH .. "media\\Textures\\icon.tga",
        brand   = "05dffa",
        onInit  = function(self)
            self:ShowWelcomeMessage()
        end,
    })
end

-- Fallback constructor if RGX-Framework is absent
if not BLU then
    BLU = {
        name = addonName,
        version = "v8.0.0-alpha.1",
        Modules = {},
        LoadedModules = {},
        events = {},
        debugMode = false,
        isInitialized = false,
    }
end

-- Shared tables (compat for modules that access these directly)
BLU.Modules = BLU.Modules or {}
BLU.LoadedModules = BLU.LoadedModules or {}
BLU.events = BLU.events or {}
BLU.hooks = BLU.hooks or {}
BLU.timers = BLU.timers or {}
BLU.debugMode = BLU.debugMode or false
BLU.isInitialized = BLU.isInitialized or false
BLU.GetMetadata = BLU.GetMetadata or GetAddOnMetadataSafe
BLU.name = BLU.name or addonName

-- Print message
function BLU:Print(message)
    print(CHAT_PREFIX .. " " .. message)
end

-- Print debug message
function BLU:PrintDebug(message)
    if not self.debugMode then
        return
    end

    if not self:IsDebugScopeEnabledForMessage(message) then
        return
    end

    print(CHAT_DEBUG_PREFIX .. " " .. message)
end

function BLU:Trace(scope, message)
    if not self.debugMode then
        return
    end

    if not self:IsDebugScopeEnabled(scope) then
        return
    end

    self:PrintDebug("[" .. tostring(scope) .. "] " .. tostring(message))
end

-- Print error message
function BLU:PrintError(message)
    print(CHAT_ERROR_PREFIX .. " " .. message)
end

function BLU:NormalizeDebugScope(scope)
    if type(scope) ~= "string" or scope == "" then
        return "core"
    end

    local normalized = string.lower(scope)
    normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")

    if normalized:find("^tabs") then
        return "tabs"
    end
    if normalized:find("^options") then
        return "options"
    end
    if normalized:find("^registry") or normalized:find("^soundregistry") then
        return "registry"
    end
    if normalized:find("^soundpanel") or normalized:find("^sounds") or normalized:find("^usersounds") or normalized:find("^sharedmedia") or normalized:find("^internalsounds") then
        return "sounds"
    end
    if normalized:find("^loader") or normalized:find("^init") then
        return "loader"
    end
    if normalized:find("^database") or normalized:find("^config") then
        return "database"
    end
    if normalized:find("^profiles") then
        return "profiles"
    end
    if normalized:find("^modules") or normalized:find("^module") then
        return "modules"
    end
    if normalized:find("^events") or normalized:find("^combat") or normalized:find("^timer") or normalized:find("^hooks") or normalized:find("^slash") or normalized:find("^welcome") or normalized:find("^state") then
        return "events"
    end
    if normalized:find("^achievement") or normalized:find("^levelup") or normalized:find("^quest") or normalized:find("^reputation") or normalized:find("^battlepet") or normalized:find("^honor") or normalized:find("^renown") or normalized:find("^delve") or normalized:find("^housing") or normalized:find("^tradingpost") then
        return "features"
    end

    return "core"
end

function BLU:IsDebugScopeEnabled(scope)
    local profile = self.db
    if not profile then
        return true
    end

    local scopes = profile.debugScopes
    if type(scopes) ~= "table" then
        return true
    end

    local normalized = self:NormalizeDebugScope(scope)
    if scopes[normalized] == nil then
        return true
    end

    return scopes[normalized] ~= false
end

function BLU:IsDebugScopeEnabledForMessage(message)
    if type(message) ~= "string" then
        return self:IsDebugScopeEnabled("core")
    end

    local rawScope = string.match(message, "^%[([^%]]+)%]")
    if rawScope then
        return self:IsDebugScopeEnabled(rawScope)
    end

    return self:IsDebugScopeEnabled("core")
end

-- Create event frame (early definition)
BLU.eventFrame = CreateFrame("Frame")
BLU.eventFrame:SetScript("OnEvent", function(self, event, ...) 
    BLU:FireEvent(event, ...)
end)

-- Register event (early definition)
local function RegisterEvent(self, event, callback, id)
    id = id or "core"
    local RGX = _G.RGXFramework
    if RGX then
        RGX:RegisterEvent(event, function(...) callback(event, ...) end, id)
        return
    end
    
    if not self.events[event] then
        self.events[event] = {}
        self.eventFrame:RegisterEvent(event)
    end
    
    self.events[event][id] = callback
end
BLU.RegisterEvent = RegisterEvent

-- Print debug message (early definition)




-- Framework loaded - BLU is now globally accessible



-- Unregister event
local function UnregisterEvent(self, event, id)
    id = id or "core"
    
    if self.events[event] then
        self.events[event][id] = nil
        
        -- If no more callbacks, unregister the event
        if not next(self.events[event]) then
            self.eventFrame:UnregisterEvent(event)
            self.events[event] = nil
        end
        self:PrintDebug("[Events] Unregistered event '" .. tostring(event) .. "' with id '" .. tostring(id) .. "'")
    end
end
BLU.UnregisterEvent = UnregisterEvent

-- Fire event with performance optimization
local function FireEvent(self, event, ...)
    local eventTable = self.events[event]
    if not eventTable then return end
    
    -- Cache event callbacks to avoid issues if they're modified during iteration
    local callbacks = {}
    for id, callback in pairs(eventTable) do
        callbacks[#callbacks + 1] = {id = id, callback = callback}
    end
    
    for i = 1, #callbacks do
        local entry = callbacks[i]
        local success, err = pcall(entry.callback, event, ...)
        if not success then
            self:PrintError("Error in event " .. tostring(event) .. " for " .. tostring(entry.id) .. ": " .. tostring(err))
        end
    end
end
BLU.FireEvent = FireEvent

--=====================================================================================
-- Timer System — delegates to RGX
--=====================================================================================

function BLU:After(delay, callback)
    local RGX = _G.RGXFramework
    if RGX then return RGX:After(delay, callback) end
    return self:CreateTimer(delay, callback, false)
end

function BLU:CancelTimer(timer)
    local RGX = _G.RGXFramework
    if RGX then RGX:CancelTimer(timer); return end
    if timer then timer.active = false end
end

--=====================================================================================
-- Hook System — delegates to RGX (zero BLU callers, kept as compat shim)
--=====================================================================================

function BLU:Hook(target, method, callback)
    local RGX = _G.RGXFramework
    if RGX and RGX.Hook then return RGX:Hook(target, method, callback) end
end

function BLU:Unhook(target, method)
    local RGX = _G.RGXFramework
    if RGX and RGX.Unhook then return RGX:Unhook(target, method) end
end

--=====================================================================================
-- Slash Commands — delegates to RGX (commands.lua uses raw SLASH_ vars directly)
--=====================================================================================

function BLU:RegisterSlashCommand(command, callback)
    local RGX = _G.RGXFramework
    if RGX then return RGX:RegisterSlashCommand(command, callback) end
end

-- Show welcome message
function BLU:ShowWelcomeMessage()
    if not (self.db and self.db.showWelcomeMessage ~= false) then
        self:Trace("Welcome", "Skipped welcome message")
        return
    end

    local version = self.GetMetadata(addonName, "Version") or self.version or "Unknown"
    print(CHAT_PREFIX .. " Welcome. Use |cff05dffa/blu|r to open the options panel or |cff05dffa/blu help|r for more commands.")
    print(CHAT_PREFIX .. " |cffffff00Version:|r |cff8080ff" .. version .. "|r")
    self:Trace("Welcome", "Displayed welcome message for version " .. tostring(version))
end

--=====================================================================================
-- Module System
--=====================================================================================

-- Register module
function BLU:RegisterModule(module, name, description)
    -- Handle both calling conventions
    if type(module) == "string" then
        -- Old style: (name, module)
        local temp = module
        module = name
        name = temp
    end
    
    self.Modules[name] = module
    self.LoadedModules[name] = module
    
    -- Don't auto-init modules here, they're initialized in init.lua
    
    self:PrintDebug("Module registered: " .. name .. (description and (" - " .. description) or ""))
end

-- Get module
function BLU:GetModule(name)
    self:Trace("Modules", "GetModule called for '" .. tostring(name) .. "'")
    return self.Modules[name]
end

--=====================================================================================
-- Advanced Settings Functions
--=====================================================================================

-- Clear sound cache
function BLU:ClearSoundCache()
    self:Trace("Advanced", "ClearSoundCache called")
    if self.Modules.registry and self.Modules.registry.soundCache then
        self.Modules.registry.soundCache = {}
        self:Print("Sound cache cleared")
    end
end

-- Module enable/disable functions
function BLU:EnableModule(moduleId)
    if self.Modules[moduleId] then
        -- Module is already loaded, just enable it
        if self.db and self.db.modules then
            self.db.modules[moduleId] = true
        end
        self:PrintDebug("Enabled module: " .. moduleId)
        return true
    end
    return false
end

function BLU:DisableModule(moduleId)
    if self.db and self.db.modules then
        self.db.modules[moduleId] = false
    end
    self:PrintDebug("Disabled module: " .. moduleId)
    return true
end

-- Reload modules function
function BLU:ReloadModules()
    self:Trace("Modules", "ReloadModules called")
    if self.Modules.loader and self.Modules.loader.LoadModulesFromSettings then
        self.Modules.loader:LoadModulesFromSettings()
    end
end

function BLU:Enable()
    self:Trace("State", "Enable called")
    -- Already enabled
end

function BLU:Disable()
    self:Trace("State", "Disable called")
    self:OnDisable()
end

function BLU:OnDisable()
    self:Trace("State", "OnDisable called")
    for name, module in pairs(self.LoadedModules) do
        if module and module.OnDisable then
            module:OnDisable()
        end
    end
end

BLU:RegisterEvent("PLAYER_LOGOUT", function(event)
    BLU:OnDisable()
end, CORE_EVENT_ID_LOGOUT)

-- Copy all BLU functions to addon table so other files can access them via local addonName, addonTable = ...
