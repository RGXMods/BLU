## Version 6.1.1 (2026-03-25)

### Patch Release

#### UI Fixes
- Added scroll frame to Housing tab — 4 sound pickers now scroll within the panel instead of overflowing.
- Added scroll frame to Delve tab — now shows all 3 Delve triggers (Companion Level Up, Life Lost, Life Gained) in a single scrollable panel.
- Fixed tab icons for Trading Post, Delve, and Housing — previous icon paths did not exist in the WoW client.
- Fixed `PlaySoundFile` audio channel from `"Master"` to `"SFX"` — resolves sounds not playing for some users.

---

## Version 6.1.0 (2026-03-24)

### Minor Release

#### New Triggers
- Added **Achievement Progress** trigger — plays sound when tracked achievement criteria advance (not just on full completion).
- Added **Quest Progress** trigger — plays sound when tracked quest objectives update mid-quest.
- Added **Pet Capture** trigger — plays sound when a wild battle pet is successfully captured.
- Added **Delve Life Lost** trigger — plays sound when the player loses a life (candle) during a delve.
- Added **Delve Life Gained** trigger — plays sound when the player gains an extra life during a delve.

#### Bug Fixes
- Fixed Housing module `HOUSE_DECOR_ADDED_TO_CHEST` phantom event registration causing errors when the event was never fired by the game client.
- Fixed house level-up detection: `HOUSE_LEVEL_CHANGED` payload has no `houseGUID` field — replaced per-GUID map with a simple `lastKnownHouseLevel` tracker seeded from `CURRENT_HOUSE_INFO_RECIEVED`/`UPDATED`.

---

## Version 6.0.3 (2026-03-24)

### Patch Release

- Fixed `Random` sound selection to pull from all registered playable sounds instead of only the current event pool.
- Forced BLU internal sounds chosen by `Random` to use the medium variant by default when low/medium/high versions exist.
- Corrected no-edit custom sound auto-detection to look in `Interface\AddOns\` and `Interface\AddOns\sounds\`.

## Version 6.0.2 (2026-03-24)

### Patch Release

- Fixed BLU startup slowdowns by limiting expensive external media rescans during load and narrowing late addon rescans to likely media providers.
- Fixed honor rank detection by sampling the player's actual honor level across the current event set instead of relying on a single payload path.
- Fixed BLU chat and welcome-message icon rendering by standardizing all chat prefixes to the shipped addon icon texture.
- Replaced the old About tab with a Housing planning tab and added Discord info directly to the options header.
- Fixed Trading Post and Delve tab icon assignments to use working Retail icon paths.
- Added no-edit custom sound auto-detection for `custom01` through `custom24` in `Interface\AddOns\` and `Interface\AddOns\sounds\`, while keeping `user_sounds.lua` support for manual entries.

## Version 6.0.1 (2026-03-24)

### Patch Release

- Fixed SharedMedia external sound rescans timing out with `script ran too long` by narrowing BLU's generic bridge fallback scan to likely media and sound pack containers instead of broadly crawling addon/global tables.
- Reduced login and manual `/blu refresh` rescan errors when large addon stacks are loaded.

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
