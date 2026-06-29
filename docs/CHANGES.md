# Changes

`docs/CHANGES.md` is the canonical changelog summary for BLU.

## Current Development Release

### [v8.0.0-alpha.2](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/8.0.0-alpha.2.md) - 2026-06-28

- User custom sound manifests now resolve through the same filename/path resolver as `/blu addcustom`.
- Short custom filenames in `BLU\\media` and `BLU\\media\\sounds` now register correctly in the combat picker.
- Profile-stored custom sound entries are normalized through the same resolver on refresh.

Full notes:
- [v8.0.0-alpha.2 changelog](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/8.0.0-alpha.2.md)

### [v8.0.0-alpha.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/8.0.0-alpha.1.md) - 2026-06-11

- **Framework Migration — Stages 1-5 complete.** BLU now delegates events, timers, hooks, slash commands, and database to RGX-Framework.
- Database proxy stabilization: fixed `__newindex`/`__index` metamethod guards so internal fields (`_guard`, `_raw`, `_defaults`, `_callbacks`, `_onSwitch`) never leak into profile SavedVars.
- `BLU.db` proxy must never be overwritten — removed `BLU.db = profile` from `onProfileSwitch`.
- Fixed `MergeDefaults` → `MergeTable`, `Database:InitializeDatabase()` → `Database:Init()`, `BLU.db.currentProfile` → `BLU.db:GetActiveProfile()`.
- `ResetProfile("Default")` now works — removed incorrect `PROTECTED_PROFILE` block from Reset.
- Dead code purge: removed `ResetAdvancedSettings`, `RebuildDatabase`, `GetDB`/`SetDB` shims, shadowed `ShowExportDialog`/`ShowImportDialog`/`ShowCharacterCopyDialog`, broken `ExportSettings`/`ImportSettings` (iterated proxy methods, not data), triple `PlayTestSound` definitions, shadowed `CreateHousingPanel`, empty `housing.lua`.
- All 16 direct `_G.BLUDB` references in profiles.lua now route through `GetRawDB()` helper.
- `RGX.Addon()` bootstrap passes `opts.onSwitch` through to `NewDatabase`.
- Version string in `core/core.lua` synced to `v8.0.0-alpha.1`.
- Combat panel stripped to 3 launch-ready triggers (Combat Start / Combat End / Combat Music); removed 11 placeholder triggers and paging UI.
- Quest debug-mode handlers guarded against nil/invalid quest IDs (was crashing on `QUEST_ACCEPTED`/`QUEST_TURNED_IN`).

Full notes:
- [v8.0.0-alpha.1 changelog](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/8.0.0-alpha.1.md)

## Production Releases

### [v7.1.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/7.1.1.md) - 2026-06-10

- Utility deduplication: removed local DeepCopy, Throttle, Debounce, SafeCall — use RGX equivalents.
- Sound muter rewritten to use `RGX:GetSound():MuteList(ids)`.

### [v7.1.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/7.1.0.md) - 2026-06-10

- Removed local `combat_protection.lua` (344 lines) → `RGX:QueueForCombat()`.
- Removed local `dropdown.lua` (252 lines) → `RGX:GetDropdowns()`.

### [v7.0.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/7.0.0.md) - 2026-06-09

- Migrated from `RGX:OpenDB` to `RGX:NewDatabase` proxy (`BLU.db`).
- Combat load screen safety — deferred registration with `C_Timer.After` + `PLAYER_REGEN_ENABLED` retry.

### [v6.5.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.5.1.md) - 2026-05-02

- Fixed volume sliders not appearing for BLU game sounds (Lua pattern bug in registry).
- Replaced OptionsSliderTemplate with consistent custom track-style volume control across all panels.
- Volume label (Low/Medium/High) now shows below slider on hover only.
- Single-column rows shrunk from 90px to 68px so 4 housing options fit without overlap.
- Test buttons always align to the right side of the row.
- Volume slider centered between dropdown and test button in both single and 2-column layouts.
- Volume fill/thumb uses percentage-based positioning with deferred layout fix.

Full notes:
- [v6.5.1 changelog](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.5.1.md)

### [v6.5.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.5.0.md) - 2026-04-10

- Added a real `Combat` options page with the same module toggle header pattern used by the other panels.
- Replaced the old mock combat layout with a compact 2-column trigger grid that supports 8 trigger cards per page.
- Added real placeholder combat trigger rows with nested sound selection, compact volume control, and test playback buttons.
- Added dedicated combat cue slots for `Combat Start`, `Combat End`, and `Combat Music Track`.
- Cleaned up the Combat page layout by removing extra explanatory sections that were wasting vertical space.

Full notes:
- [v6.5.0 changelog](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.5.0.md)

## Recent History
- [v6.4.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.4.1.md)
- [v6.4.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.4.0.md)
- [v6.3.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.3.0.md)
- [v6.2.5](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.2.5.md)
- [v6.2.4](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.2.4.md)
- [v6.2.3](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.2.3.md)
- [v6.2.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.2.1.md)
- [v6.2.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.2.0.md)
- [v6.1.3](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.1.3.md)
- [v6.1.2](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.1.2.md)
- [v6.1.1](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.1.1.md)
- [v6.1.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.1.0.md)
- [v6.0.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.0.0.md)
