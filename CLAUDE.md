# CLAUDE.md

This file gives repository-specific guidance to Claude Code and similar coding agents working in this project.

## Project Overview

BLU (Better Level-Up!) is a Retail World of Warcraft addon that replaces milestone and progression sounds with curated audio from many other games.

Current release target:
- Version: `v6.4.0-alpha.1`
- WoW interface: `120001`
- Addon type: Retail-only UI/sound customization addon
- Branding: RGX Mods / RealmGX community project

## Current Structure

```text
blu/
|- core/                         # Framework, database, registry, loader, UI plumbing
|- modules/                      # Feature modules and dedicated panels
|  |- Achievement/
|  |- BattlePet/
|  |- Debug/
|  |- Delve/
|  |- Honor/
|  |- Housing/
|  |- LevelUp/
|  |- Quest/
|  |- Renown/
|  |- Reputation/
|  `- TradingPost/
|- media/                        # Sounds and textures
|- Localization/                 # Localized strings
|- docs/                         # Release notes and changelogs
|- user/                         # User-defined sound helpers / persisted assets
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
- `core/core.lua`: addon object, chat output, debug scope filtering, helpers
- `core/config.lua`: defaults and profile defaults
- `core/database.lua`: SavedVariables and profile persistence
- `core/loader.lua`: feature/module toggles and init helpers
- `core/registry.lua`: sound registration and event category mapping
- `core/interface/options/`: options UI shell and tab layout

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

## Development Expectations

When making changes:
- Keep `BLU.toc` and `core/core.lua` version strings aligned
- Keep `docs/CHANGES.md` as the single current release summary
- Use `scripts/release-alpha.ps1` for alpha cuts so branch push is the default and tag push is opt-in
- Add or update the matching file in `docs/changelogs/`
- Prefer keeping options panels compact and visually consistent with the existing BLU UI
- Use the existing BLU APIs for profile work:
  - `BLU.CreateProfile`
  - `BLU.LoadProfile`
  - `BLU.DeleteProfile`
  - `BLU.RenameProfile`

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
