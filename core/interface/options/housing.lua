--=====================================================================================
-- BLU - interface/options/housing.lua
-- Housing options panel
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

function BLU.CreateHousingPanel(panel)
    BLU:PrintDebug("[Options/Housing] Creating Housing sound panel")
    local content = CreateFrame("Frame", nil, panel)
    content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    local titleBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("RIGHT", 0, 0)
    titleBar:SetHeight(44)
    titleBar:SetBackdrop(BLU.Modules.design.Backdrops.Solid)
    titleBar:SetBackdropColor(0.06, 0.10, 0.16, 0.95)
    titleBar:SetBackdropBorderColor(0.10, 0.20, 0.28, 1)

    local icon = titleBar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Trade_Blacksmithing")

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    title:SetText("|cff05dffaHousing Sounds|r")

    local switchFrame = CreateFrame("Frame", nil, titleBar)
    switchFrame:SetSize(44, 20)
    switchFrame:SetPoint("RIGHT", -10, 0)

    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

    local toggle = CreateFrame("Button", nil, switchFrame)
    toggle:SetSize(18, 18)
    toggle:EnableMouse(true)

    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    toggleBg:SetVertexColor(1, 1, 1, 1)

    local status = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", switchFrame, "LEFT", -6, 0)

    local function UpdateToggleState(enabled)
        toggle:ClearAllPoints()
        if enabled then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
            switchBg:SetVertexColor(unpack(BLU.Modules.design.Colors.Primary))
            status:SetText("|cff00ff00ON|r")
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
            switchBg:SetVertexColor(0.3, 0.3, 0.3, 1)
            status:SetText("|cffff0000OFF|r")
        end
    end

    local function IsModuleEnabled()
        if not (BLU.db and BLU.db.profile) then
            return true
        end

        local modules = BLU.db.profile.modules
        if modules and modules.housing ~= nil then
            return modules.housing ~= false
        end
        if BLU.db.profile.enableHousing ~= nil then
            return BLU.db.profile.enableHousing ~= false
        end
        return true
    end

    local function SetModuleEnabledState(enabled)
        BLU.db.profile.modules = BLU.db.profile.modules or {}
        BLU.db.profile.modules.housing = enabled
        BLU.db.profile.enableHousing = enabled
    end

    UpdateToggleState(IsModuleEnabled())

    toggle:SetScript("OnClick", function()
        if not (BLU.db and BLU.db.profile) then
            return
        end

        local newState = not IsModuleEnabled()
        SetModuleEnabledState(newState)
        BLU:PrintDebug("[Options/Housing] Toggled Housing module to " .. tostring(newState))
        UpdateToggleState(newState)

        if newState then
            if BLU.LoadModule then
                BLU:LoadModule("features", "housing")
            end
        else
            if BLU.UnloadModule then
                BLU:UnloadModule("housing")
            end
        end

        C_Timer.After(0, function()
            if toggle and toggle:IsVisible() then
                UpdateToggleState(IsModuleEnabled())
            end
        end)
    end)

    if not BLU.CreateSoundDropdown then
        BLU:PrintError("Housing panel could not initialize its sound dropdowns")
        return
    end

	BLU.CreateSoundDropdown(content, "housing", "House XP Gained Sound", -54, "housingxpgained")
	BLU.CreateSoundDropdown(content, "housing", "House Leveled Up Sound", -124, "housingleveledup")
	BLU.CreateSoundDropdown(content, "housing", "House Rewards Received Sound", -194, "housingrewardsreceived")
	BLU.CreateSoundDropdown(content, "housing", "New Decor Collected Sound", -264, "housingdecorcollected")
end
