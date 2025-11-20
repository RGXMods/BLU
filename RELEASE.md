# BLU Release Notes

## Version 5.2.13 (2025-11-18)

### 🎉 Major Rework & Repurposing

This release marks a significant shift, repurposing the robust BLU Classic v1.1.9 codebase for the new BLU addon, focusing on enhanced compatibility and a cleaner structure.

### ✨ Highlights

- **Rebranding**: Complete rebranding from "BLU Classic" to "BLU".
- **Ace3 Framework**: Leverages the stable Ace3 library framework for core functionalities.
- **Version Update**: Updated to `v5.2.13` and interface version `120000` for WoW Midnight Beta.
- **Improved Compatibility**: Optimized for modern WoW environments while retaining core Classic features.

### 🔧 Technical Changes

#### Core Framework
- Ace3 based event system, database management, and options framework.
- Repurposed core logic from BLU Classic.

#### UI Improvements
- Utilizes AceGUI for options panel creation.
- Clean options panel with intuitive controls.

#### Module System
- Core modules implemented based on Classic architecture.

### 📦 Installation

1. Download the latest release
2. Extract to your WoW AddOns directory (Retail or Beta)
3. Launch WoW and type `/blu` to open settings

### 🐛 Known Issues

- Options panel alignment may need fine-tuning (inherited from Classic codebase).
- Some sound packs not fully implemented (inherited from Classic codebase).
- Profile system pending implementation (inherited from Classic codebase).
- Midnight Beta compatibility issues (e.g., "Secret Values," "Silent Thread Death") are being actively investigated and addressed in this version.

### 🔄 Migration from BLU Classic v1.x

**Important**: This version maintains compatibility with BLU Classic v1.x SavedVariables structure. Settings should migrate seamlessly.

### 📊 Performance Metrics

- (To be updated based on new codebase performance)

### 🎮 Compatibility

- **WoW Version**: 12.0.0 (The War Within Midnight Beta)
- **Interface**: 120000
- **Classic Support**: Not directly supported in this release, focus is on Retail/Beta.

### 👥 Contributors

- **donniedice**: Original author and maintainer
- **RGX Mods Community**: Testing and feedback

### 📝 Development Notes

This release establishes a clean foundation for future development based on the Classic codebase.

### 🚀 What's Next

- [ ] Full integration of modern WoW API features.
- [ ] Complete sound pack library (50+ games).
- [ ] Profile system with import/export.
- [ ] Custom trigger conditions.
- [ ] Visual effects system.

### 📋 Full Changelog

#### Added
- Ace3 library framework.
- BLU branding and versioning.

#### Changed
- Codebase repurposed from BLU Classic v1.1.9.
- `.toc` files updated.
- `blu.xml` rebuilt.
- Documentation updated for BLU.

#### Removed
- Redundant BLU Classic `.toc` files.

#### Fixed
- Initial compatibility for WoW Midnight Beta (via TOC update, initialization refactor).
- Resolved potential "Silent Thread Death" issues (via `PLAYER_ENTERING_WORLD` init, `charKey` refactor, `pcall` protection).
- Removed conflicting `core/database_safety.lua` reference (from `blu.xml`).
- Corrected sound categorization and registry reference.

### 📞 Support

- **Issues**: [GitHub Issues](https://github.com/donniedice/BLU/issues)
- **Discord**: RGX Mods Community
- **Email**: donniedice@protonail.com

---

*Thank you for repurposing BLU Classic! This release represents a fresh start for the BLU addon. Your feedback is always welcome.*
