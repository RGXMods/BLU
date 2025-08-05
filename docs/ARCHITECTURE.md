# BLU v6.0.0-alpha Architecture Documentation

## Core Architecture Overview

BLU follows a modular architecture with clear separation of concerns:

```
BLU/
├── core/           # Core framework and initialization
├── modules/        # Feature modules and systems  
├── sound/          # Sound management and packs
├── media/          # Assets (images, sounds)
└── docs/           # Documentation
```

## Loading Sequence

### 1. XML Loading Order (blu.xml)
```xml
1. core/core.xml      → Framework initialization
2. modules/modules.xml → Core systems and features
3. sound/sound.xml    → Sound system
```

### 2. Core Initialization (core/init.lua)
```lua
ADDON_LOADED → Load saved variables
             → Initialize core modules in order:
               - events
               - localization
               - config  
               - utils
               - registry
               - loader
               - options
             → Load feature modules

PLAYER_LOGIN → Create options panel
             → Show welcome message
```

### 3. Module Loading Logic

#### Core Modules (Always Loaded)
- **Framework** (`core/framework.lua`): Event system, timers, hooks
- **Database** (`core/database.lua`): SavedVariables management
- **Events** (`core/events.lua`): Event registration and handling
- **Registry** (`modules/registry.lua`): Sound registration and playback

#### Feature Modules (Loaded on Demand)
- Loaded based on `db.profile.enabled` setting
- Each module has `Init()` and `Cleanup()` functions
- Modules register for specific game events

#### Sound Modules (Loaded as Needed)
- Loaded when sounds from that game are selected
- Register sounds with the central registry
- Support dynamic loading/unloading

## Key Design Patterns

### 1. Module Pattern
```lua
local ModuleName = {}
BLU.Modules["ModuleName"] = ModuleName

function ModuleName:Init()
    -- Initialize module
end

function ModuleName:Cleanup()
    -- Cleanup module
end
```

### 2. Event-Driven Architecture
```lua
-- Register event
BLU:RegisterEvent("EVENT_NAME", handler)

-- Fire custom event
BLU:FireEvent("CUSTOM_EVENT", arg1, arg2)
```

### 3. Sound Registration Pattern
```lua
-- Register sound
BLU:RegisterSound(soundId, {
    name = "Display Name",
    file = "path/to/sound.ogg",
    duration = 2.0,
    category = "levelup"
})

-- Play sound
BLU:PlayCategorySound("levelup")
```

## Data Flow

### Settings Management
```
BLUDB (SavedVariables)
  └── profile
      ├── enabled
      ├── soundVolume  
      ├── soundChannel
      └── selectedSounds
          ├── levelup: "finalfantasy"
          ├── achievement: "zelda"
          └── quest: "default"
```

### Sound Playback Flow
```
Game Event → Feature Module → PlayCategorySound()
                                ├── Check random mode
                                ├── Get selected game
                                ├── Build sound ID
                                ├── Apply volume
                                └── PlaySoundFile()
```

### SharedMedia Integration
```
LSM Registration → SoundPak Bridge → BLU Registry
                    ├── Detect new sounds
                    ├── Create BLU entries
                    └── Make available in UI
```

## Options Panel Architecture

### Tab System
- Dynamic tab creation
- Lazy panel loading
- State management

### Widget System  
- Reusable UI components
- Consistent styling
- Event handling

### Panel Structure
```
Options Panel
├── General Tab
│   ├── Enable checkbox
│   ├── Volume slider
│   └── Sound channel dropdown
├── Sounds Tab
│   ├── Category dropdowns
│   ├── Preview buttons
│   └── Browse button
├── Modules Tab
│   └── Feature toggles
└── About Tab
    └── Info and links
```

## Performance Optimizations

### 1. Lazy Loading
- Feature modules only loaded when enabled
- Sound files loaded on first use
- UI panels created on demand

### 2. Event Optimization
- Minimal event registrations
- Efficient event handlers
- Cleanup on module unload

### 3. Memory Management
- Reuse UI elements
- Clear references on cleanup
- Minimal global namespace pollution

## Error Handling

### Graceful Degradation
- Missing sounds fallback to default
- LibStub optional dependency
- Module loading failures logged

### Debug Support
```lua
BLU:PrintDebug("message")  -- Development logging
/blutest                   -- Loading diagnostics
```

## Future Architecture Considerations

### 1. Plugin System
- Allow third-party sound packs
- Custom event handlers
- UI extensions

### 2. Profile System
- Multiple profiles per character
- Import/export settings
- Sync across characters

### 3. Advanced Features
- Sound mixing/layering
- Dynamic volume adjustment
- Conditional sound playing