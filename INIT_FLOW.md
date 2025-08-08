# BLU Initialization Flow

## 🚀 Startup Sequence Diagram

```mermaid
graph TD
    A[WoW Client Starts] --> B[Parse BLU.toc]
    B --> C[Load BLU.xml]
    
    C --> D[Phase 1: Core Bootstrap]
    D --> D1[core/core.lua - Create BLU namespace]
    D1 --> D2[core/database.lua - Setup SavedVars]
    D2 --> D3[core/config.lua - Load defaults]
    D3 --> D4[core/utils.lua - Helper functions]
    D4 --> D5[core/registry.lua - Sound system]
    D5 --> D6[core/loader.lua - Module loader]
    D6 --> D7[core/commands.lua - Slash commands]
    D7 --> D8[core/optionslauncher.lua - UI launcher]
    D8 --> D9[core/init.lua - Event registration]
    
    D9 --> E[Phase 2: Component Loading]
    E --> E1[localization/enUS.lua]
    E1 --> E2[interface/design.lua]
    E2 --> E3[interface/widgets.lua]
    E3 --> E4[interface/tabs.lua]
    E4 --> E5[interface/settings.lua]
    E5 --> E6[interface/panels/*.lua]
    
    E6 --> F[Phase 3: Module Registration]
    F --> F1[modules/*/\*.lua registered]
    F1 --> F2[Modules remain dormant]
    
    F2 --> G[ADDON_LOADED Event]
    G --> G1{Is this BLU?}
    G1 -->|Yes| G2[Load SavedVariables]
    G2 --> G3[Apply user config]
    G3 --> G4[Activate enabled modules]
    G4 --> G5[Register game events]
    
    G5 --> H[PLAYER_LOGIN Event]
    H --> H1[Register options panel]
    H1 --> H2[Enable slash commands]
    H2 --> H3[Fire BLU_INITIALIZED]
    
    H3 --> I[Addon Ready]
    I --> J[Runtime Events]
    
    J --> K{Event Type}
    K -->|Level Up| L1[levelup module handles]
    K -->|Quest Complete| L2[quest module handles]
    K -->|Achievement| L3[achievement module handles]
    K -->|Other| L4[appropriate module handles]
    
    L1 --> M[Play Sound]
    L2 --> M
    L3 --> M
    L4 --> M
    
    M --> N[Update UI if needed]
    N --> J
```

## 📋 Initialization Checklist

### ✅ Core Systems (Always Loaded)
- [x] **BLU Namespace**: Global addon table created
- [x] **Event System**: Custom event dispatcher ready
- [x] **Database**: SavedVariables handler initialized
- [x] **Config**: Default settings loaded
- [x] **Registry**: Sound mappings available
- [x] **Loader**: Module discovery complete
- [x] **Commands**: Slash handlers registered

### 🔌 Conditional Loading
- [ ] **Modules**: Only if enabled in config
- [ ] **Sound Packs**: On first sound play
- [ ] **UI Panels**: On first `/blu` command
- [ ] **Localization**: Additional languages on demand

## 🎮 Event Flow Examples

### Example 1: Player Levels Up
```
1. PLAYER_LEVEL_UP event fires
2. levelup module receives event
3. Module checks if enabled
4. Queries registry for user's selected sound
5. Calls PlaySoundFile() with volume setting
6. Optional: Shows visual notification
7. Logs to debug if enabled
```

### Example 2: User Opens Settings
```
1. Player types /blu
2. Command handler triggered
3. Checks if panels created
4. If not, builds UI dynamically
5. Shows main window with tabs
6. Loads current config into UI
7. Ready for user interaction
```

### Example 3: Module Hot-Reload
```
1. User toggles module in settings
2. If disabling:
   - Call module:Cleanup()
   - Unregister events
   - Clear module state
3. If enabling:
   - Call module:Init()
   - Register events
   - Load module config
4. Save to SavedVariables
```

## 🔍 Debug Trace Points

Key locations for debugging initialization:

```lua
-- core/init.lua
BLU:Debug("ADDON_LOADED", addonName)

-- core/loader.lua
BLU:Debug("Loading module:", moduleName)

-- modules/[name]/[name].lua
BLU:Debug(moduleName, "initialized")

-- interface/settings.lua
BLU:Debug("Settings panel created")
```

## ⚡ Performance Timing

Typical load times on modern hardware:

| Phase | Time | Description |
|-------|------|-------------|
| Core Bootstrap | ~10ms | Framework setup |
| Component Load | ~20ms | UI and localization |
| Module Registration | ~5ms | Discovery only |
| ADDON_LOADED | ~15ms | Config and activation |
| PLAYER_LOGIN | ~10ms | Final initialization |
| **Total** | **~60ms** | Full startup |

## 🛠️ Troubleshooting Init Issues

### Addon doesn't load
1. Check BLU.toc Interface version
2. Verify file paths are lowercase
3. Check for Lua errors in BugSack

### Modules not activating
1. Check SavedVariables for corruption
2. Verify module files exist
3. Enable debug mode: `/blu debug`

### Sounds not playing
1. Check sound files exist in media/sounds/
2. Verify registry mappings
3. Test with: `/blu test levelup`

### UI not showing
1. Check if panels are created
2. Verify interface files loaded
3. Try: `/reload` to reset

## 🔄 Reload Sequence

When user does `/reload`:

1. **Cleanup Phase**
   - All modules call :Cleanup()
   - Events unregistered
   - Hooks removed

2. **Save Phase**
   - Current config written to SavedVariables
   - Profile data persisted

3. **Restart Phase**
   - Full initialization sequence runs
   - Previous state restored from SavedVars

---

*This initialization flow ensures minimal load time while maintaining flexibility for dynamic module loading and configuration changes.*