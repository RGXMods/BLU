--=====================================================================================
-- BLU - interface/options/general.lua
-- General options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local function IsProfileReady()
    return BLU and BLU.db and BLU.db.profile
end

local function EnsureProfileDefaults()
    if not IsProfileReady() then
        BLU:PrintDebug("[Options/General] EnsureProfileDefaults skipped; profile not ready")
        return false
    end

    local profile = BLU.db.profile
    profile.soundVolume = tonumber(profile.soundVolume) or 100
    profile.soundChannel = profile.soundChannel or "Master"
    profile.maxQueueSize = tonumber(profile.maxQueueSize) or 3
    profile.queueSounds = profile.queueSounds ~= false
    profile.muteInInstances = profile.muteInInstances == true
    profile.muteInCombat = profile.muteInCombat == true
    profile.modules = profile.modules or {}
    return true
end

local function CreateCheckbox(parent, text, x, y, checked, onClick)
    local checkbox = BLU.Modules.design:CreateCheckbox(parent, text)
    checkbox:SetPoint("TOPLEFT", x, y)
    checkbox.check:SetChecked(checked)
    checkbox.check:SetScript("OnClick", onClick)
    return checkbox
end

function BLU.CreateGeneralPanel(panel)
    BLU:PrintDebug("[Options/General] Creating General panel")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 1, -8)
    content:SetPoint("BOTTOMRIGHT", -7, 8)

    local contentBg = content:CreateTexture(nil, "BACKGROUND")
    contentBg:SetAllPoints()
    contentBg:SetColorTexture(0.04, 0.06, 0.08, 0.35)

    if not EnsureProfileDefaults() then
        local unavailable = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        unavailable:SetPoint("TOPLEFT", 0, -12)
        unavailable:SetText("|cffff6666Database not ready. Reopen this tab in a moment.|r")
        content:SetHeight(60)
        return
    end

    local profile = BLU.db.profile

    local coreSection = BLU.Modules.design:CreateSection(content, "Core", "Interface\\Icons\\Achievement_General")
    coreSection:SetPoint("TOPLEFT", content, "TOPLEFT", 2, -2)
    coreSection:SetPoint("TOPRIGHT", content, "TOP", -4, -2)
    coreSection:SetHeight(104)

    CreateCheckbox(coreSection.content, "Enable BLU", 4, -6, profile.enabled ~= false, function(self)
        profile.enabled = self:GetChecked()
        BLU:PrintDebug("[Options/General] Enable BLU set to " .. tostring(profile.enabled))
        if profile.enabled then
            if BLU.Enable then
                BLU:Enable()
            end
            if BLU.ReloadModules then
                BLU:ReloadModules()
            end
        else
            if BLU.Disable then
                BLU:Disable()
            end
        end
    end)

    CreateCheckbox(coreSection.content, "Show welcome message", 4, -32, profile.showWelcomeMessage ~= false, function(self)
        profile.showWelcomeMessage = self:GetChecked()
        BLU:PrintDebug("[Options/General] Show welcome message set to " .. tostring(profile.showWelcomeMessage))
    end)

    local behaviorSection = BLU.Modules.design:CreateSection(content, "Behavior", "Interface\\Icons\\INV_Misc_GroupLooking")
    behaviorSection:SetPoint("TOPLEFT", content, "TOP", 4, -2)
    behaviorSection:SetPoint("TOPRIGHT", content, "TOPRIGHT", -2, -2)
    behaviorSection:SetHeight(104)

    CreateCheckbox(behaviorSection.content, "Mute in instances", 4, -6, profile.muteInInstances == true, function(self)
        profile.muteInInstances = self:GetChecked()
        BLU:PrintDebug("[Options/General] Mute in instances set to " .. tostring(profile.muteInInstances))
    end)

    CreateCheckbox(behaviorSection.content, "Mute in combat", 4, -34, profile.muteInCombat == true, function(self)
        profile.muteInCombat = self:GetChecked()
        BLU:PrintDebug("[Options/General] Mute in combat set to " .. tostring(profile.muteInCombat))
    end)

    StaticPopupDialogs["BLU_ADD_CUSTOM_SOUND"] = {
        text = "Add a custom sound file for BLU.",
        subText = "Enter a short file name like myfile or myfile.ogg. You can also paste a full path like Interface\\AddOns\\myfile.ogg. BLU will try common AddOns folders automatically.",
        button1 = ADD,
        button2 = CANCEL,
        hasEditBox = true,
        maxLetters = 255,
        editBoxWidth = 320,
        OnShow = function(self)
            if self.editBox then
                self._bluCustomSoundText = ""
                self.editBox:SetText("")
                self.editBox:SetAutoFocus(false)
                self.editBox:SetFocus()
            end
        end,
        OnHide = function(self)
            self._bluCustomSoundText = nil
        end,
        EditBoxOnTextChanged = function(self)
            local parent = self:GetParent()
            if parent then
                parent._bluCustomSoundText = self:GetText() or ""
            end
        end,
        EditBoxOnEnterPressed = function(self)
            local parent = self:GetParent()
            if parent and parent.button1 then
                parent._bluCustomSoundText = self:GetText() or ""
                parent.button1:Click()
            end
        end,
        OnAccept = function(self)
            local soundInput = self._bluCustomSoundText or (self.editBox and self.editBox:GetText()) or ""
            soundInput = soundInput:gsub("^%s+", ""):gsub("%s+$", "")
            BLU:PrintDebug("[Options/General] Add Custom Sound popup accepted with input '" .. tostring(soundInput) .. "'")

            if soundInput == "" then
                BLU:Print("|cff00ccffBLU:|r Enter a file name like myfile or myfile.ogg.")
                return
            end

            if BLU.Modules and BLU.Modules["usersounds"] and BLU.Modules["usersounds"].AddCustomSound then
                local ok, result, resolvedPath = BLU.Modules["usersounds"]:AddCustomSound(soundInput)
                if ok then
                    if resolvedPath and soundInput:find("[/\\]") then
                        BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result) .. " (" .. tostring(resolvedPath) .. ")")
                    else
                        BLU:Print("|cff00ccffBLU:|r Added custom sound: " .. tostring(result))
                    end
                else
                    BLU:Print("|cff00ccffBLU:|r Failed to add custom sound: " .. tostring(result))
                end
            else
                BLU:Print("|cff00ccffBLU:|r User custom sounds are not available yet.")
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    content:SetHeight(296)
end
