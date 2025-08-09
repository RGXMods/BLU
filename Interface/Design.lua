--=====================================================================================
-- BLU | UI Design System
-- Author: donniedice
-- Description: Design constants and styling for BLU interface
--=====================================================================================

local addonName, BLU = ...

-- Design system namespace
BLU.Design = BLU.Design or {}
local Design = BLU.Design

-- Color palette
Design.Colors = {
    Primary = {0.02, 0.37, 1, 1},      -- BLU blue
    Secondary = {1, 0.84, 0, 1},        -- RGX gold
    Success = {0, 1, 0, 1},             -- Green
    Warning = {1, 0.65, 0, 1},          -- Orange
    Error = {1, 0, 0, 1},                -- Red
    Background = {0.05, 0.05, 0.05, 0.95},
    Border = {0.02, 0.37, 1, 1}
}

-- Spacing
Design.Padding = 10
Design.Margin = 5

-- Fonts
Design.TitleFont = "GameFontNormalLarge"
Design.NormalFont = "GameFontNormal"
Design.SmallFont = "GameFontNormalSmall"