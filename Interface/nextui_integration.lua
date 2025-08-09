--=====================================================================================
-- BLU + NextUI Integration
-- Modernizes BLU interface using NextUI React-like components
--=====================================================================================

local addonName, BLU = ...

-- Wait for NextUI to load
local function IntegrateNextUI()
    if not _G.NextUI then
        print("|cffff0000BLU:|r NextUI framework not found. Using legacy interface.")
        return false
    end
    
    print("|cff00ff00BLU:|r NextUI framework detected! Loading modern interface...")
    
    -- Import NextUI components
    local useState = NextUI.useState
    local useEffect = NextUI.useEffect
    local useContext = NextUI.useContext
    local useMemo = NextUI.useMemo
    local useCallback = NextUI.useCallback
    
    -- Import components
    local Frame = _G.Frame
    local Button = _G.Button
    local Text = _G.Text
    local Input = _G.Input
    local Dropdown = _G.Dropdown
    local Slider = _G.Slider
    local Checkbox = _G.Checkbox
    local TabPanel = _G.TabPanel
    
    -- Create BLU context for shared state
    BLU.Context = createContext({
        volume = 100,
        enabled = true,
        selectedSounds = {},
        modules = {},
        theme = "dark"
    })
    
    -- Modern BLU Settings Component
    local function BLUSettings(props)
        local volume, setVolume = useState(BLU.db.profile.volume or 100)
        local enabled, setEnabled = useState(BLU.db.profile.enabled)
        local activeTab, setActiveTab = useState(1)
        
        -- Save settings on change
        useEffect(function()
            BLU.db.profile.volume = volume
            BLU.db.profile.enabled = enabled
        end, {volume, enabled})
        
        -- Tab definitions
        local tabs = {
            {
                label = "General",
                content = GeneralTab({
                    volume = volume,
                    setVolume = setVolume,
                    enabled = enabled,
                    setEnabled = setEnabled
                })
            },
            {
                label = "Sounds",
                content = SoundsTab()
            },
            {
                label = "Modules",
                content = ModulesTab()
            },
            {
                label = "Profiles",
                content = ProfilesTab()
            },
            {
                label = "About",
                content = AboutTab()
            }
        }
        
        return Frame({
            name = "BLUSettingsNextUI",
            size = {800, 600},
            point = {"CENTER"},
            movable = true,
            backdrop = {
                bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                edgeSize = 32
            },
            children = {
                -- Title
                Text({
                    text = "BLU Settings (NextUI)",
                    font = "GameFontNormalLarge",
                    point = {"TOP", 0, -16}
                }),
                
                -- Close button
                Button({
                    text = "X",
                    size = {24, 24},
                    point = {"TOPRIGHT", -10, -10},
                    onClick = function()
                        BLUSettingsNextUI:Hide()
                    end
                }),
                
                -- Tab panel
                TabPanel({
                    tabs = tabs,
                    size = {760, 520},
                    point = {"TOP", 0, -50},
                    defaultTab = activeTab,
                    onTabChange = function(index)
                        setActiveTab(index)
                    end
                })
            }
        })
    end
    
    -- General Tab Component
    local function GeneralTab(props)
        return Frame({
            size = {740, 480},
            children = {
                Text({
                    text = "General Settings",
                    font = "GameFontNormalLarge",
                    point = {"TOPLEFT", 20, -20}
                }),
                
                Checkbox({
                    label = "Enable BLU",
                    checked = props.enabled,
                    onChange = props.setEnabled,
                    point = {"TOPLEFT", 20, -60}
                }),
                
                Text({
                    text = "Master Volume",
                    point = {"TOPLEFT", 20, -100}
                }),
                
                Slider({
                    min = 0,
                    max = 100,
                    value = props.volume,
                    onChange = props.setVolume,
                    size = {300, 20},
                    point = {"TOPLEFT", 20, -120},
                    label = "Volume: " .. props.volume .. "%"
                })
            }
        })
    end
    
    -- Sounds Tab Component with dropdowns
    local function SoundsTab()
        local sounds = GetAllSounds and GetAllSounds() or {}
        local events = {
            {id = "levelup", name = "Level Up"},
            {id = "achievement", name = "Achievement"},
            {id = "quest", name = "Quest Complete"},
            {id = "reputation", name = "Reputation"},
            {id = "honor", name = "Honor"},
            {id = "battlepet", name = "Battle Pet"},
            {id = "renown", name = "Renown"},
            {id = "tradingpost", name = "Trading Post"},
            {id = "delve", name = "Delve"}
        }
        
        return Frame({
            size = {740, 480},
            children = {
                Text({
                    text = "Sound Configuration",
                    font = "GameFontNormalLarge",
                    point = {"TOPLEFT", 20, -20}
                }),
                
                Frame({
                    size = {700, 400},
                    point = {"TOPLEFT", 20, -60},
                    children = (function()
                        local items = {}
                        for i, event in ipairs(events) do
                            local yOffset = -40 * (i - 1)
                            
                            -- Event label
                            table.insert(items, Text({
                                text = event.name,
                                point = {"TOPLEFT", 0, yOffset}
                            }))
                            
                            -- Sound dropdown
                            table.insert(items, Dropdown({
                                options = sounds,
                                defaultValue = BLU:GetDB({"selectedSounds", event.id}) or "blu:default",
                                onChange = function(value)
                                    BLU:SetDB({"selectedSounds", event.id}, value)
                                end,
                                size = {250, 30},
                                point = {"TOPLEFT", 150, yOffset}
                            }))
                            
                            -- Test button
                            table.insert(items, Button({
                                text = "Test",
                                size = {60, 24},
                                point = {"TOPLEFT", 410, yOffset},
                                onClick = function()
                                    BLU:PlayTestSound(event.id)
                                end
                            }))
                        end
                        return items
                    end)()
                })
            }
        })
    end
    
    -- Modules Tab Component
    local function ModulesTab()
        local modules = BLU:GetAvailableModules and BLU:GetAvailableModules() or {}
        
        return Frame({
            size = {740, 480},
            children = {
                Text({
                    text = "Module Management",
                    font = "GameFontNormalLarge",
                    point = {"TOPLEFT", 20, -20}
                }),
                
                Frame({
                    size = {700, 400},
                    point = {"TOPLEFT", 20, -60},
                    children = (function()
                        local items = {}
                        for i, module in ipairs(modules) do
                            local yOffset = -50 * (i - 1)
                            local enabled, setEnabled = useState(BLU:IsModuleEnabled(module.id))
                            
                            -- Module checkbox
                            table.insert(items, Checkbox({
                                label = module.name,
                                checked = enabled,
                                onChange = function(value)
                                    setEnabled(value)
                                    if value then
                                        BLU:EnableModule(module.id)
                                    else
                                        BLU:DisableModule(module.id)
                                    end
                                end,
                                point = {"TOPLEFT", 0, yOffset}
                            }))
                            
                            -- Module description
                            table.insert(items, Text({
                                text = module.desc,
                                font = "GameFontNormalSmall",
                                color = {0.7, 0.7, 0.7},
                                point = {"TOPLEFT", 30, yOffset - 20}
                            }))
                        end
                        return items
                    end)()
                })
            }
        })
    end
    
    -- Profiles Tab Component
    local function ProfilesTab()
        local profiles, setProfiles = useState({"Default", "Raiding", "Leveling", "PvP"})
        local currentProfile, setCurrentProfile = useState(BLU.db.currentProfile or "Default")
        
        return Frame({
            size = {740, 480},
            children = {
                Text({
                    text = "Profile Management",
                    font = "GameFontNormalLarge",
                    point = {"TOPLEFT", 20, -20}
                }),
                
                Text({
                    text = "Current Profile: " .. currentProfile,
                    point = {"TOPLEFT", 20, -60}
                }),
                
                Dropdown({
                    options = profiles,
                    value = currentProfile,
                    onChange = function(value)
                        setCurrentProfile(value)
                        BLU:SwitchProfile(value)
                    end,
                    size = {200, 30},
                    point = {"TOPLEFT", 20, -90}
                })
            }
        })
    end
    
    -- About Tab Component
    local function AboutTab()
        return Frame({
            size = {740, 480},
            children = {
                Text({
                    text = "About BLU",
                    font = "GameFontNormalLarge",
                    point = {"TOP", 0, -20}
                }),
                
                Text({
                    text = "Better Level-Up! v6.0.0-alpha",
                    point = {"TOP", 0, -60}
                }),
                
                Text({
                    text = "Powered by NextUI Framework",
                    font = "GameFontNormalSmall",
                    color = {0.2, 0.8, 1},
                    point = {"TOP", 0, -80}
                }),
                
                Text({
                    text = "Created by donniedice",
                    point = {"TOP", 0, -120}
                }),
                
                Text({
                    text = "Part of the RGX Mods Collection",
                    color = {1, 0.8, 0},
                    point = {"TOP", 0, -140}
                })
            }
        })
    end
    
    -- Replace BLU's ShowSettings with NextUI version
    BLU.ShowSettingsNextUI = function()
        if not BLU.settingsFrame then
            BLU.settingsFrame = BLUSettings()
        end
        
        if BLU.settingsFrame then
            NextRouter:Navigate("/blu-settings")
        end
    end
    
    -- Register with NextUI router
    if NextRouter then
        NextRouter:Register("/blu-settings", BLUSettings)
    end
    
    -- Override slash command to use NextUI
    SLASH_BLU1 = "/blu"
    SlashCmdList["BLU"] = function(msg)
        if msg == "legacy" then
            -- Use old interface
            if BLU.ShowSettings then
                BLU:ShowSettings()
            end
        else
            -- Use NextUI interface
            BLU.ShowSettingsNextUI()
        end
    end
    
    print("|cff00ff00BLU:|r NextUI integration complete! Type /blu to open settings.")
    return true
end

-- Initialize on addon loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "NextUI" then
        C_Timer.After(0.5, IntegrateNextUI)
    elseif addon == addonName then
        -- Check if NextUI is already loaded
        if _G.NextUI then
            C_Timer.After(0.5, IntegrateNextUI)
        end
    end
end)