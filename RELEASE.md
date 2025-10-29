# BLU Release Notes

## Version 6.0.0-alpha.3 (2025-10-28)

### 🚀 Features & Improvements

-   **Sound System:**
    -   Implemented muting/unmuting of default WoW sounds when the addon is enabled/disabled.
-   **UI:**
    -   Added information about the BLU Classic addon to the "About" panel.
    -   Removed the "None" option from the volume selection dropdown for BLU internal sounds.

---

## Version 6.0.0-alpha.2 (2025-10-28)

### 🐞 Bug Fixes & Improvements

-   **Dropdown Menus:**
    -   Fixed an issue where SharedMedia sounds were not appearing in the sound selection dropdowns.
    -   Fixed a bug that caused an error when the "Installed Packs" page was viewed.
    -   Corrected the logic for the "Default Sound" option to play the intended BLU default sounds.
    -   Fixed the nesting of the "BLU WoW Defaults" category in the dropdowns.
    -   Fixed an issue with the volume dropdown visibility for BLU's internal sounds.
-   **Development:**
    -   Added a `copy_to_wow.bat` script for manual testing.
    -   Updated documentation to reflect the new manual testing process.
    -   Refactored internal sound packs for better organization and to fix nesting issues in the options panel.

---

## Version 6.0.0-alpha (2025-08-08)

### 🎉 Major Refactor Release

This release represents a complete architectural overhaul of the BLU addon, focusing on performance, maintainability, and user experience.

### ✨ Highlights

- **Complete Codebase Cleanup**: Reduced addon size by 75% (removed 180MB+ of redundant files)
- **Modular Architecture**: Each feature is now a self-contained module
- **Professional Structure**: Industry-standard directory organization
- **Performance Optimized**: Lazy loading, on-demand module activation
- **Sound Consolidation**: Single sound file per event (volume controlled via settings)

### 🔧 Technical Changes

#### Core Framework
- Custom event system without external dependencies
- Dynamic module loader with on-demand activation
- Centralized sound registry system
- SavedVariables database management
- Comprehensive configuration system

#### UI Improvements
- Modern-inspired design system
- Tabbed interface for settings
- Per-event sound customization
- Volume control (0-100%) with channel selection
- Sound preview functionality

#### Module System
Feature modules implemented:
- **LevelUp**: Character leveling events
- **Achievement**: Achievement unlocked notifications
- **Quest**: Quest accepted/completed sounds
- **Reputation**: Reputation changes
- **BattlePet**: Pet battle events
- **Honor**: PvP honor gains
- **Renown**: Renown rank increases
- **TradingPost**: Trading post activities
- **Delve**: Delve-specific events

### 📦 Installation

1. Download the latest release
2. Extract to `World of Warcraft/_retail_/Interface/AddOns/BLU`
3. Launch WoW and type `/blu` to open settings

### 🐛 Known Issues

- Options panel alignment needs fine-tuning
- Some sound packs not fully implemented
- Profile system pending implementation

### 🔄 Migration from v5.x

**Important**: This version uses a new SavedVariables structure. Your settings will be reset to defaults on first load.

### 📊 Performance Metrics

- **Memory Usage**: ~2MB idle, ~5MB active
- **CPU Impact**: <0.1% during normal gameplay
- **Load Time**: <100ms on average hardware

### 🎮 Compatibility

- **WoW Version**: 11.0.5 (The War Within)
- **Interface**: 110105
- **Classic Support**: Moved to separate BLU_Classic addon

### 👥 Contributors

- **donniedice**: Original author and maintainer
- **RGX Mods Community**: Testing and feedback

### 📝 Development Notes

This release establishes a clean foundation for future development:
- No external library dependencies
- Modular architecture allows easy feature additions
- Professional code organization improves maintainability
- Performance optimizations ensure minimal game impact

### 🚀 What's Next

- [ ] Complete sound pack library (50+ games)
- [ ] Profile system with import/export
- [ ] Custom trigger conditions
- [ ] Visual effects system

### 📋 Full Changelog

#### Added
- Professional directory structure
- Module loader system
- Sound registry pattern
- Modern design system

#### Changed
- Complete codebase reorganization
- All files/directories to lowercase
- Sound files consolidated (no more variants)
- SavedVariables structure updated
- UI panels rebuilt from scratch

#### Removed
- 180MB+ of duplicate/unused files
- High/low sound variants
- Test files and build artifacts
- Legacy Ace3 code
- Unused options implementations

#### Fixed
- Module loading performance
- Memory leaks in event handlers
- Sound playback timing
- Options panel registration
- File naming consistency

### 📞 Support

- **Issues**: [GitHub Issues](https://github.com/donniedice/BLU/issues)
- **Discord**: RGX Mods Community
- **Email**: 60427166+donniedice@users.noreply.github.com

---

*Thank you for using BLU! This release represents months of work to create a cleaner, faster, and more maintainable addon. Your feedback is always welcome.*