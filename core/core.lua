--=====================================================================================
-- BLU Framework
-- Our own lightweight addon framework (no external dependencies)
--=====================================================================================

-- Removed redundant BluPrint function - using BLU:Print() instead

local addonName, addonTable = ...
local ADDON_PATH = "Interface\\AddOns\\" .. addonName .. "\\"
local CORE_EVENT_ID_LOGOUT = "core_player_logout"
local CHAT_ICON = "|T" .. ADDON_PATH .. "media\\Textures\\icon.tga:16:16:0:0|t"
local CHAT_PREFIX = CHAT_ICON .. " - |cffffffff[|r|cff05dffaBLU|r|cffffffff]|r"
local CHAT_DEBUG_PREFIX = CHAT_PREFIX .. " |cffffffff[|r|cff808080DEBUG|r|cffffffff]|r"
local CHAT_ERROR_PREFIX = CHAT_PREFIX .. " |cffffffff[|r|cffff0000ERROR|r|cffffffff]|r"

local function GetAddOnMetadataSafe(self, addonName, key)
    -- Support both BLU:GetMetadata(name, key) and GetAddOnMetadataSafe(name, key)
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

-- Create the main addon object (global)
BLU = {
    GetMetadata = GetAddOnMetadataSafe,
    name = addonName,
    version = "v6.5.0",
    author = GetAddOnMetadataSafe(addonName, "Author"),
    
    -- Core tables
    Modules = {},
    LoadedModules = {},
    events = {},
    hooks = {},
    timers = {},
    
    -- Settings
    debugMode = false,
    isInitialized = false
}

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
    
    if not self.events[event] then
        self.events[event] = {}
        self.eventFrame:RegisterEvent(event)
    end
    
    self.events[event][id] = callback
    self:PrintDebug("[Events] Registered event '" .. tostring(event) .. "' with id '" .. tostring(id) .. "'")
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
-- Timer System
--=====================================================================================

-- Create timer
function BLU:CreateTimer(duration, callback, repeating)
    self:Trace("Timer", "Creating timer (duration=" .. tostring(duration) .. ", repeating=" .. tostring(repeating == true) .. ")")
    local timer = {
        duration = duration,
        callback = callback,
        repeating = repeating,
        elapsed = 0,
        active = true
    }
    
    table.insert(self.timers, timer)
    
    -- Start timer frame if needed
    if not self.timerFrame then
        self.timerFrame = CreateFrame("Frame")
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed) 
            BLU:UpdateTimers(elapsed)
        end)
    end
    
    return timer
end

-- Update timers
function BLU:UpdateTimers(elapsed)
    for i = #self.timers, 1, -1 do
        local timer = self.timers[i]
        
        if timer.active then
            timer.elapsed = timer.elapsed + elapsed
            
            if timer.elapsed >= timer.duration then
                -- Execute callback
                local success, err = pcall(timer.callback)
                if not success then
                    self:PrintError("Timer error: " .. err)
                end
                
                if timer.repeating then
                    timer.elapsed = 0
                else
                    -- Remove one-time timer
                    table.remove(self.timers, i)
                end
            end
        end
    end
    
    -- Stop timer frame if no active timers
    if #self.timers == 0 and self.timerFrame then
        self.timerFrame:SetScript("OnUpdate", nil)
    end
end

-- Cancel timer
function BLU:CancelTimer(timer)
    if timer then
        timer.active = false
        self:Trace("Timer", "Cancelled timer")
    end
end

--=====================================================================================
-- Hook System
--=====================================================================================

-- Hook function
function BLU:Hook(target, method, callback)
    self:Trace("Hooks", "Hook request for method '" .. tostring(method) .. "'")
    local original = target[method]
    
    if not original then
        self:PrintError("Cannot hook non-existent method: " .. method)
        return
    end
    
    target[method] = function(...)
        return callback(original, ...)
    end
    
    -- Store for unhooking
    self.hooks[target] = self.hooks[target] or {}
    self.hooks[target][method] = original
    self:Trace("Hooks", "Hooked method '" .. tostring(method) .. "'")
end

-- Unhook function
function BLU:Unhook(target, method)
    if self.hooks[target] and self.hooks[target][method] then
        target[method] = self.hooks[target][method]
        self.hooks[target][method] = nil
        self:Trace("Hooks", "Unhooked method '" .. tostring(method) .. "'")
    end
end

--=====================================================================================
-- Slash Commands
--=====================================================================================

-- Register slash command
function BLU:RegisterSlashCommand(command, callback)
    self:Trace("Slash", "Registering slash command(s): " .. tostring(type(command) == "table" and table.concat(command, ", ") or command))
    -- Support multiple commands
    local commands = type(command) == "table" and command or {command}
    
    -- Use a unique identifier for this addon's commands
    local cmdName = addonName .. "CMD"
    
    for i, cmd in ipairs(commands) do
        _G["SLASH_" .. cmdName .. i] = "/" .. cmd
    end
    
    SlashCmdList[cmdName] = callback
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
-- Profile Management Functions
--=====================================================================================

-- Create profile
-- Serialize profile for export
function BLU:SerializeProfile(profileName)
    self:Trace("Profiles", "SerializeProfile called for '" .. tostring(profileName) .. "'")
    if not BLUDB or not BLUDB.profiles or not BLUDB.profiles[profileName] then
        self:PrintError("Profile not found: " .. tostring(profileName))
        return nil
    end
    
    local profile = BLUDB.profiles[profileName]
    local serialized = {
        name = profileName,
        version = self.version,
        exportDate = date("%Y-%m-%d %H:%M:%S"),
        settings = profile
    }
    
    return self:TableToString(serialized)
end

-- Import profile from string
function BLU:ImportProfile(dataString, profileName)
    self:Trace("Profiles", "ImportProfile called for target '" .. tostring(profileName or "auto") .. "'")
    local success, data = pcall(loadstring("return " .. dataString))
    if not success or type(data) ~= "table" then
        self:PrintError("Invalid import data")
        return false
    end
    
    if not data.settings then
        self:PrintError("Import data missing settings")
        return false
    end
    
    local name = profileName or data.name or "Imported Profile"
    BLUDB.profiles[name] = self.Database:CopyTable(data.settings)
    
    self:Print("Profile imported: " .. name)
    return true
end

-- Table to string helper
function BLU:TableToString(t, indent)
    indent = indent or ""
    local str = "{\n"
    
    for k, v in pairs(t) do
        str = str .. indent .. "  "
        
        if type(k) == "string" then
            str = str .. "[\"" .. k .. "\"] = "
        else
            str = str .. "[" .. tostring(k) .. "] = "
        end
        
        if type(v) == "table" then
            str = str .. self:TableToString(v, indent .. "  ")
        elseif type(v) == "string" then
            str = str .. "\"" .. v .. "\""
        else
            str = str .. tostring(v)
        end
        
        str = str .. ",\n"
    end
    
    str = str .. indent .. "}"
    return str
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

-- Reset advanced settings
function BLU:ResetAdvancedSettings()
    self:Trace("Advanced", "ResetAdvancedSettings called")
    if not self.db then return end
    self.db.soundPooling = false
    self.db.asyncLoading = false
    self.db.soundQueueSize = 3
    self.db.fadeTime = 200
    self.db.lazyLoading = true
    self.db.moduleTimeout = 5
    self.db.debugLevel = 0
    self.db.debugToConsole = true
    self.db.debugToFile = false
    self.db.profiling = false
    self.db.positionalAudio = false
    self.db.dynamicCompression = false
    self.db.aiSounds = false
    self.db.weakAurasIntegration = false
    self.db.discordIntegration = false
end

-- Rebuild database
function BLU:RebuildDatabase()
    self:Trace("Advanced", "RebuildDatabase called")
    if self.Database then
        -- Force reload saved variables
        self.Database:LoadSavedVariables()
        self:Print("Database rebuilt")
    end
end

-- Test sound function
function BLU:PlayTestSound(category, volume)
    self:Trace("Sound", "PlayTestSound called for category '" .. tostring(category) .. "' at volume '" .. tostring(volume or 1.0) .. "'")
    if self.Modules.registry then
        local testSounds = {
            levelup = ADDON_PATH .. "media\\sounds\\level_default.ogg",
            achievement = ADDON_PATH .. "media\\sounds\\achievement_default.ogg",
            quest = ADDON_PATH .. "media\\sounds\\quest_default.ogg"
        }
        
        local soundFile = testSounds[category] or testSounds.levelup
        local channel = self.db and self.db.soundChannel or "Master"
        local vol = volume or 1.0
        
        PlaySoundFile(soundFile, channel)
        return true
    end
    return false
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

-- Show export dialog
function BLU:ShowExportDialog(profileData)
    self:Trace("Profiles", "ShowExportDialog opened")
    -- Create a simple text display dialog
    local frame = CreateFrame("Frame", "BLUExportDialog", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Export Profile")
    
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetWidth(scrollFrame:GetWidth() - 20)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetText(profileData)
    scrollFrame:SetScrollChild(editBox)
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    frame:Show()
end

-- Show import dialog
function BLU:ShowImportDialog()
    self:Trace("Profiles", "ShowImportDialog opened")
    local frame = CreateFrame("Frame", "BLUImportDialog", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 400)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("Import Profile")
    
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)
    
    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetWidth(scrollFrame:GetWidth() - 20)
    editBox:SetAutoFocus(true)
    editBox:SetFontObject(ChatFontNormal)
    scrollFrame:SetScrollChild(editBox)
    
    local importBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    importBtn:SetSize(80, 22)
    importBtn:SetPoint("BOTTOMLEFT", 10, 10)
    importBtn:SetText("Import")
    importBtn:SetScript("OnClick", function()
        local data = editBox:GetText()
        if data and data ~= "" then
            BLU:ImportProfile(data)
            frame:Hide()
        end
    end)
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    closeBtn:SetText("Cancel")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    frame:Show()
end

-- Show character copy dialog
function BLU:ShowCharacterCopyDialog()
    self:Trace("Profiles", "ShowCharacterCopyDialog opened")
    self:Print("Character copy functionality not yet implemented")
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

