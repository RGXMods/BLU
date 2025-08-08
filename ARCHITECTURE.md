# BLU Addon Architecture Documentation

## 🎮 Overview

BLU (Better Level-Up!) is a **modular sound replacement addon** for World of Warcraft that enhances gameplay events with custom audio from 50+ classic games. This document explains the internal architecture, data flow, and design decisions.

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         BLU.toc                              │
│                    (WoW Entry Point)                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                         BLU.xml                              │
│                    (Load Order Control)                      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │    Core Framework    │
        ├─────────────────────┤
        │ • core/core.lua      │ ← Main addon object & API
        │ • core/database.lua  │ ← SavedVariables handler
        │ • core/config.lua    │ ← Default settings
        │ • core/registry.lua  │ ← Sound registry system
        │ • core/loader.lua    │ ← Dynamic module loader
        │ • core/init.lua      │ ← Initialization sequence
        └──────────┬──────────┘
                   │
        ┌──────────┴──────────┬─────────────┬────────────┐
        ▼                     ▼             ▼            ▼
┌──────────────┐   ┌──────────────┐  ┌──────────┐  ┌──────────┐
│   Modules    │   │  Interface   │  │  Media   │  │  Sound   │
├──────────────┤   ├──────────────┤  ├──────────┤  ├──────────┤
│ • levelup    │   │ • settings   │  │ • sounds │  │ • packs  │
│ • quest      │   │ • panels     │  │ • icons  │  │   config │
│ • achievement│   │ • widgets    │  └──────────┘  └──────────┘
│ • reputation │   │ • tabs       │
│ • battlepet  │   └──────────────┘
│ • honor      │
│ • renown     │
│ • tradingpost│
│ • delve      │
└──────────────┘
```

## 🔄 Initialization Flow

### Phase 1: Core Bootstrap
```lua
1. WoW loads BLU.toc
2. BLU.xml parsed → files loaded in order:
   a. core/core.lua      → Creates BLU namespace & framework
   b. core/database.lua  → Initializes SavedVariables
   c. core/config.lua    → Sets defaults
   d. core/utils.lua     → Utility functions available
   e. core/registry.lua  → Sound registry initialized
   f. core/loader.lua    → Module loader ready
   g. core/init.lua      → ADDON_LOADED event registered
```

### Phase 2: Module Registration
```lua
3. Localization loaded (localization/enUS.lua)
4. Interface framework loaded:
   - interface/design.lua    → UI theme system
   - interface/widgets.lua   → Reusable components
   - interface/tabs.lua      → Tab navigation
   - interface/settings.lua  → Main settings UI
5. Feature modules registered (but NOT loaded):
   - Each module registers with loader
   - Modules remain dormant until enabled
```

### Phase 3: Runtime Activation
```lua
6. ADDON_LOADED event fires:
   - Database loaded from SavedVariables
   - Enabled modules activated
   - Event handlers registered
   - Sound packs loaded on-demand
7. PLAYER_LOGIN event:
   - Options panel registered
   - Slash commands activated (/blu)
   - Module initialization complete
```

## 🧩 Module Architecture

### Module Structure
Each module follows this pattern:
```lua
-- modules/[feature]/[feature].lua
local addonName, BLU = ...
local module = BLU:NewModule("ModuleName")

function module:Init()
    -- Register events
    -- Initialize state
    -- Hook into game systems
end

function module:Cleanup()
    -- Unregister events
    -- Clean up hooks
    -- Release memory
end

function module:OnEvent(event, ...)
    -- Handle specific game events
    -- Trigger sounds via registry
    -- Update UI if needed
end
```

### Module Communication
Modules communicate through:
1. **Event System**: `BLU:RegisterEvent()`, `BLU:TriggerEvent()`
2. **Sound Registry**: `BLU:PlaySound(category, soundId)`
3. **Config System**: `BLU:GetConfig()`, `BLU:SetConfig()`
4. **Shared State**: Via `BLU.db` (SavedVariables)

## 🎵 Sound System Architecture

### Sound Registry Pattern
```lua
BLU.Registry = {
    sounds = {
        ["levelup"] = {
            ["default"] = "Interface\\AddOns\\BLU\\media\\sounds\\level_default.ogg",
            ["finalfantasy"] = "Interface\\AddOns\\BLU\\media\\sounds\\final_fantasy.ogg",
            ["zelda"] = "Interface\\AddOns\\BLU\\media\\sounds\\legend_of_zelda.ogg"
        },
        ["achievement"] = { ... },
        ["quest"] = { ... }
    }
}
```

### Sound Playback Flow
```
Game Event → Module Handler → Registry Lookup → PlaySoundFile() → User Hears Sound
     ↓             ↓                ↓                  ↓
PLAYER_LEVEL_UP  levelup.lua   Check user pref   WoW Sound API
```

### Volume Control System
- No longer uses separate high/med/low files
- Volume controlled via WoW's sound channel system
- User preference: 0-100% volume slider
- Channel selection: Master/SFX/Music/Ambience

## 🖼️ UI Architecture

### Panel System
```lua
BLU.Panels = {
    General = {},     -- Main settings
    Sounds = {},      -- Sound pack selection
    About = {},       -- Credits/info
    EventSimple = {}  -- Per-event dropdowns
}
```

### Widget Reusability
Common widgets defined in `interface/widgets.lua`:
- Dropdown menus
- Volume sliders
- Checkboxes with custom styling
- Preview buttons for sounds

### Narcissus Design System
Implements clean, minimal UI inspired by Narcissus addon:
- Three-tier text coloring (highlight/normal/disabled)
- Compact form factors
- Smooth animations
- Consistent spacing

## 💾 Data Persistence

### SavedVariables Structure
```lua
BLUDB = {
    profile = {
        default = {
            enabled = true,
            volume = 100,
            channel = "Master",
            modules = {
                levelup = { enabled = true, sound = "finalfantasy" },
                achievement = { enabled = true, sound = "zelda" },
                quest = { enabled = true, sound = "pokemon" }
            }
        }
    }
}
```

### Profile System (Future)
- Multiple profiles per character
- Import/export functionality
- Preset configurations

## 🔌 Extension Points

### Adding New Modules
1. Create `modules/newfeature/newfeature.lua`
2. Implement `Init()` and `Cleanup()` methods
3. Register in `BLU.xml`
4. Module auto-discovered by loader

### Adding Sound Packs
1. Create `sound/packs/gamename.lua`
2. Define sound mappings
3. Add to `sound/packs/packs.xml`
4. Sounds available in dropdown

### Custom Events
Modules can define custom events:
```lua
BLU:RegisterCustomEvent("BLU_SPECIAL_EVENT")
BLU:TriggerCustomEvent("BLU_SPECIAL_EVENT", data)
```

## 🚀 Performance Considerations

### Lazy Loading
- Modules only loaded when enabled
- Sound files loaded on first play
- UI panels created on first access

### Memory Management
- Unused modules can be unloaded
- Sound cache cleared periodically
- Event handlers cleaned up properly

### CPU Optimization
- Event filtering at framework level
- Batched UI updates
- Throttled sound playback

## 🔧 Developer Tools

### Debug Mode
```lua
/blu debug        -- Enable debug output
/blu modules      -- List loaded modules
/blu sounds       -- Test sound playback
/blu reload       -- Reload configuration
```

### Testing Helpers
- Mock event generation
- Sound preview system
- Module hot-reloading

## 📦 Build & Release

### Version Management
- Semantic versioning (v6.0.0-alpha)
- Git tags for releases
- Automated changelog generation

### Distribution
- CurseForge via .pkgmeta
- GitHub releases
- Wago.io integration

## 🎯 Design Goals

1. **Zero Dependencies**: No external libraries required
2. **Modular**: Features can be enabled/disabled independently
3. **Performant**: Minimal CPU/memory footprint
4. **Extensible**: Easy to add new sounds and features
5. **User-Friendly**: Clean UI with sensible defaults

## 🔮 Future Enhancements

- [ ] WeakAuras integration
- [ ] Custom trigger conditions
- [ ] Sound effect chains
- [ ] Visual effects system
- [ ] Multi-profile support
- [ ] Cloud sync via SavedVariables export

---

*This architecture is designed for maintainability, performance, and user experience. Each component has a single responsibility and communicates through well-defined interfaces.*