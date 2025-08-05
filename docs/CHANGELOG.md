# BLU Changelog

## v6.0.0-alpha (2025-08-05)

### Major Changes
- Complete UI overhaul with SimpleQuestPlates-inspired design
- Removed external library dependencies (no more Ace3)
- Modular architecture for better performance

### New Features
- **WoW SoundKit Integration**: Added 50+ built-in WoW sounds accessible via soundKit IDs
- **Dynamic Volume Control**: BLU volume slider appears only when BLU internal sounds are selected
- **Improved Sound Organization**: Three-tier sound system (Default WoW, WoW Game Sounds, BLU Packs, External)
- **Module Toggle Integration**: Enable/disable controls moved directly to each event tab
- **SharedMedia Fallback**: Test sounds provided when LibSharedMedia isn't available

### UI Improvements
- **Removed Unnecessary Tabs**: Removed Modules, Sounds, and RGXMods tabs for cleaner interface
- **Fixed Tab Alignment**: Proper spacing using design constants (Padding=20, Spacing=10)
- **Enhanced Dropdowns**: Better styling and improved sound selection menus
- **Consistent Layout**: All tabs now use standardized spacing and positioning

### Sound System Updates
- **Volume Variants**: BLU sounds properly use high/med/low variants based on volume setting
- **SoundKit Support**: Added comprehensive WoW soundKit integration
- **Sound Registry**: Fixed to handle both file-based and soundKit-based sounds
- **SharedMedia Detection**: Improved detection with fallback test sounds

### Bug Fixes
- Fixed dropdown menu structure issues
- Fixed volume control visibility logic
- Fixed content alignment on all event tabs
- Fixed scroll frame sizing to prevent content cutoff
- Fixed sound selection saving and loading
- Fixed module initialization order
- Fixed SharedMedia category detection

### Technical Improvements
- Added BLU.Design system for consistent UI styling
- Improved error handling throughout
- Better debug logging for troubleshooting
- Removed legacy code and unused files
- Updated to v6.0.0-alpha version numbering

### Known Issues
- LibSharedMedia detection requires the library to be embedded
- Some external sound packs may not be detected without LibSharedMedia

### Testing
- Added test commands: `/blutest fixes`, `/blutest sharedmedia`, `/blutest alignment`
- Comprehensive test coverage for sound system and UI

## Previous Versions

### v5.3.0
- Last version before major rewrite
- Used Ace3 libraries
- Different UI system