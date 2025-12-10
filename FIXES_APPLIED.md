# BLU Addon - Critical Fixes Applied

## Date: 2024
## Issue: Options panel not loading and non-functional options

---

## Problems Identified

### 1. **Missing Config:Init() Function**
- **File**: `core/config.lua`
- **Issue**: The config module had no `Init()` function, causing initialization.lua to fail when trying to initialize it
- **Impact**: Prevented proper module initialization chain

### 2. **Incorrect Initialization Order**
- **File**: `core/initialization.lua`
- **Issue**: Database was being initialized before Config, but `Database:ApplyDefaults()` requires `Config.defaults` to exist
- **Impact**: Database couldn't apply default settings, leading to nil reference errors

### 3. **Forward Reference Problem in Tabs**
- **File**: `core/interface/options/tabs.lua`
- **Issue**: `BLU.OptionsTabs` was defined at module load time, referencing panel creation functions (`BLU.CreateGeneralPanel`, etc.) that didn't exist yet
- **Impact**: Tab configuration had nil function references, preventing tabs from being created

### 4. **Internal Sounds Loading Before Registry**
- **File**: `core/initialization.lua`
- **Issue**: `internal_sounds` module was loaded before `registry` module was initialized
- **Impact**: Sound registration failed because the registry wasn't ready

### 5. **Incorrect Module Paths in XML**
- **File**: `blu.xml`
- **Issue**: Module paths used lowercase (e.g., `modules/quest/quest.lua`) but actual directories are capitalized (e.g., `modules/Quest/Quest.lua`)
- **Impact**: Modules failed to load, causing missing functionality

### 6. **Widgets Module Not Properly Registered**
- **File**: `core/interface/widgets.lua`
- **Issue**: Widgets module wasn't registered in `BLU.Modules` table
- **Impact**: Widgets module couldn't be initialized properly

---

## Fixes Applied

### Fix 1: Added Config:Init() Function
**File**: `core/config.lua`

```lua
-- Initialize config module
function Config:Init()
    BLU:PrintDebug("[Config] Config module initialized")
    BLU:PrintDebug("[Config] Defaults available: " .. tostring(self.defaults ~= nil))
end
```

### Fix 2: Corrected Initialization Order
**File**: `core/initialization.lua`

**Before**:
```lua
-- Phase 1: Core Systems (must be first)
self:InitializePhase("core", {
    "database",        -- Database must be first
    "config",         -- Configuration system
    ...
})
```

**After**:
```lua
-- Phase 1: Core Systems (must be first)
self:InitializePhase("core", {
    "config",         -- Configuration system (MUST be first for defaults)
    "database",        -- Database (needs config.defaults)
    ...
})
```

### Fix 3: Moved BLU.OptionsTabs to Init Function
**File**: `core/interface/options/tabs.lua`

**Before**: `BLU.OptionsTabs` was defined at module level (when file loads)

**After**: Moved to `Tabs:Init()` function so it's evaluated after all panel creation functions are loaded

```lua
function Tabs:Init()
    BLU:PrintDebug("[Tabs] Initializing tab system (alpha.3 style)")
    
    -- Tab configuration - defined here so panel creation functions are available
    BLU.OptionsTabs = {
        -- Row 1
        {text = "General", create = BLU.CreateGeneralPanel, row = 1, col = 1},
        {text = "Sounds", create = BLU.CreateSoundsPanel, row = 1, col = 2},
        ...
    }
    
    BLU:PrintDebug("[Tabs] Registered " .. #BLU.OptionsTabs .. " tabs")
end
```

### Fix 4: Added Internal Sounds to Phase 2
**File**: `core/initialization.lua`

```lua
-- Phase 2: Registry and Loader
self:InitializePhase("registry", {
    "registry",
    "internal_sounds",  -- Must come after registry
    "loader",
    "sharedmedia"
})
```

### Fix 5: Fixed Module Paths in XML
**File**: `blu.xml`

**Before**:
```xml
<Script file="modules/quest/quest.lua"/>
<Script file="modules/levelup/levelup.lua"/>
```

**After**:
```xml
<Script file="modules/Quest/Quest.lua"/>
<Script file="modules/LevelUp/LevelUp.lua"/>
```

Also fixed Localization path:
```xml
<Script file="Localization/enUS.lua"/>
```

### Fix 6: Properly Registered Widgets Module
**File**: `core/interface/widgets.lua`

**Before**:
```lua
BLU.Widgets = {}

function BLU.Widgets:Init()
    ...
end
```

**After**:
```lua
local Widgets = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["widgets"] = Widgets
BLU.Widgets = Widgets

function Widgets:Init()
    ...
end
```

And added to initialization:
```lua
-- Phase 3: Interface System (design MUST come first!)
self:InitializePhase("interface", {
    "design",      -- Design system MUST be first
    "widgets",     -- Widget helpers
    "tabs",        -- Tab system
    ...
})
```

---

## Expected Results

After these fixes:

1. ✅ Config module initializes first with defaults available
2. ✅ Database can properly apply default settings
3. ✅ All panel creation functions are available when tabs are created
4. ✅ Sound registry is ready before internal sounds try to register
5. ✅ All modules load correctly from proper file paths
6. ✅ Widgets module is properly initialized
7. ✅ Options panel opens without errors
8. ✅ All tabs display correctly
9. ✅ Sound dropdowns populate with available sounds
10. ✅ Module toggles work properly

---

## Testing Checklist

- [ ] `/reload` completes without Lua errors
- [ ] `/blu` opens the options panel
- [ ] All tabs are visible and clickable
- [ ] General tab displays content
- [ ] Sounds tab shows installed sound packs
- [ ] Event tabs (Level Up, Achievement, etc.) display properly
- [ ] Sound dropdowns populate with sounds
- [ ] Module toggles enable/disable correctly
- [ ] About tab displays addon information
- [ ] No errors in `/console scriptErrors 1`

---

## Files Modified

1. `core/config.lua` - Added Init() function
2. `core/initialization.lua` - Fixed initialization order and added modules
3. `core/interface/options/tabs.lua` - Moved BLU.OptionsTabs to Init()
4. `blu.xml` - Fixed module and localization paths
5. `core/interface/widgets.lua` - Proper module registration

---

## Architecture Notes

### Initialization Order (Critical!)

```
Phase 1: Core Systems
  1. config         ← MUST be first (provides defaults)
  2. database       ← Needs config.defaults
  3. utils
  4. combat_protection
  5. sounds

Phase 2: Registry & Loader
  1. registry       ← MUST be before internal_sounds
  2. internal_sounds ← Registers sounds with registry
  3. loader
  4. sharedmedia

Phase 3: Interface
  1. design         ← MUST be first (provides colors, backdrops)
  2. widgets        ← Widget helpers
  3. tabs           ← Creates BLU.OptionsTabs in Init()
  4. general        ← Defines BLU.CreateGeneralPanel
  5. sound_panel    ← Defines BLU.CreateEventSoundPanel
  6. sounds         ← Defines BLU.CreateSoundsPanel
  7. about          ← Defines BLU.CreateAboutPanel
  8. modules        ← Defines BLU.CreateModulesPanel
  9. options        ← MUST be last (creates panel using all above)

Phase 4: Feature Modules
  - levelup, achievement, quest, reputation, etc.

Phase 5: Final Setup
  - Load saved settings
  - Show welcome message
```

### Key Dependencies

- **Database** depends on **Config** (for defaults)
- **Internal Sounds** depends on **Registry** (for registration)
- **Tabs** depends on **Panel Creation Functions** (general, sounds, about, etc.)
- **Options Panel** depends on **Everything** (must be last in Phase 3)

---

## Maintenance Notes

When adding new modules or panels:

1. Add the module file to `blu.xml` in the correct section
2. Ensure the module has an `Init()` function
3. Register the module in `BLU.Modules[moduleName]`
4. Add to appropriate initialization phase in `initialization.lua`
5. If it's a panel, add to `BLU.OptionsTabs` in `tabs.lua:Init()`
6. Respect the initialization order dependencies

---

## Version
- **BLU Version**: v6.0.0-alpha
- **Fix Date**: November 2024
- **Status**: Ready for testing
