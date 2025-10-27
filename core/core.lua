--=====================================================================================
-- BLU Framework
-- Our own lightweight addon framework (no external dependencies)
--=====================================================================================

-- Removed redundant BluPrint function - using BLU:Print() instead

local addonName, addonTable = ...

print("BLU: Core loading started.")

-- Create the main addon object (global)
BLU = {
    name = addonName,
    version = "6.0.0-alpha",
    author = C_AddOns.GetAddOnMetadata(addonName, "Author"),
    
    -- Core tables
    Modules = {},
    LoadedModules = {},
    events = {},
    hooks = {},
    timers = {},
    
    -- Settings
    debugMode = true,  -- Debug on to see tab creation
    isInitialized = false
}

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
    end
end

--=====================================================================================
-- Hook System
--=====================================================================================

-- Hook function
function BLU:Hook(target, method, callback)
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
end

-- Unhook function
function BLU:Unhook(target, method)
    if self.hooks[target] and self.hooks[target][method] then
        target[method] = self.hooks[target][method]
        self.hooks[target][method] = nil
    end
end

--=====================================================================================
-- Slash Commands
--=====================================================================================

-- Register slash command
function BLU:RegisterSlashCommand(command, callback)
    -- Support multiple commands
    local commands = type(command) == "table" and command or {command}
    
    -- Use a unique identifier for this addon's commands
    local cmdName = addonName .. "CMD"
    
    for i, cmd in ipairs(commands) do
        _G["SLASH_" .. cmdName .. i] = "/" .. cmd
    end
    
    SlashCmdList[cmdName] = callback
end

--=====================================================================================
-- Print Functions
--=====================================================================================

-- Print message
function BLU:Print(message)
    local prefix = "|TInterface\\AddOns\\BLU\\media\\Textures\\icon:16:16|t |cff05dffa[BLU]|r"
    print(prefix .. " " .. message)
end

-- Print debug message
function BLU:PrintDebug(message)
    if self.debugMode then
        local prefix = "|TInterface\\Icons\\INV_Misc_Gear_06:16:16|t|cff05dffa[BLU]|r |cff808080[DEBUG]|r"
        print(prefix .. " " .. message)
    end
end

-- Print error message
function BLU:PrintError(message)
    local prefix = "|cff05dffa[BLU]|r |cffff0000[ERROR]|r"
    print(prefix .. " " .. message)
end

-- Show welcome message
function BLU:ShowWelcomeMessage()
    -- Check if first time loading
    local isFirstTime = not (self.db and self.db.global and self.db.global.notFirstTime)
    
    if isFirstTime then
        -- First time welcome
        self:Print("|cff00ccff========================================|r")
        self:Print("|cff00ccffWelcome to Better Level-Up!|r")
        self:Print("Thank you for installing BLU v6.0.0-alpha")
        self:Print("")
        self:Print("Replace boring WoW sounds with iconic audio from 50+ games!")
        self:Print("")
        self:Print("Quick Start:")
        self:Print("  |cff05dffa/blu|r - Open settings panel")
        self:Print("  |cff05dffa/blu test|r - Play a test sound")
        self:Print("  |cff05dffa/blu help|r - Show all commands")
        self:Print("")
        self:Print("Join our Discord: |cffffd700discord.gg/rgxmods|r")
        self:Print("|cff00ccff========================================|r")
        
        -- Mark as not first time
        if self.db and self.db.global then
            self.db.global.notFirstTime = true
        end
    else
        -- Regular welcome (if enabled)
        if self.db and self.db.profile and self.db.profile.showWelcomeMessage ~= false then
            local version = GetAddOnMetadata("BLU", "Version") or "6.0.0-alpha"
            self:Print("|cff00ccffBLU|r " .. version .. " loaded! Type |cff05dffa/blu|r for options")
        end
    end
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
    return self.Modules[name]
end

--=====================================================================================
-- Profile Management Functions
--=====================================================================================

-- Create profile
function BLU:CreateProfile(name)
    if not self.Database then
        self:PrintError("Database not initialized")
        return false
    end
    return self.Database:CreateProfile(name)
end

-- Delete profile
function BLU:DeleteProfile(name)
    if not self.Database then
        self:PrintError("Database not initialized")
        return false
    end
    return self.Database:DeleteProfile(name)
end

-- Load profile
function BLU:LoadProfile(name)
    if not self.Database then
        self:PrintError("Database not initialized")
        return false
    end
    return self.Database:SetProfile(name)
end

-- Save profile
function BLU:SaveProfile(name)
    if not self.Database then
        self:PrintError("Database not initialized")
        return false
    end
    -- Force save current settings
    self.Database:Save()
    return true
end

-- Rename profile
function BLU:RenameProfile(oldName, newName)
    if not self.Database then
        self:PrintError("Database not initialized")
        return false
    end
    
    if not self.Database:CopyProfile(oldName, newName) then
        return false
    end
    
    -- Switch to new profile if it was the active one
    if BLUDB.currentProfile == oldName then
        self.Database:SetProfile(newName)
    end
    
    -- Delete old profile
    return self.Database:DeleteProfile(oldName)
end

-- Serialize profile for export
function BLU:SerializeProfile(profileName)
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
    if self.Modules.registry and self.Modules.registry.soundCache then
        self.Modules.registry.soundCache = {}
        self:Print("Sound cache cleared")
    end
end

-- Reset advanced settings
function BLU:ResetAdvancedSettings()
    -- Reset only advanced settings to defaults
    local profile = self.db.profile
    if profile then
        profile.soundPooling = false
        profile.asyncLoading = false
        profile.soundQueueSize = 3
        profile.fadeTime = 200
        profile.lazyLoading = true
        profile.moduleTimeout = 5
        profile.debugLevel = 0
        profile.debugToConsole = true
        profile.debugToFile = false
        profile.profiling = false
        profile.positionalAudio = false
        profile.dynamicCompression = false
        profile.aiSounds = false
        profile.weakAurasIntegration = false
        profile.discordIntegration = false
    end
end

-- Rebuild database
function BLU:RebuildDatabase()
    if self.Database then
        -- Force reload saved variables
        self.Database:LoadSavedVariables()
        self:Print("Database rebuilt")
    end
end

-- Test sound function
function BLU:PlayTestSound(category, volume)
    if self.Modules.registry then
        local testSounds = {
            levelup = "Interface\AddOns\BLU\media\sounds\level_default.ogg",
            achievement = "Interface\AddOns\BLU\media\sounds\achievement_default.ogg",
            quest = "Interface\AddOns\BLU\media\sounds\quest_default.ogg"
        }
        
        local soundFile = testSounds[category] or testSounds.levelup
        local channel = self.db and self.db.profile and self.db.profile.soundChannel or "Master"
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
        if self.db and self.db.profile and self.db.profile.modules then
            self.db.profile.modules[moduleId] = true
        end
        self:PrintDebug("Enabled module: " .. moduleId)
        return true
    end
    return false
end

function BLU:DisableModule(moduleId)
    if self.db and self.db.profile and self.db.profile.modules then
        self.db.profile.modules[moduleId] = false
    end
    self:PrintDebug("Disabled module: " .. moduleId)
    return true
end

-- Reload modules function
function BLU:ReloadModules()
    if self.Modules.loader and self.Modules.loader.LoadModulesFromSettings then
        self.Modules.loader:LoadModulesFromSettings()
    end
end

-- Show export dialog
function BLU:ShowExportDialog(profileData)
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
    self:Print("Character copy functionality not yet implemented")
end

function BLU:Enable()
    -- Already enabled
end

function BLU:Disable()
    self:OnDisable()
end

function BLU:OnDisable()
    for name, module in pairs(self.LoadedModules) do
        if module and module.OnDisable then
            module:OnDisable()
        end
    end
end

BLU:RegisterEvent("PLAYER_LOGOUT", function(event)
    BLU:OnDisable()
end)

-- Copy all BLU functions to addon table so other files can access them via local addonName, addonTable = ...

