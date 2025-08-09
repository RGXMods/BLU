--=====================================================================================
-- BLU Settings Component (TypeScript-style)
-- Written in TSX-like syntax for NextUI
--=====================================================================================

local addonName, BLU = ...

-- TypeScript-style interface definitions
interface("SettingsProps", {
    initialVolume = "number",
    onClose = "Function",
    theme = "string"
})

interface("SoundOption", {
    value = "string",
    label = "string",
    category = "string",
    source = "string"
})

interface("ModuleConfig", {
    id = "string",
    name = "string",
    enabled = "boolean",
    sound = "string",
    volume = "number"
})

-- Type definitions
type("Theme", "dark | light | auto")
type("SoundEvent", "levelup | achievement | quest | reputation | honor")

-- Enum for sound sources
local SoundSource = enum("SoundSource", {
    BLU = "BLU",
    SHARED_MEDIA = "SharedMedia",
    CUSTOM = "Custom"
})

-- Main Settings Component (TypeScript/React style)
local Settings = NextUI.createTypedComponent("Settings", {
    initialVolume = "number",
    onClose = "Function"
}, function(props)
    -- Typed state hooks
    local volume, setVolume = NextUI.useTypedState(props.initialVolume or 100, "number")
    local activeTab, setActiveTab = NextUI.useTypedState(1, "number")
    local theme, setTheme = NextUI.useTypedState("dark", "string")
    local modules, setModules = NextUI.useTypedState({}, "Array")
    
    -- Memoized calculations
    local soundList = useMemo(function()
        return GetAllSounds and GetAllSounds() or {}
    end, {})
    
    -- Effect hooks
    useEffect(function()
        -- Save settings when they change
        BLU.db.profile.volume = volume
        BLU.db.profile.theme = theme
        
        -- Cleanup
        return function()
            BLU:SaveSettings()
        end
    end, {volume, theme})
    
    -- Callback functions
    local handleVolumeChange = useCallback(function(newVolume)
        setVolume(newVolume)
        BLU:SetMasterVolume(newVolume)
    end, {})
    
    local handleModuleToggle = useCallback(function(moduleId, enabled)
        if enabled then
            BLU:EnableModule(moduleId)
        else
            BLU:DisableModule(moduleId)
        end
    end, {})
    
    -- Component JSX-style return
    return jsx("Frame", {
        name = "BLUSettingsTSX",
        size = {850, 650},
        point = {"CENTER"},
        backdrop = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            edgeSize = 32
        }
    },
        -- Header
        jsx("Frame", {size = {850, 60}, point = {"TOP"}},
            jsx("Text", {
                text = "BLU Settings",
                font = "GameFontNormalLarge",
                point = {"CENTER"}
            }),
            jsx("Button", {
                text = "×",
                size = {30, 30},
                point = {"TOPRIGHT", -10, -10},
                onClick = props.onClose or function() end
            })
        ),
        
        -- Tab Navigation
        jsx("Frame", {size = {850, 40}, point = {"TOP", 0, -60}},
            jsx("TabBar", {
                tabs = {
                    {id = 1, label = "General", icon = "Interface\\Icons\\INV_Misc_Gear_01"},
                    {id = 2, label = "Sounds", icon = "Interface\\Icons\\INV_Misc_Bell_01"},
                    {id = 3, label = "Modules", icon = "Interface\\Icons\\INV_Misc_Wrench_01"},
                    {id = 4, label = "Profiles", icon = "Interface\\Icons\\INV_Misc_Book_09"},
                    {id = 5, label = "Advanced", icon = "Interface\\Icons\\INV_Misc_EngGizmos_06"}
                },
                activeTab = activeTab,
                onTabChange = setActiveTab
            })
        ),
        
        -- Content Area
        jsx("ScrollFrame", {
            size = {830, 500},
            point = {"TOP", 0, -100}
        },
            activeTab == 1 and GeneralPanel({volume = volume, onVolumeChange = handleVolumeChange}) or nil,
            activeTab == 2 and SoundsPanel({sounds = soundList}) or nil,
            activeTab == 3 and ModulesPanel({modules = modules, onToggle = handleModuleToggle}) or nil,
            activeTab == 4 and ProfilesPanel() or nil,
            activeTab == 5 and AdvancedPanel({theme = theme, onThemeChange = setTheme}) or nil
        )
    )
end)

-- General Panel Component
local GeneralPanel = NextUI.createTypedComponent("GeneralPanel", {
    volume = "number",
    onVolumeChange = "Function"
}, function(props)
    local autoPreview, setAutoPreview = NextUI.useTypedState(false, "boolean")
    local debugMode, setDebugMode = NextUI.useTypedState(false, "boolean")
    
    return jsx("Fragment", {},
        jsx("Text", {
            text = "General Settings",
            font = "GameFontNormalLarge",
            point = {"TOPLEFT", 20, -20}
        }),
        
        jsx("VolumeControl", {
            label = "Master Volume",
            value = props.volume,
            onChange = props.onVolumeChange,
            min = 0,
            max = 100,
            step = 1,
            point = {"TOPLEFT", 20, -60}
        }),
        
        jsx("Checkbox", {
            label = "Auto-preview sounds on selection",
            checked = autoPreview,
            onChange = setAutoPreview,
            point = {"TOPLEFT", 20, -120}
        }),
        
        jsx("Checkbox", {
            label = "Debug Mode",
            checked = debugMode,
            onChange = function(value)
                setDebugMode(value)
                BLU.db.profile.debugMode = value
            end,
            point = {"TOPLEFT", 20, -150}
        })
    )
end)

-- Sounds Panel Component with TypeScript-style async
local SoundsPanel = NextUI.createTypedComponent("SoundsPanel", {
    sounds = "Array"
}, NextUI.async(function(props)
    local searchTerm, setSearchTerm = NextUI.useTypedState("", "string")
    local selectedCategory, setSelectedCategory = NextUI.useTypedState("all", "string")
    local isLoading, setIsLoading = NextUI.useTypedState(false, "boolean")
    
    -- Async sound loading simulation
    local loadExternalSounds = NextUI.async(function()
        setIsLoading(true)
        
        -- Simulate async operation
        C_Timer.After(0.5, function()
            if BLU.Modules.sharedmedia then
                BLU.Modules.sharedmedia:ScanExternalSounds()
            end
            setIsLoading(false)
        end)
    end)
    
    -- Filter sounds based on search and category
    local filteredSounds = useMemo(function()
        return props.sounds:filter(function(sound)
            local matchesSearch = searchTerm == "" or 
                sound.label:lower():find(searchTerm:lower())
            local matchesCategory = selectedCategory == "all" or 
                sound.category == selectedCategory
            return matchesSearch and matchesCategory
        end)
    end, {searchTerm, selectedCategory, props.sounds})
    
    return jsx("Fragment", {},
        jsx("Text", {
            text = "Sound Configuration",
            font = "GameFontNormalLarge",
            point = {"TOPLEFT", 20, -20}
        }),
        
        jsx("SearchBar", {
            placeholder = "Search sounds...",
            value = searchTerm,
            onChange = setSearchTerm,
            point = {"TOPLEFT", 20, -60}
        }),
        
        jsx("Button", {
            text = isLoading and "Loading..." or "Refresh External Sounds",
            onClick = loadExternalSounds,
            disabled = isLoading,
            point = {"TOPRIGHT", -20, -60}
        }),
        
        jsx("SoundGrid", {
            sounds = filteredSounds,
            columns = 3,
            point = {"TOPLEFT", 20, -100}
        })
    )
end))

-- Module Panel with TypeScript generics
local ModulesPanel = NextUI.createTypedComponent("ModulesPanel", {
    modules = "Array",
    onToggle = "Function"
}, function(props)
    -- Generic state for module configurations
    local configs = NextUI.createGeneric("ModuleConfig")
    local moduleConfigs, setModuleConfigs = NextUI.useTypedState({}, configs("Array"))
    
    return jsx("Fragment", {},
        jsx("Text", {
            text = "Module Management",
            font = "GameFontNormalLarge",
            point = {"TOPLEFT", 20, -20}
        }),
        
        jsx("ModuleList", {
            modules = props.modules,
            configs = moduleConfigs,
            onToggle = props.onToggle,
            onConfigChange = function(moduleId, config)
                local newConfigs = {...moduleConfigs}
                newConfigs[moduleId] = config
                setModuleConfigs(newConfigs)
            end
        })
    )
end)

-- Export the main component
NextUI.exportDefault(Settings)

-- Register with BLU
BLU.SettingsTSX = Settings

-- TypeScript-style namespace
local BLUComponents = {
    Settings = Settings,
    GeneralPanel = GeneralPanel,
    SoundsPanel = SoundsPanel,
    ModulesPanel = ModulesPanel
}

NextUI.export("BLUComponents", BLUComponents)