# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BLU (Better Level-Up!) is a World of Warcraft addon that replaces default sounds with iconic audio from 50+ games. Currently in v6.0.0-alpha with a complete professional reorganization.

**Key Points:**
- Retail WoW only (TWW 11.0.5)
- No external library dependencies
- Professional folder structure with proper capitalization
- Modular architecture for performance
- RGX Mods branding (RealmGX Community Project)
- Manual copy script (`copy_to_wow.bat`) for testing

## Current Directory Structure

```
BLU/
├── core/               # Framework and core systems
├── modules/            # Feature modules (quest, levelup, etc)
├── interface/          # UI panels and widgets
│   └── panels/         # Individual panel files
├── media/              # Sounds and textures
│   ├── sounds/         # Game sound files
│   └── textures/       # Icons and images
├── localization/       # Language files
├── sound/              # Sound pack definitions
│   └── packs/          # Individual game sound packs
├── libs/               # External libraries (currently empty)
├── BLU.toc             # Table of Contents (uppercase)
├── BLU.xml             # Main XML loader (uppercase)
├── README.md           # Public documentation
└── CLAUDE.md           # This file
```

## Architecture

### Loading Order (via BLU.xml + _manifest.lua)
1. Core systems (core.lua, database.lua, config.lua, etc)
2. Localization files (enUS.lua)
3. Interface framework (design.lua, widgets.lua, tabs.lua)
4. Interface panels (general.lua, sounds.lua, about.lua)
5. Feature modules loaded via `modules/_manifest.lua` for dependency resolution
6. Sound packs (dynamically loaded)

### AI Assistant Integration
This project uses Claude Code Router with multiple AI models:
- **GPT-4**: General code analysis and best practices
- **Deepseek Coder**: Architecture optimization and performance
- **Gemini Pro**: Organization and maintainability recommendations
- Access via: `gpt`, `deepseek`, or `gemini` commands when router is running

### Core Systems
- **core.lua**: Main framework, event system, timers, hooks
- **database.lua**: SavedVariables management
- **config.lua**: Configuration defaults
- **registry.lua**: Sound registry system
- **loader.lua**: Dynamic module loading
- **sharedmedia.lua**: Optional SharedMedia support
- **optionslauncher.lua**: Options panel launcher (/blu command)

### Module Types
1. **Core Modules** (always loaded): framework, database, events, localization, config, utils
2. **Feature Modules** (loaded on-demand): levelup, achievement, quest, reputation, etc.
3. **Sound Modules** (loaded per game): finalfantasy, zelda, pokemon, etc.

### Key Design Decisions
- Feature modules only loaded when enabled (CPU/memory optimization)
- Sound files only loaded for selected games
- No dependencies on external libraries
- Custom lightweight framework mimics Ace3 API for easier migration

## Common Development Tasks

### Testing the Addon
To test changes in-game, you need to manually copy the addon files to your World of Warcraft directory.

1.  Run the `copy_to_wow.bat` script in the root of the repository.
2.  This will copy all the necessary files to `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\BLU`.
3.  After the script finishes, use `/reload` in-game to see the changes.

### Adding a New Sound Pack
1. Create `sound/packs/gamename.lua`
2. Define sounds with structure:
   ```lua
   local sounds = {
       gamename_levelup = {
           name = "Game Name - Level Up",
           file = "Interface\\AddOns\\BLU\\Media\\Sounds\\gamename.ogg",
           duration = 2.0,
           category = "levelup"
       }
   }
   BLU:RegisterSoundPack("gamename", "Game Name", sounds)
   ```
3. Add to `sound/packs/packs.xml`
4. Add .ogg files to `Media/Sounds/`

### Adding a New Feature Module
1. Create `Modules/FeatureName/FeatureName.lua`
2. Implement module structure:
   ```lua
   local module = BLU:NewModule("FeatureName")
   function module:Init() ... end
   function module:Cleanup() ... end
   ```
3. Update `BLU.xml` to include the new module

### Git Workflow
- Main branch: stable releases
- Alpha branch: active development
- **IMPORTANT**: Do NOT add Claude as co-author in commits
- Do NOT include any AI assistant attribution
- Commits should be made as the repository owner only

## Current State (v6.0.0-alpha)

### Latest Changes (2025-08-08)
- **AI Consensus Update**: Used GPT-4, Deepseek Coder, and Gemini Pro to analyze architecture
- Fixed ALL uppercase files in modules/ and interface/ directories  
- Created `modules/_manifest.lua` for explicit load ordering and dependency management
- Standardized all filenames to lowercase (modules, interface panels)
- Documented AI recommendations in `AI_CONSENSUS_REPORT.md`

### Previous Changes (2025-08-07)
- **MAJOR**: Complete directory reorganization to professional structure
- Cleaned up ~180MB of duplicate/unused files
- Converted ALL directories and files to lowercase naming
- Removed all test files, old options files, and artifacts
- Created proper sound pack structure
- Updated BLU.xml and BLU.toc with lowercase paths
- Removed Claude co-author attribution from git commits

### Working Features
- Options panel accessible via `/blu` command
- Tabbed interface (General, Sounds, About)
- Volume control system (0-100%)
- Sound channel selection
- Event-based sound playback
- Narcissus-style UI design
- Sound registry system

### Known Issues
- Some feature modules may need path updates
- Sound packs need to be fully implemented
- Options panel alignment needs fine-tuning

### Technical Requirements
- WoW Version: 11.0.5 (The War Within)
- Interface: 110105
- TOC: BLU.toc (uppercase)
- XML: BLU.xml (uppercase)

## Important Conventions

### Naming Conventions (STRICT REQUIREMENT)
- **ALL directories**: MUST be lowercase (e.g., `core/`, `modules/`, `interface/`, `media/textures/`)
- **ALL subdirectories**: MUST be lowercase (e.g., `modules/achievement/`, `interface/panels/`)
- **ALL Lua files**: MUST be lowercase (e.g., `levelup.lua`, `achievement.lua`)
- **ALL XML files**: MUST be lowercase (e.g., `modules.xml`, `packs.xml`)
- **ONLY EXCEPTIONS**:
  - `BLU.toc` - TOC file MUST be uppercase
  - `BLU.xml` - Main XML loader MUST be uppercase
  - Addon name in code: `BLU` (uppercase)
- **Author**: donniedice
- **Email**: 60427166+donniedice@users.noreply.github.com

**IMPORTANT**: Windows is case-insensitive but WoW's Lua is case-sensitive. All paths in XML/Lua must match exact case.

### Sound File Structure
- No more high/med/low variants in filenames
- Volume controlled via settings, not separate files
- Format: `gamename_soundtype.ogg`

### Localization
- Support for 8 languages: enUS, deDE, frFR, esES, ruRU, zhCN, zhTW, koKR
- Use `BLU:Loc(key, ...)` for all user-facing strings
- Fallback to English for missing translations