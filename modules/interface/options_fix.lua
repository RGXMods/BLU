--=====================================================================================
-- BLU - interface/options_fix.lua
-- Direct options panel creation to fix registration issues
--=====================================================================================

local addonName, BLU = ...

-- Create a frame that will handle the panel creation
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Wait a moment for everything to load
        C_Timer.After(0.5, function()
            -- Create the panel directly
            if not BLU.OptionsPanel then
                BLU:Print("Creating BLU options panel...")
                
                -- Create main frame
                local panel = CreateFrame("Frame", "BLUOptionsPanel", UIParent)
                panel.name = "Better Level-Up!"
                
                -- Store reference
                BLU.OptionsPanel = panel
                
                -- Add basic content
                local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
                title:SetPoint("TOPLEFT", 16, -16)
                title:SetText("|cff05dffaB|retter |cff05dffaL|revel-|cff05dffaU|rp!")
                
                local subtitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
                subtitle:SetText("Type /blu to open the full options panel with tabs")
                
                -- Register it immediately
                if Settings and Settings.RegisterAddOnCategory then
                    -- New API
                    local category = Settings.RegisterCanvasLayoutCategory(panel, "Better Level-Up!")
                    Settings.RegisterAddOnCategory(category)
                    BLU.OptionsCategory = category
                    BLU:Print("Options registered with Settings API")
                elseif InterfaceOptions_AddCategory then
                    -- Legacy API  
                    InterfaceOptions_AddCategory(panel)
                    BLU.OptionsCategory = panel
                    BLU:Print("Options registered with legacy API")
                end
                
                -- Create the actual tabbed panel when opened
                BLU.OpenOptions = function()
                    -- First check if the full panel exists
                    if not BLU.FullOptionsPanel then
                        -- Create the full tabbed panel
                        if BLU.Modules and BLU.Modules.options_new then
                            if BLU.Modules.options_new.CreateOptionsPanel then
                                BLU.Modules.options_new:CreateOptionsPanel()
                            end
                        end
                    end
                    
                    -- Try to open it
                    if Settings and Settings.OpenToCategory and BLU.OptionsCategory then
                        Settings.OpenToCategory(BLU.OptionsCategory.ID or BLU.OptionsCategory)
                    elseif InterfaceOptionsFrame_OpenToCategory then
                        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsPanel)
                        InterfaceOptionsFrame_OpenToCategory(BLU.OptionsPanel) -- Call twice (Blizzard bug)
                    else
                        BLU:Print("Cannot open options - try opening from ESC menu")
                    end
                end
                
                BLU:Print("|cff00ff00BLU options panel created and registered!|r")
            end
        end)
    end
end)