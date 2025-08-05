# BLU Development Roadmap

## Current Version: v6.0.0-alpha

## Addon Scope

### What BLU Is:
- **Sound Replacement Addon**: Replaces default WoW sounds with iconic game sounds
- **Event-Based**: Triggers on specific WoW events (level up, achievements, etc.)
- **Volume Control**: For BLU internal sounds only (3 pre-rendered variants)
- **Channel Selection**: Routes sounds through WoW's audio channels
- **Modular System**: Load only the features you use
- **SharedMedia Compatible**: Can use external sound packs

### What BLU Is NOT:
- **NOT a sound editor**: Cannot modify or create sounds in-game
- **NOT a music player**: No playlists or background music
- **NOT a voice addon**: No voice chat or communication features
- **NOT an alert system**: No custom triggers or WeakAura-style alerts
- **NOT a sound mixer**: Cannot adjust WoW's system volumes
- **NOT profile-based**: Single configuration only

### Core Functionality:
1. **Replace these WoW sounds**:
   - Level up notifications
   - Achievement earned
   - Quest complete
   - Reputation gains
   - Honor/Renown ranks
   - Battle pet victories
   - Trading Post activities
   - Delve companion events

2. **With sounds from**:
   - BLU built-in sounds (Final Fantasy, WoW defaults)
   - External SharedMedia addons (when installed)
   - Default WoW sounds (option to keep original)

3. **User controls**:
   - Enable/disable addon globally
   - Volume slider (0-100%, affects BLU sounds only)
   - Channel selection (Master/Sound/Music/Ambience/Dialog)
   - Mute in instances/combat options
   - Per-event sound selection via dropdowns
   - Test buttons for all sounds

### ✅ Completed Features (v6.0.0-alpha)

#### Core Systems
- ✅ Complete modular rewrite without external dependencies (no Ace3)
- ✅ Custom framework implementation
- ✅ Event system with hooks and timers
- ✅ SavedVariables database management
- ✅ Dynamic module loading system
- ✅ Localization support (8 languages)
- ✅ Sound registry with categorization

#### User Interface
- ✅ New options panel with 14 tabs across 3 rows
- ✅ Dropdown menus for sound selection
- ✅ Volume control slider (0-100%)
- ✅ Sound channel selection (Master/Sound/Music/Ambience/Dialog)
- ✅ Module management interface (enable/disable features)
- ✅ RGXMods community tab
- ✅ Test buttons for all sounds

#### Sound System
- ✅ Three-tier sound implementation:
  - Default WoW sounds (uses game's default sound channels)
  - BLU internal sounds (respects BLU volume slider, 0-100%)
  - External sounds via SharedMedia (uses game's default sound channels)
- ✅ Sound categorization by event type
- ✅ Mute in instances/combat options
- ✅ Show sound names in chat option

#### Event Support
- ✅ Level Up (PLAYER_LEVEL_UP)
- ✅ Achievement Earned (ACHIEVEMENT_EARNED)
- ✅ Quest Complete (QUEST_TURNED_IN)
- ✅ Reputation Gain (CHAT_MSG_COMBAT_FACTION_CHANGE)
- ✅ Honor Rank Up (HONOR_LEVEL_UPDATE)
- ✅ Renown Level (MAJOR_FACTION_RENOWN_LEVEL_CHANGED)
- ✅ Trading Post Rewards (PERKS_ACTIVITY_COMPLETED)
- ✅ Battle Pet Victory (PET_BATTLE_CLOSE)
- ✅ Delve Companion (COMPANION_SOFT_INTERACT_SUMMON_COMPLETE)

### ✅ Completed for v6.0.0-alpha (2025-08-05)

#### Bug Fixes
- [x] Fix tab layout and content panel visibility
- [x] Ensure all dropdown menus properly save/load state
- [x] Fix options panel database initialization timing
- [x] Correct scroll frame sizing in all panels
- [x] Fix alignment issues on all event tabs
- [x] Fix SharedMedia sound detection
- [x] Fix volume control show/hide logic
- [x] Fix dropdown menu overlapping

#### Features Implemented
- [x] WoW soundKit integration (50+ sounds)
- [x] Dynamic volume control for BLU sounds only
- [x] Module toggles on each event tab
- [x] SharedMedia fallback with test sounds
- [x] Removed unnecessary tabs (Modules, Sounds, RGXMods)
- [x] Add confirmation dialog for "Reset to Defaults" button
- [x] Add visual feedback when test sound is playing
- [x] Ensure smooth tab switching experience

### 📋 Remaining for v6.0.0 Release

- [ ] Improve dropdown menu tooltips with better descriptions
- [ ] Memory optimization for sound loading
- [ ] Add more BLU sound packs (currently have 13)
- [ ] Improve LibSharedMedia detection
- [ ] Add sound preview on hover (optional)
- [ ] Create user guide documentation

### 🚫 Out of Scope

The following features are NOT planned for BLU:
- Profile system (single profile only)
- Sound preview in dropdowns (use Test button instead)
- Custom sound upload (use SharedMedia addons)
- Sound pack creator (manual process)
- Import/Export settings (use SavedVariables)
- Minimap button (use /blu command)
- WeakAuras integration
- Custom event triggers beyond WoW events
- Sound effect chains or playlists
- Volume automation/fading
- Multi-track support

### 📝 Maintenance Tasks

- [ ] Update all sound pack .lua files to match new structure
- [ ] Verify all .ogg files are properly formatted
- [ ] Test with popular SharedMedia addons
- [ ] Performance testing with all modules enabled
- [ ] Update CurseForge/Wago descriptions

## Development Guidelines

### Sound Pack Requirements
BLU internal sounds:
- Single .ogg file per sound
- Volume controlled via in-game slider (0-100%)
- Played through selected sound channel

### Code Standards
- No external libraries
- Modular architecture
- Comprehensive error handling
- Debug logging for all operations
- Performance-first approach

### Testing Checklist
- [ ] All event types trigger correctly
- [ ] Volume control works for BLU sounds
- [ ] External sounds play at full volume
- [ ] Channel selection affects all sounds
- [ ] Settings persist through /reload
- [ ] No Lua errors in any scenario

## Version History

### v5.x → v6.0
- Complete rewrite without Ace3
- New UI system
- Modular architecture
- Better performance

### Future Considerations (Not Planned)
These items are documented but not currently planned:
- Classic WoW support (use BLU_Classic instead)
- Advanced audio processing
- Community sound pack repository
- Automated testing framework

## Support

- **Discord**: discord.gg/rgxmods
- **GitHub**: https://github.com/donniedice/BLU
- **Author**: donniedice
- **Email**: 60427166+donniedice@users.noreply.github.com