# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BLU (Better Level-Up!) is a World of Warcraft addon that replaces default sounds with iconic audio from 50+ games. It's currently in v5.3.0-alpha, undergoing a complete modular rewrite without external library dependencies.

**Key Points:**
- Retail WoW only (Classic support moved to BLU_Classic repo)
- No external libraries (removed Ace3, implementing custom framework)
- Optional LibSharedMedia support for SoundPak compatibility
- Modular architecture for performance optimization
- All filenames use lowercase convention
- RGX Mods branding (RealmGX Community Project)

## Architecture

### Loading Order
1. `blu.xml` → `core/core.xml` → Framework loads first
2. `modules/modules.xml` → Core modules loaded
3. Feature modules loaded dynamically based on user settings
4. Sound modules loaded on-demand when sounds are selected

### Core Systems
- **Framework** (`core/framework.lua`): Custom event system, timers, hooks, slash commands
- **Database** (`core/database.lua`): SavedVariables management, profile system
- **Module Loader** (`modules/loader.lua`): Dynamic loading/unloading of feature modules
- **Sound Registry** (`modules/registry.lua`): Central sound management system

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
```bash
# Copy to WoW for testing (Windows)
xcopy /E /Y /I "C:\Users\donniedice\BLU" "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\BLU" /EXCLUDE:.git
```

### Adding a New Sound Pack
1. Create `sound/packs/gamename.lua`
2. Define sounds with structure:
   ```lua
   sounds = {
       gamename_soundtype = {
           name = "Game - Sound Name",
           file = "Interface\\AddOns\\BLU\\media\\sounds\\gamename\\sound.ogg",
           duration = 2.0,
           category = "levelup"
       }
   }
   ```
3. Add actual .ogg files to `media/sounds/gamename/`

### Adding a New Feature Module
1. Create `modules/features/featurename.lua`
2. Implement Init() and Cleanup() functions
3. Register events and handle them
4. Update module loader registry in `modules/loader.lua`

### Git Workflow
- Main branch: stable releases
- Alpha branch: active development
- Commit with co-author: `Co-Authored-By: Claude <noreply@anthropic.com>`

## Current State (v5.3.0-alpha)

### Completed Features
- Complete modular rewrite without Ace3
- Custom framework implementation
- File structure reorganization
- Options panel with tabs (General, Sounds, Modules, About)
- Volume control system (0-100%)
- Sound channel selection
- Sound registry with category-based playback
- Event handlers for all game events
- Sound browser UI for previewing sounds
- SharedMedia/SoundPak compatibility bridge

### In Development
- Additional sound packs (Zelda, Pokemon, Mario, etc.)
- Advanced sound categorization
- Profile system for multiple configurations

### Technical Status
- All core systems functional
- Options panel accessible via `/blu` command
- Sound playback working with volume control
- SharedMedia integration ready (optional)

### TOC File Requirements
- Must use `BLU.toc` (uppercase) for addon name
- Interface version: 110105 (The War Within)
- Main loader: `blu.xml` (lowercase)

## Important Conventions

### Naming
- All lua/xml files: lowercase (e.g., `levelup.lua`, `modules.xml`)
- TOC file: uppercase (`BLU.toc`)
- Addon name in code: `BLU` (uppercase)
- Author: donniedice
- Email: 60427166+donniedice@users.noreply.github.com

### Sound File Structure
- No more high/med/low variants in filenames
- Volume controlled via settings, not separate files
- Format: `gamename_soundtype.ogg`

### Localization
- Support for 8 languages: enUS, deDE, frFR, esES, ruRU, zhCN, zhTW, koKR
- Use `BLU:Loc(key, ...)` for all user-facing strings
- Fallback to English for missing translations