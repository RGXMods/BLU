--=====================================================================================
-- BLU | Combat Lockdown Protection
-- Author: donniedice
-- Description: Prevents UI taint by deferring operations during combat
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]
local COMBAT_EVENT_ID_ENTER = "combat_protection_enter"
local COMBAT_EVENT_ID_LEAVE = "combat_protection_leave"

-- Queue for operations blocked by combat
BLU.CombatQueue = {}

-- Register combat events
function BLU:InitializeCombatProtection()
    self:PrintDebug("[Combat] InitializeCombatProtection called")
    _G.BLU:RegisterEvent("PLAYER_REGEN_DISABLED", function(...) BLU:OnEnterCombat(...) end, COMBAT_EVENT_ID_ENTER)
    _G.BLU:RegisterEvent("PLAYER_REGEN_ENABLED", function(...) BLU:OnLeaveCombat(...) end, COMBAT_EVENT_ID_LEAVE)
    
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
    self:PrintDebug("[Combat] QueueForCombat called for function '" .. tostring(func) .. "'")
    if not InCombatLockdown() then
        -- Execute immediately if not in combat
        self:PrintDebug("[Combat] Executing immediately; not in combat")
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
    self:PrintDebug("[Combat] ProcessCombatQueue called with " .. tostring(#self.CombatQueue) .. " queued operations")
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
    self:PrintDebug("[Combat] SafeShow called for frame '" .. tostring(frame and frame.GetName and frame:GetName() or frame) .. "'")
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:Show()
        return true
    end)
end

function BLU:SafeHide(frame)
    self:PrintDebug("[Combat] SafeHide called for frame '" .. tostring(frame and frame.GetName and frame:GetName() or frame) .. "'")
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:Hide()
        return true
    end)
end

function BLU:SafeSetPoint(frame, ...)
    self:PrintDebug("[Combat] SafeSetPoint called for frame '" .. tostring(frame and frame.GetName and frame:GetName() or frame) .. "'")
    if not frame then return false end
    
    local args = {...}
    return self:QueueForCombat(function()
        frame:ClearAllPoints()
        frame:SetPoint(unpack(args))
        return true
    end)
end

function BLU:SafeSetSize(frame, width, height)
    self:PrintDebug("[Combat] SafeSetSize called for frame '" .. tostring(frame and frame.GetName and frame:GetName() or frame) .. "' => " .. tostring(width) .. "x" .. tostring(height))
    if not frame then return false end
    
    return self:QueueForCombat(function()
        frame:SetSize(width, height)
        return true
    end)
end

-- Protected button operations
function BLU:SafeSetText(button, text)
    self:PrintDebug("[Combat] SafeSetText called for button '" .. tostring(button and button.GetName and button:GetName() or button) .. "'")
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:SetText(text)
        return true
    end)
end

function BLU:SafeEnable(button)
    self:PrintDebug("[Combat] SafeEnable called for button '" .. tostring(button and button.GetName and button:GetName() or button) .. "'")
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:Enable()
        return true
    end)
end

function BLU:SafeDisable(button)
    self:PrintDebug("[Combat] SafeDisable called for button '" .. tostring(button and button.GetName and button:GetName() or button) .. "'")
    if not button then return false end
    
    return self:QueueForCombat(function()
        button:Disable()
        return true
    end)
end

-- Protected dropdown operations
function BLU:SafeUIDropDownMenu_SetText(dropdown, text)
    self:PrintDebug("[Combat] SafeUIDropDownMenu_SetText called for dropdown '" .. tostring(dropdown and dropdown.GetName and dropdown:GetName() or dropdown) .. "'")
    if not dropdown then return false end
    
    return self:QueueForCombat(function()
        UIDropDownMenu_SetText(dropdown, text)
        return true
    end)
end

function BLU:SafeUIDropDownMenu_Initialize(dropdown, func)
    self:PrintDebug("[Combat] SafeUIDropDownMenu_Initialize called for dropdown '" .. tostring(dropdown and dropdown.GetName and dropdown:GetName() or dropdown) .. "'")
    if not dropdown or not func then return false end
    
    return self:QueueForCombat(function()
        UIDropDownMenu_Initialize(dropdown, func)
        return true
    end)
end

-- Protected slider operations
function BLU:SafeSetValue(slider, value)
    self:PrintDebug("[Combat] SafeSetValue called for slider '" .. tostring(slider and slider.GetName and slider:GetName() or slider) .. "' => " .. tostring(value))
    if not slider then return false end
    
    return self:QueueForCombat(function()
        slider:SetValue(value)
        return true
    end)
end

function BLU:SafeSetMinMaxValues(slider, min, max)
    self:PrintDebug("[Combat] SafeSetMinMaxValues called for slider '" .. tostring(slider and slider.GetName and slider:GetName() or slider) .. "' => [" .. tostring(min) .. ", " .. tostring(max) .. "]")
    if not slider then return false end
    
    return self:QueueForCombat(function()
        slider:SetMinMaxValues(min, max)
        return true
    end)
end

-- Protected checkbox operations
function BLU:SafeSetChecked(checkbox, checked)
    self:PrintDebug("[Combat] SafeSetChecked called for checkbox '" .. tostring(checkbox and checkbox.GetName and checkbox:GetName() or checkbox) .. "' => " .. tostring(checked))
    if not checkbox then return false end
    
    return self:QueueForCombat(function()
        checkbox:SetChecked(checked)
        return true
    end)
end

-- Protected options panel operations
function BLU:SafeShowOptions()
    self:PrintDebug("[Combat] SafeShowOptions called")
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:Show()
        end
        return true
    end)
end

function BLU:SafeHideOptions()
    self:PrintDebug("[Combat] SafeHideOptions called")
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:Hide()
        end
        return true
    end)
end

function BLU:SafeRefreshOptions()
    self:PrintDebug("[Combat] SafeRefreshOptions called")
    return self:QueueForCombat(function()
        if BLU.RefreshOptions then
            BLU:RefreshOptions()
        end
        return true
    end)
end

-- Module loading protection
function BLU:SafeLoadModule(moduleName)
    self:PrintDebug("[Combat] SafeLoadModule called for '" .. tostring(moduleName) .. "'")
    return self:QueueForCombat(function()
        return self:LoadModule(moduleName)
    end)
end

function BLU:SafeUnloadModule(moduleName)
    self:PrintDebug("[Combat] SafeUnloadModule called for '" .. tostring(moduleName) .. "'")
    return self:QueueForCombat(function()
        return self:UnloadModule(moduleName)
    end)
end

function BLU:SafeReloadModules()
    self:PrintDebug("[Combat] SafeReloadModules called")
    return self:QueueForCombat(function()
        return self:ReloadModules()
    end)
end

-- Profile operations protection
function BLU:SafeLoadProfile(profileName)
    self:PrintDebug("[Combat] SafeLoadProfile called for '" .. tostring(profileName) .. "'")
    return self:QueueForCombat(function()
        return self:LoadProfile(profileName)
    end)
end

function BLU:SafeCreateProfile(profileName)
    self:PrintDebug("[Combat] SafeCreateProfile called for '" .. tostring(profileName) .. "'")
    return self:QueueForCombat(function()
        return self:CreateProfile(profileName)
    end)
end

function BLU:SafeDeleteProfile(profileName)
    self:PrintDebug("[Combat] SafeDeleteProfile called for '" .. tostring(profileName) .. "'")
    return self:QueueForCombat(function()
        return self:DeleteProfile(profileName)
    end)
end

-- Test mode protection
function BLU:SafeToggleTestMode()
    self:PrintDebug("[Combat] SafeToggleTestMode called")
    return self:QueueForCombat(function()
        if BLU.Settings then
            BLU.Settings:ToggleTestMode()
        end
        return true
    end)
end

-- Sound test protection (sounds can play in combat, but UI updates are protected)
function BLU:SafePlayTestSound(soundType, volume)
    self:PrintDebug("[Combat] SafePlayTestSound called for '" .. tostring(soundType) .. "'")
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

-- Utility function to check if operation should be queued
function BLU:ShouldQueueOperation()
    self:PrintDebug("[Combat] ShouldQueueOperation called")
    return InCombatLockdown()
end

-- Clear expired operations from queue (cleanup)
function BLU:CleanCombatQueue()
    self:PrintDebug("[Combat] CleanCombatQueue called")
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

local CombatProtection = {}
function CombatProtection:Init()
    BLU:InitializeCombatProtection()
    BLU:PrintDebug("Combat protection module initialized")
end
BLU.Modules["combat_protection"] = CombatProtection
