--=====================================================================================
-- BLU Framework
-- Our own lightweight addon framework (no external dependencies)
--=====================================================================================

local addonName, addonTable = ...

-- Create the main addon object
BLU = {
    name = addonName,
    version = C_AddOns.GetAddOnMetadata(addonName, "Version"),
    author = C_AddOns.GetAddOnMetadata(addonName, "Author"),
    
    -- Core tables
    modules = {},
    events = {},
    hooks = {},
    timers = {},
    
    -- Settings
    debugMode = false,
    isInitialized = false
}

-- Make globally accessible
_G[addonName] = BLU

--=====================================================================================
-- Event System
--=====================================================================================

-- Create event frame
BLU.eventFrame = CreateFrame("Frame")
BLU.eventFrame:SetScript("OnEvent", function(self, event, ...)
    BLU:FireEvent(event, ...)
end)

-- Register event
function BLU:RegisterEvent(event, callback, id)
    id = id or "core"
    
    if not self.events[event] then
        self.events[event] = {}
        self.eventFrame:RegisterEvent(event)
    end
    
    self.events[event][id] = callback
end

-- Unregister event
function BLU:UnregisterEvent(event, id)
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

-- Fire event
function BLU:FireEvent(event, ...)
    if self.events[event] then
        for id, callback in pairs(self.events[event]) do
            local success, err = pcall(callback, event, ...)
            if not success then
                self:PrintError("Error in event " .. event .. " for " .. id .. ": " .. err)
            end
        end
    end
end

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
    
    for i, cmd in ipairs(commands) do
        _G["SLASH_" .. addonName .. i] = "/" .. cmd
    end
    
    SlashCmdList[addonName] = callback
end

--=====================================================================================
-- Print Functions
--=====================================================================================

-- Print message
function BLU:Print(message)
    local prefix = "|cff05dffa[BLU]|r"
    print(prefix .. " " .. message)
end

-- Print debug message
function BLU:PrintDebug(message)
    if self.debugMode then
        local prefix = "|cff05dffa[BLU]|r |cff808080[DEBUG]|r"
        print(prefix .. " " .. message)
    end
end

-- Print error message
function BLU:PrintError(message)
    local prefix = "|cff05dffa[BLU]|r |cffff0000[ERROR]|r"
    print(prefix .. " " .. message)
end

--=====================================================================================
-- Module System
--=====================================================================================

-- Register module
function BLU:RegisterModule(name, module)
    self.modules[name] = module
    
    -- Call module init if exists
    if module.Init then
        module:Init()
    end
    
    self:PrintDebug("Module registered: " .. name)
end

-- Get module
function BLU:GetModule(name)
    return self.modules[name]
end

--=====================================================================================
-- Initialization
--=====================================================================================

-- Initialize addon
function BLU:Initialize()
    -- Load saved variables
    self:LoadSettings()
    
    -- Register base events
    self:RegisterEvent("ADDON_LOADED", function(event, addon)
        if addon == addonName then
            self:OnAddonLoaded()
        end
    end)
    
    self:RegisterEvent("PLAYER_LOGIN", function()
        self:OnPlayerLogin()
    end)
    
    self:RegisterEvent("PLAYER_LOGOUT", function()
        self:SaveSettings()
    end)
end

-- Addon loaded
function BLU:OnAddonLoaded()
    -- Initialize modules
    self:InitializeModules()
    
    -- Register slash commands
    self:RegisterSlashCommand({"blu", "betterup"}, function(input)
        self:HandleSlashCommand(input)
    end)
    
    self.isInitialized = true
end

-- Player login
function BLU:OnPlayerLogin()
    if self.db and self.db.showWelcomeMessage then
        self:Print("v" .. self.version .. " loaded. Type /blu for options.")
    end
end

-- Initialize
BLU:Initialize()

-- Export
return BLU