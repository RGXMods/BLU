--=====================================================================================
-- BLU - interface/dropdown.lua
-- Shared dropdown layout utilities
-- Used by sound_panel.lua and profiles.lua (and any future dropdown consumers).
--
-- API:
--   BLU.Modules.dropdown:GetListFrame(level)
--   BLU.Modules.dropdown:ShortenLabel(text, maxChars) -> text, wasTruncated
--   BLU.Modules.dropdown:ForceWidth(level, minWidth, leftInset, opts)
--     opts = { deleteKey = "bluDeleteButton", previewKey = "bluPreviewButton" }
--
-- ForceWidth defers via C_Timer.After(0) so it always runs after WoW's own
-- UIDropDownMenu_AddButton sizing.  It does two passes:
--   Pass 1 - measure rendered GetStringWidth() on every button to find needed width
--   Pass 2 - apply list frame + button widths, re-anchor text and inline widgets
--=====================================================================================

local BLU = _G["BLU"]

local DropdownUtil = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules.dropdown = DropdownUtil

-- WoW sizes buttons as: listFrame:GetWidth() - (UIDROPDOWNMENU_BORDER_THICKNESS * 2)
-- UIDROPDOWNMENU_BORDER_THICKNESS = 15, so buttons = listFrame - 30
local BORDER_THICKNESS = UIDROPDOWNMENU_BORDER_THICKNESS or 15
local BORDER_PAD = BORDER_THICKNESS * 2  -- 30

function DropdownUtil:GetListFrame(level)
    return _G["DropDownList" .. level] or _G["LibDropDownMenu_List" .. level]
end

function DropdownUtil:ShortenLabel(text, maxChars)
    if type(text) ~= "string" then return "", false end
    if #text <= maxChars then return text, false end
    return string.sub(text, 1, maxChars - 3) .. "...", true
end

function DropdownUtil:StyleButton(button, options)
    if not button then
        return
    end

    options = options or {}

    if button.bluPreviewButton then
        button.bluPreviewButton:SetFrameStrata("TOOLTIP")
        button.bluPreviewButton:SetFrameLevel(button:GetFrameLevel() + 5)
    end

    if button.bluDeleteButton then
        button.bluDeleteButton:SetFrameStrata("TOOLTIP")
        button.bluDeleteButton:SetFrameLevel(button:GetFrameLevel() + 5)
    end
end

function DropdownUtil:StyleLastAddedButton(level, options)
    local listFrame = self:GetListFrame(level)
    if not listFrame or not listFrame.numButtons then
        return
    end

    local button = _G[listFrame:GetName() .. "Button" .. listFrame.numButtons]
    self:StyleButton(button, options)
end

function DropdownUtil:ResetLevel(level)
    local listFrame = self:GetListFrame(level)
    if not listFrame then
        return
    end

    local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
    for index = 1, maxButtons do
        local button = _G[listFrame:GetName() .. "Button" .. index]
        if button then
            if button.bluPreviewButton then
                button.bluPreviewButton:Hide()
            end
            if button.bluDeleteButton then
                button.bluDeleteButton:Hide()
            end
            if button.bluCountLabel then
                button.bluCountLabel:Hide()
            end

            if button:IsShown() then
                self:StyleButton(button)
            end
        end
    end
end

--[[
  ForceWidth(level, minWidth, leftInset, opts)
    level      - dropdown level (1, 2, 3 …)
    minWidth   - floor width; list will never shrink below this
    leftInset  - left px for NormalText (default 10)
    opts       - optional table:
        deleteKey  (string) - button field name for inline delete widget  (default "bluDeleteButton")
        previewKey (string) - button field name for inline preview widget (default "bluPreviewButton")
]]
function DropdownUtil:ForceWidth(level, minWidth, leftInset, opts)
    leftInset = leftInset or 10
    opts = opts or {}
    local deleteKey  = opts.deleteKey  or "bluDeleteButton"
    local previewKey = opts.previewKey or "bluPreviewButton"
    local countKey   = opts.countKey
    local compactRightControl = opts.compactRightControl
    local util = self

    C_Timer.After(0, function()
        local listFrame = util:GetListFrame(level)
        if not listFrame or not listFrame:IsShown() then return end

        local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32

        -- Pass 1: find the widest button content needed
        -- neededContentWidth = leftInset + text + rightReservation
        -- listFrame width    = neededContentWidth + BORDER_PAD (WoW border on each side)
        local neededContentWidth = (minWidth or 200) - BORDER_PAD
        local visibleButtonCount = 0
        for i = 1, maxButtons do
            local btn = _G[listFrame:GetName() .. "Button" .. i]
            if btn and btn:IsShown() then
                visibleButtonCount = visibleButtonCount + 1
                local nt          = _G[btn:GetName() .. "NormalText"]
                local expandArrow = _G[btn:GetName() .. "ExpandArrow"]
                local hasPreview  = btn[previewKey] and btn[previewKey]:IsShown()
                local hasDelete   = btn[deleteKey]  and btn[deleteKey]:IsShown()
                local countLabel  = countKey and btn[countKey]
                local hasCount    = countLabel and countLabel:IsShown()
                local hasArrow    = expandArrow     and expandArrow:IsShown()
                local tw          = nt and math.ceil(nt:GetStringWidth() or 0) or 0
                local cw          = hasCount and math.ceil(countLabel:GetStringWidth() or 0) or 0
                -- right reservation for inline widget + gap
                local rightRes = hasPreview and 40 or (hasDelete and 24 or ((hasArrow and 14 or 6) + (hasCount and (cw + 6) or 0)))
                neededContentWidth = math.max(neededContentWidth, leftInset + tw + rightRes)
            end
        end

        if visibleButtonCount == 0 then
            return
        end

        -- Pass 2: apply sizes and re-anchor everything
        local btnWidth   = neededContentWidth
        local frameWidth = neededContentWidth + BORDER_PAD
        listFrame:SetWidth(frameWidth)

        for i = 1, maxButtons do
            local btn = _G[listFrame:GetName() .. "Button" .. i]
            if btn and btn:IsShown() then
                util:StyleButton(btn)
                btn:SetWidth(btnWidth)
                local nt          = _G[btn:GetName() .. "NormalText"]
                local expandArrow = _G[btn:GetName() .. "ExpandArrow"]
                local previewBtn  = btn[previewKey]
                local deleteBtn   = btn[deleteKey]
                local countLabel  = countKey and btn[countKey]
                local hasPreview  = previewBtn and previewBtn:IsShown()
                local hasDelete   = deleteBtn  and deleteBtn:IsShown()
                local hasCount    = countLabel and countLabel:IsShown()
                local hasArrow    = expandArrow and expandArrow:IsShown()
                local textWidth   = nt and math.ceil(nt:GetStringWidth() or 0) or 0
                local anchorX     = leftInset + textWidth + 4

                -- Arrow can either align to the list edge or sit just after the label.
                if expandArrow and compactRightControl and nt and hasArrow then
                    expandArrow:ClearAllPoints()
                    expandArrow:SetPoint("LEFT", btn, "LEFT", anchorX, 0)
                elseif expandArrow then
                    expandArrow:ClearAllPoints()
                    expandArrow:SetPoint("RIGHT", btn, "RIGHT", -3, 0)
                end

                -- Inline preview button (Play)
                if hasPreview then
                    previewBtn:ClearAllPoints()
                    if compactRightControl and nt then
                        previewBtn:SetPoint("LEFT", btn, "LEFT", anchorX, 0)
                    else
                        previewBtn:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
                    end
                    if nt then
                        nt:ClearAllPoints()
                        nt:SetPoint("LEFT",  btn, "LEFT",  leftInset, 0)
                        nt:SetPoint("RIGHT", previewBtn, "LEFT", -6, 0)
                        nt:SetJustifyH("LEFT")
                        nt:SetWordWrap(false)
                        if nt.SetNonSpaceWrap then
                            nt:SetNonSpaceWrap(false)
                        end
                        if nt.SetMaxLines then
                            nt:SetMaxLines(1)
                        end
                    end
                -- Inline delete button (x)
                elseif hasDelete then
                    deleteBtn:ClearAllPoints()
                    if compactRightControl and nt then
                        deleteBtn:SetPoint("LEFT", btn, "LEFT", anchorX, 0)
                    else
                        deleteBtn:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
                    end
                    if nt then
                        nt:ClearAllPoints()
                        nt:SetPoint("LEFT",  btn, "LEFT",  leftInset, 0)
                        nt:SetPoint("RIGHT", deleteBtn, "LEFT", -6, 0)
                        nt:SetJustifyH("LEFT")
                        nt:SetWordWrap(false)
                        if nt.SetNonSpaceWrap then
                            nt:SetNonSpaceWrap(false)
                        end
                        if nt.SetMaxLines then
                            nt:SetMaxLines(1)
                        end
                    end
                -- Plain text (with or without expand arrow)
                else
                    if nt then
                        nt:ClearAllPoints()
                        nt:SetPoint("LEFT",  btn, "LEFT",  leftInset, 0)
                        if hasCount and countLabel then
                            if hasArrow and expandArrow then
                                expandArrow:ClearAllPoints()
                                expandArrow:SetPoint("RIGHT", btn, "RIGHT", -3, 0)
                            end
                            countLabel:ClearAllPoints()
                            if hasArrow and expandArrow then
                                countLabel:SetPoint("RIGHT", expandArrow, "LEFT", -4, 0)
                            else
                                countLabel:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
                            end
                            nt:SetPoint("RIGHT", countLabel, "LEFT", -6, 0)
                        elseif not compactRightControl then
                            nt:SetPoint("RIGHT", btn, "RIGHT", hasArrow and -16 or -6, 0)
                        end
                        nt:SetJustifyH("LEFT")
                        nt:SetWordWrap(false)
                        if nt.SetNonSpaceWrap then
                            nt:SetNonSpaceWrap(false)
                        end
                        if nt.SetMaxLines then
                            nt:SetMaxLines(1)
                        end
                    end
                end
            end
        end
    end)
end
