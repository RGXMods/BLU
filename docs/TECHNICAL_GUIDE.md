# BLU Technical Guide

## Architecture Overview

BLU v6.0.0-alpha is a complete rewrite with no external dependencies, featuring a modular architecture designed for performance and maintainability.

## Sound System Architecture

### Three-Tier Sound System

1. **Default WoW Sounds**
   - Uses WoW's built-in soundKit IDs
   - No volume control (uses system volume)
   - Plays on selected channel
   - Example: `PlaySound(888, "Master")`

2. **BLU Internal Sounds**
   - Custom sounds with 3 pre-rendered volume variants
   - Files: `soundname_low.ogg`, `soundname_med.ogg`, `soundname_high.ogg`
   - Volume slider selects appropriate variant
   - Full modulation control

3. **External Sounds (SharedMedia/SoundPak)**
   - Integration with other sound addons
   - No volume control (plays at full volume)
   - Respects channel selection
   - Dynamic detection and registration

### Sound Flow Diagram
```
User Action (Level Up)
    ↓
Event Module Detects
    ↓
PlayCategorySound("levelup")
    ↓
Check Selected Sound Type:
    ├─ "default" → PlaySound(soundKit, channel)
    ├─ "blu_*" → PlaySound(file_variant, channel)
    └─ "external:*" → PlaySoundFile(external_path, channel)
```

## Module System

### Core Modules (Always Loaded)
```lua
framework.lua    -- Event system, timers, hooks
database.lua     -- SavedVariables management
events.lua       -- Event registration
registry.lua     -- Sound management
loader.lua       -- Dynamic module loading
```

### Feature Modules (On-Demand)
```lua
levelup.lua      -- PLAYER_LEVEL_UP handler
achievement.lua  -- ACHIEVEMENT_EARNED handler
quest.lua        -- QUEST_COMPLETE handler
-- etc...
```

### Loading Sequence
1. **XML Bootstrap** (`blu.xml`)
2. **Core Init** (`core/init.lua`)
3. **Module Registration**
4. **Event Binding**
5. **UI Creation**

## Options Panel System

### Tab Structure
```
Row 1: General | Level Up | Achievement | Quest | Reputation | Battle Pets
Row 2: Honor | Renown | Trading Post | Delve | Modules | Sounds  
Row 3: About | RGXMods
```

### Component Hierarchy
```
BLUOptionsPanel
├── Header (logo, title, version)
├── TabContainer
│   └── Tab Buttons (14 total)
└── Content Frames
    ├── General Settings
    ├── Event Sound Panels (9)
    ├── Module Management
    ├── Sound Browser
    ├── About Info
    └── RGXMods Community
```

## SavedVariables Structure

```lua
BLUDB = {
    profile = {
        -- Core Settings
        enabled = true,
        showWelcomeMessage = true,
        debugMode = false,
        showSoundNames = false,
        
        -- Audio Settings
        soundVolume = 100,      -- 0-100
        soundChannel = "Master",
        
        -- Behavior
        muteInInstances = false,
        muteInCombat = false,
        randomSounds = false,
        
        -- Sound Selections
        selectedSounds = {
            levelup = "finalfantasy",
            achievement = "zelda",
            quest = "default",
            -- etc...
        },
        
        -- Volume Overrides
        volumeOverrides = {
            levelup = 75,
            -- etc...
        },
        
        -- Module States
        modules = {
            levelup = true,
            achievement = true,
            -- etc...
        }
    }
}
```

## API Reference

### Global Functions
```lua
-- Sound Playback
BLU:PlaySound(soundId, volume)
BLU:PlayCategorySound(category, forceSound)
BLU:PlayExternalSound(soundName)

-- Sound Management
BLU:RegisterSound(soundId, soundData)
BLU:UnregisterSound(soundId)
BLU:GetSound(soundId)

-- Module Management
BLU:LoadModule(type, name)
BLU:UnloadModule(name)
BLU:IsModuleLoaded(name)

-- Settings
BLU:LoadSettings()
BLU:SaveSettings()
BLU:ResetSettings()

-- UI
BLU:OpenOptions()
BLU:CreateOptionsPanel()
```

### Event System
```lua
-- Register for events
BLU:RegisterEvent("EVENT_NAME", callback)
BLU:UnregisterEvent("EVENT_NAME", callback)

-- Fire custom events
BLU:FireEvent("CUSTOM_EVENT", ...)

-- Hook functions
BLU:Hook("FunctionName", callback)
BLU:SecureHook(object, "method", callback)
```

## Performance Optimization

### Memory Management
- Modules loaded on-demand
- Sound files loaded only when selected
- Unused modules can be disabled
- Efficient event registration

### Best Practices
1. Use `BLU:PrintDebug()` for development logging
2. Always check if modules exist before calling
3. Use batch operations for multiple sounds
4. Implement proper cleanup in modules

## Debugging

### Enable Debug Mode
```lua
/blu debug
-- or
BLU.db.profile.debugMode = true
```

### Debug Output
```
[BLU Debug] Module loaded: levelup
[BLU Debug] Playing sound: finalfantasy_levelup (volume: 1.00, channel: Master)
[BLU Debug] Event fired: PLAYER_LEVEL_UP
```

### Common Issues
1. **Sound not playing**: Check channel settings and volume
2. **Module not loading**: Verify it's enabled in settings
3. **UI not appearing**: Try `/reload` and check for errors
4. **External sounds**: Ensure SharedMedia addon is loaded

## Development Guidelines

### Adding a New Sound Pack
1. Create `sound/packs/gamename.lua`
2. Define sound structure
3. Add .ogg files with 3 variants
4. Register in `internal_sounds.lua`

### Adding a New Event
1. Create `modules/features/eventname.lua`
2. Implement Init() and Cleanup()
3. Register for WoW events
4. Call PlayCategorySound()
5. Add to module loader

### Code Standards
- Use lowercase filenames
- Follow existing patterns
- Add debug logging
- Handle errors gracefully
- Document complex logic

## Testing Checklist

- [ ] All sound variants play correctly
- [ ] Volume control works for BLU sounds
- [ ] External sounds detected and play
- [ ] Module enable/disable works
- [ ] Settings persist across reload
- [ ] No Lua errors in log
- [ ] Memory usage acceptable
- [ ] Performance impact minimal