--=====================================================================================
-- BLU | Combat Lockdown Protection
-- Author: donniedice
-- Description: Prevents UI taint by deferring operations during combat
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

-- Queue for operations blocked by combat
BLU.CombatQueue = {}

-- Register combat events
function BLU:InitializeCombatProtection()
    BLU:RegisterEvent("PLAYER_REGEN_DISABLED", function(...) BLU:OnEnterCombat(...) end)
    BLU:RegisterEvent("PLAYER_REGEN_ENABLED", function(...) BLU:OnLeaveCombat(...) end)
    
    -- Flag for combat state
    self.inCombat = InCombatLockdown()
end

-- Combat state handlers
function BLU:OnEnterCombat()
    self.inCombat = true
    self:PrintDebug("Entered combat - UI operations queued")
end

function BLU:OnLeaveCombat()
    self.inCombat = false
    self:PrintDebug("Left combat - processing queued operations")
    self:ProcessCombatQueue()
end

-- Add operation to combat queue
function BLU:QueueForCombat(func, ...)
    if not InCombatLockdown() then
        -- Execute immediately if not in combat
        return func(...)
    end
    
    -- Queue for later
    local args = {...}
    table.insert(self.CombatQueue, {
        func = func,
        args = args,
        timestamp = GetTime()
    })
    
    self:PrintDebug("Operation queued for after combat")
    return false
end

-- Process queued operations
function BLU:ProcessCombatQueue()
    if InCombatLockdown() then
        return -- Still in combat, wait
    end
    
    local processed = 0
    while #self.CombatQueue > 0 do
        local operation = table.remove(self.CombatQueue, 1)
        if operation and operation.func then
            -- Execute queued operation
            local success, err = pcall(operation.func, unpack(operation.args))
            if not success then
                self:PrintError("Queued operation failed: " .. tostring(err))
            else
                processed = processed + 1
            end
        end
    end
    
    if processed > 0 then
        self:PrintDebug(string.format("Processed %d queued operations", processed))
    end
end

-- Protected frame operations
function BLU:SafeShow(frame)
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:Show()
        return true
    end)
end

function BLU:SafeHide(frame)
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:Hide()
        return true
    end)
end

function BLU:SafeSetPoint(frame, ...)
    if not frame then return false end
    
    local args = {...}
    return self:QueueForCombat(function()
        frame:ClearAllPoints()
        frame:SetPoint(unpack(args))
        return true
    end)
end

function BLU:SafeSetSize(frame, width, height)
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:SetSize(width, height)
        return true
    end)
end

-- Protected button operations
function BLU:SafeSetText(button, text)
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:SetText(text)
        return true
    end)
end

function BLU:SafeEnable(button)
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:Enable()
        return true
    end)
end

function BLU:SafeDisable(button)
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:Disable()
        return true
    end)
end

-- Protected dropdown operations
function BLU:SafeUIDropDownMenu_SetText(dropdown, text)
    if not dropdown then return false end
    
    return self:QueueForCombat(function()
        UIDropDownMenu_SetText(dropdown, text)
        return true
    end)
end

function BLU:SafeUIDropDownMenu_Initialize(dropdown, func)
    if not dropdown or not func then return false end
    
    return self:QueueForCombat(function()
        UIDropDownMenu_Initialize(dropdown, func)
        return true
    end)
end

-- Protected slider operations
function BLU:SafeSetValue(slider, value)
    if not slider then return false end
    
    return self:QueueForCombat(function()
        slider:SetValue(value)
        return true
    end)
end

function BLU:SafeSetMinMaxValues(slider, min, max)
    if not slider then return false end
    
    return self:QueueForCombat(function()
        slider:SetMinMaxValues(min, max)
        return true
    end)
end

-- Protected checkbox operations
function BLU:SafeSetChecked(checkbox, checked)
    if not checkbox then return false end
    
    return self:QueueForCombat(function()
        checkbox:SetChecked(checked)
        return true
    end)
end

-- Protected options panel operations
function BLU:SafeShowOptions()
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:Show()
        end
        return true
    end)
end

function BLU:SafeHideOptions()
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:Hide()
        end
        return true
    end)
end

function BLU:SafeRefreshOptions()
    return self:QueueForCombat(function()
        if BLU.RefreshOptions then
            BLU:RefreshOptions()
        end
        return true
    end)
end

-- Module loading protection
function BLU:SafeLoadModule(moduleName)
    return self:QueueForCombat(function()
        return self:LoadModule(moduleName)
    end)
end

function BLU:SafeUnloadModule(moduleName)
    return self:QueueForCombat(function()
        return self:UnloadModule(moduleName)
    end)
end

function BLU:SafeReloadModules()
    return self:QueueForCombat(function()
        return self:ReloadModules()
    end)
end

-- Profile operations protection
function BLU:SafeLoadProfile(profileName)
    return self:QueueForCombat(function()
        return self:LoadProfile(profileName)
    end)
end

function BLU:SafeCreateProfile(profileName)
    return self:QueueForCombat(function()
        return self:CreateProfile(profileName)
    end)
end

function BLU:SafeDeleteProfile(profileName)
    return self:QueueForCombat(function()
        return self:DeleteProfile(profileName)
    end)
end

-- Test mode protection
function BLU:SafeToggleTestMode()
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:ToggleTestMode()
        end
        return true
    end)
end

-- Sound test protection (sounds can play in combat, but UI updates are protected)
function BLU:SafePlayTestSound(soundType, volume)
    -- Sound playback is allowed in combat
    self:PlayTestSound(soundType, volume)
    
    -- But UI updates are protected
    return self:QueueForCombat(function()
        -- Update any UI elements that show sound is playing
        if self.UpdateSoundPlayingIndicator then
            self:UpdateSoundPlayingIndicator(soundType, true)
            C_Timer.After(2, function()
                self:UpdateSoundPlayingIndicator(soundType, false)
            end)
        end
        return true
    end)
end

-- Clear expired operations from queue (cleanup)
function BLU:CleanCombatQueue()
    local currentTime = GetTime()
    local expireTime = 300 -- 5 minutes
    
    for i = #self.CombatQueue, 1, -1 do
        local operation = self.CombatQueue[i]
        if operation and operation.timestamp then
            if currentTime - operation.timestamp > expireTime then
                table.remove(self.CombatQueue, i)
                self:PrintDebug("Removed expired combat queue operation")
            end
        end
    end
end


