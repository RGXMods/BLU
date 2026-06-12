# CLAUDE.md

This file gives repository-specific guidance to Claude Code and similar coding agents working in this project.

## Project Overview

BLU (Better Level-Up!) is a Retail World of Warcraft addon that replaces milestone and progression sounds with curated audio from many other games.

Current release target:
- Version: `v8.0.0-alpha.1`
- WoW interface: `120005`
- Addon type: Retail-only UI/sound customization addon
- Branding: RGX Mods / RealmGX community project
- Framework dependency: RGX-Framework v2.0.0-alpha.1

## Current Structure

```text
blu/
|- core/                     # Framework, database, registry, loader, UI plumbing
|- modules/                  # Feature modules and dedicated panels
|  |- Achievement/
|  |- BattlePet/
|  |- Collectibles/
|  |- Combat/
|  |- Debug/
|  |- Delve/
|  |- Honor/
|  |- Housing/
|  |- LevelUp/
|  |- Loot/
|  |- Prey/
|  |- Quest/
|  |- Renown/
|  |- Reputation/
|  `- TradingPost/
|- media/                    # Sounds and textures
|- Localization/             # Localized strings
|- docs/                     # Release notes and changelogs
|- user/                     # User-defined sound helpers / persisted assets
|- BLU.toc
|- BLU.xml
|- README.md
`- CLAUDE.md
```

## Architecture Notes

Loading flow:
- `BLU.toc` loads `BLU.xml`
- `BLU.xml` loads core systems, interface files, then feature modules
- `core/initialization.lua` handles staged setup after files are available

Important core files:
- `core/core.lua`: addon object, chat output, debug scope filtering, helpers, RGX.Addon() bootstrap
- `core/config.lua`: defaults and profile defaults
- `core/systems/database.lua`: thin adapter over `RGX:NewDatabase()` — profile CRUD, serialization, export/import dialogs delegate to framework proxy
- `core/systems/utils.lua`: sound queue, channel routing, interrupt-music logic (DeepCopy/Throttle/Debounce removed — use RGX)
- `core/systems/registry.lua`: sound registration, mute system (delegated to RGX Sound), event category mapping
- `core/systems/loader.lua`: feature/module toggles and init helpers
- `core/interface/options/`: options UI shell and tab layout
- `core/interface/options/profiles.lua`: profile management panel — uses `GetRawDB()` helper and `BLU.db:GetActiveProfile()` for proxy-safe access

Important current UI panels:
- `core/interface/options/general.lua`
- `core/interface/options/profiles.lua`
- `core/interface/options/sound_panel.lua`
- `modules/Debug/Debug.lua`

## Current Product Shape

The addon now includes:
- A 3-row options tab layout
- A dedicated Profiles tab with create/load/rename/delete/reset/import-export controls
- A dedicated Debug tab backed by `modules/Debug/Debug.lua`
- Sounds-style grouped UI sections for larger management panels
- Support for event-based sounds across level up, achievements, quests, pets, delve, renown, honor, reputation, trading post, and housing-related triggers

## RGX-Framework Migration Status

BLU is progressively migrating to RGX-Framework. The following systems now delegate to RGX:

| BLU System | RGX Replacement | Status |
|---|---|---|
| Event system | `RGX:RegisterEvent` (delegation with fallback) | Done |
| Timer system | `RGX:After` / `RGX:Every` | Done |
| Hooks + slash | `RGX:RegisterHook` / `RGX:RegisterSlashCommand` | Done |
| Addon bootstrap | `RGX.Addon()` with full fallback | Done |
| Database / profiles | `RGX:NewDatabase()` proxy (`BLU.db`) | Done |
| Combat protection | `RGX:QueueForCombat()` | Removed (was 344 lines) |
| Dropdowns | `RGX:GetDropdowns()` | Removed (was 252 lines) |
| Utility (DeepCopy, Throttle, Debounce, SafeCall) | `RGX:DeepCopy` / `RGX:Throttle` / `RGX:Debounce` / `RGX:QueueForCombat` | Removed |
| Sound muting | `RGX:GetSound():MuteList(ids)` | Delegated |
| SharedMedia scanning | `sharedmedia.lua` (local) | **Not yet migrated** |

Key proxy rules:
- `BLU.db` must never be overwritten — it is the proxy table with `__index`/`__newindex`
- Internal proxy fields (`_guard`, `_raw`, `_defaults`, `_callbacks`, `_onSwitch`) use `rawget`/`rawset`
- Direct `_G.BLUDB` access should go through `GetRawDB()` (in profiles.lua) or `BLU.db._raw`
- `BLU.db:GetActiveProfile()` replaces `BLU.db.currentProfile`

When making changes:
- Keep `BLU.toc` and `core/core.lua` version strings aligned
- Keep `docs/CHANGES.md` as the single current release summary
- Use `scripts/release-alpha.ps1` for alpha cuts so branch push is the default and tag push is opt-in
- Add or update the matching file in `docs/changelogs/`
- Prefer keeping options panels compact and visually consistent with the existing BLU UI
- Use the proxy API for profile work:
  - `BLU.db:CreateProfile(name)` / `BLU.CreateProfile(name)`
  - `BLU.db:LoadProfile(name)` / `BLU.LoadProfile(name)`
  - `BLU.db:DeleteProfile(name)` / `BLU.DeleteProfile(name)`
  - `BLU.db:RenameProfile(old, new)` / `BLU.RenameProfile(old, new)`
  - `BLU.db:GetActiveProfile()` — current profile name (not `BLU.db.currentProfile`)
  - `BLU.db:ResetProfile()` — reset active profile to defaults (works on "Default" too)
  - `BLU.db:OnProfileChanged(fn)` — register switch callback
- Never assign `BLU.db = <anything>` — the proxy must not be overwritten
- For direct profile table access (CRUD on raw profile data), use `BLU.db._raw` or `GetRawDB()`

## Naming And File Conventions

- Addon object name in code is always `BLU`
- `BLU.toc` stays uppercase
- Module directories use PascalCase names such as `modules/Debug/Debug.lua`
- Core/interface filenames are generally lowercase
- Paths referenced from XML and Lua must match actual casing exactly

## Testing Workflow

Primary local test path:
- `E:\World of Warcraft\_retail_\Interface\AddOns\BLU`

Common sync command:

```powershell
robocopy 'c:\Users\Admin\projects\blu' 'E:\World of Warcraft\_retail_\Interface\AddOns\BLU' /MIR /XD .git .claude .claude-code-router .github /XF CLAUDE.md *.tmp *.bak
```

After syncing:
- launch or focus Retail WoW
- run `/reload`
- test the changed tab or event in the options UI

## Debug Guidance

Debug output is intentionally scoped now.

Relevant areas:
- `core`
- `options`
- `tabs`
- `registry`
- `loader`
- `database`
- `profiles`
- `modules`
- `events`
- `sounds`
- `features`

Prefer using `BLU:Trace(scope, message)` for new debug output so it respects the Debug tab filters.

## Documentation To Keep In Sync

When feature work lands, check these files:
- `README.md`
- `docs/description.html`
- `docs/CHANGES.md`
- `docs/changelogs/<version>.md`
- `ROADMAP.md` when future/planned work changes

## Git And Commit Expectations

- Do not add AI co-author lines
- Do not include assistant attribution in commits
- Do not rewrite unrelated user changes
- Avoid destructive git commands unless explicitly requested
