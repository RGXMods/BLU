## Version 6.0.0 (2026-03-23)

### Complete Rewrite — Better Level-Up! v6

v6.0.0 is a ground-up rewrite of BLU with a new modular architecture, a fully redesigned options UI, and expanded sound pack support.

### Architecture
- Rebuilt on a clean modular core (`core/`) replacing the legacy monolithic structure.
- All feature modules (`Quest`, `LevelUp`, `Achievement`, `Reputation`, `BattlePet`, `Honor`, `Renown`, `TradingPost`, `Delve`) are independently loaded and toggleable.
- New `combat_protection.lua` guards against taint during combat.
- New `registry.lua` and `loader.lua` for safe dynamic module registration.

### Sound System
- New unified sound registry with per-module sound selection.
- Auto-discovers compatible audio from other loaded addons at startup — no external libraries required.
- Optional `LibSharedMedia-3.0` integration: if installed, BLU hooks in automatically for broader pack coverage.
- Added public API `BLU:RegisterExternalSoundPack(packName, soundEntries)` for direct third-party pack registration.
- Improved discovery timing — rebinds and rescans when media/addons register after startup.
- Added `/blu refresh` and `/blu rescan` slash commands for safe manual media rebuild without reloading.
- Fixed forbidden-table iteration errors during external sound rescans.

### User Custom Sounds
- New "User Custom Sounds" pack: drop `.ogg`, `.mp3`, or `.wav` files into `BLU\user\sounds\` and register them in `BLU\user\user_sounds.lua`.
- User sounds appear as a dedicated pack in the Sounds tab and are selectable in all module dropdowns.
- Reference sounds from any path — not just the BLU folder.
- Use `/blu refresh` or `/reload` to pick up changes without restarting the game.

### Options UI
- Fully redesigned settings panel integrated into the Retail Settings list with BLU icon and styled title.
- New tab system: General, Sounds, Modules, About.
- Sounds tab uses multi-column layout with spillover/paging for large pack lists (175+ entries).
- Inline play button for sound previews; in-dropdown `♪ Preview` actions in nested sound menus.
- Single-line sound labels with truncation and tooltip; removed repeated addon/pack prefixes.
- Module toggle now serves as the disable control (removed redundant `None` option from dropdowns).
- About panel displays real BLU-loaded pack/count data dynamically.
- Improved section/header spacing and border rendering to reduce clipped frames.

### Bug Fixes
- Fixed Delve chat taint error.
- Fixed burst-trigger freeze on rapid event firing.
- Fixed syntax errors in sound and initialization modules preventing addon load.
- Fixed `About` panel error on first open.
- Fixed version display double-`v` in options panel.
- Fixed BLU game sounds not correctly nested in dropdown menus.
- Fixed SharedMedia sounds not appearing in sound selection dropdowns.
- Fixed `Installed Packs` page error.
- Fixed `Default Sound` option playing incorrect sounds.

### Compatibility
- Updated `BLU.toc` interface version to `120001` for WoW Midnight `12.0.1`.
