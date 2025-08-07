--=====================================================================================
-- BLU Framework
-- Our own lightweight addon framework (no external dependencies)
--=====================================================================================

-- Removed redundant BluPrint function - using BLU:Print() instead

local addonName, addonTable = ...

-- Create the main addon object
local BLU = {
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

-- Make globally accessible
_G["BLU"] = BLU

-- Framework loaded - functions will be copied to addonTable at the end of this file

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
    local prefix = "|TInterface\\AddOns\\BLU\\media\\images\\icon:16:16|t |cff05dffa[BLU]|r"
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
function BLU:RegisterModule(module, name, description)
    -- Handle both calling conventions
    if type(module) == "string" then
        -- Old style: (name, module)
        local temp = module
        module = name
        name = temp
    end
    
    self.Modules[name] = module
    
    -- Don't auto-init modules here, they're initialized in init.lua
    
    self:PrintDebug("Module registered: " .. name .. (description and (" - " .. description) or ""))
end

-- Get module
function BLU:GetModule(name)
    return self.Modules[name]
end

-- Copy all BLU functions to addon table so other files can access them via local addonName, addonTable = ...
for k, v in pairs(BLU) do
    addonTable[k] = v
end

-- Export
return BLU