# Changes

`docs/CHANGES.md` is the canonical changelog summary for BLU.

## Current Production Release

### [v6.4.0](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.4.0.md) - 2026-04-10

- Sound Output section on the General tab is now a self-contained card with a channel selector and a volume slider that reads/writes WoW's actual audio CVars.
- Profile management overhauled: Default is permanent and always pinned at the top of the dropdown; new profiles start from clean defaults; copies are true independent deep copies; preset application and profile switches fully rebuild all option tab panels in real time.
- Applying a preset now requires confirmation before overwriting profile settings.
- All Profiles panel action buttons (Create, Rename, Reset, Copy, presets) use the same animated hover style as the tab buttons, with consistent tooltips.
- Fixed welcome message, debug scopes, and module toggles all broken by stale nested `BLU.db.profile.*` schema references — standardized to flat `BLU.db.*` across the entire codebase.
- Fixed ghost widget stacking on repeated profile switches.
- Fixed `Slider:SetMinMaxValues` Lua error that blocked the General tab from rendering.
- Fixed "Database not ready" error on every options panel open.

Full notes:
- [v6.4.0 changelog](https://github.com/DonnieDice/BLU/blob/main/docs/changelogs/6.4.0.md)

## Recent History

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
