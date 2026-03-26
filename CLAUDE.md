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
│   ├── achievement/
│   ├── battlepet/
│   ├── delve/
│   ├── honor/
│   ├── levelup/
│   ├── quest/
│   ├── renown/
│   ├── reputation/
│   └── tradingpost/
├── media/              # Sounds and textures
│   ├── sounds/         # Game sound files (.ogg)
│   └── Textures/       # Icons and images (.tga, .blp, .png)
├── localization/       # Language files
├── libs/               # External libraries (LibSharedMedia-3.0)
├── .github/            # GitHub Actions workflows
├── .claude-code-router/ # AI agent configurations
├── BLU.toc             # Table of Contents (uppercase)
├── BLU.xml             # Main XML loader (lowercase)
├── README.md           # Public documentation
└── CLAUDE.md           # This file
```

## Architecture

### Loading Order
`BLU.toc` -> `BLU.xml` -> Core Systems -> Localization -> Interface -> Feature Modules.

### AI Assistant Integration
This project uses `claude-code-router` to delegate tasks to specialized AI models:
- **`wow-ui-expert` (GPT-4o)**: For UI/UX design and implementation.
- **`lua-optimizer` (Deepseek)**: For performance and memory optimization.
- **`code-reviewer` (Gemini)**: For code quality, architecture, and security reviews.

### Core Systems
- **core.lua**: Main framework, event system, timers, hooks
- **database.lua**: SavedVariables management
- **config.lua**: Configuration defaults
- **registry.lua**: Sound registry system
- **loader.lua**: Dynamic module loading
- **sharedmedia.lua**: Optional SharedMedia support

### Module Types
1. **Core Modules** (always loaded): framework, database, events, localization, config, utils
2. **Feature Modules** (loaded on-demand): levelup, achievement, quest, reputation, etc.

### Key Design Decisions
- Feature modules only loaded when enabled (CPU/memory optimization)
- No dependencies on external libraries
- Custom lightweight framework mimics Ace3 API for easier migration

## Common Development Tasks

### Testing the Addon
To test changes in-game, you need to manually copy the addon files to your World of Warcraft directory.

1.  Run the `copy_to_wow.bat` script in the root of the repository.
2.  This will copy all the necessary files to `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\BLU`.
3.  After the script finishes, use `/reload` in-game to see the changes.

### Adding a New Feature Module
1. Create `modules/NewFeature/NewFeature.lua`
2. Implement module structure:
   ```lua
   local module = BLU:NewModule("NewFeature")
   function module:Init() ... end
   function module:Cleanup() ... end
   ```
3. Add the new Lua file to `BLU.xml` to be loaded.

### Git Workflow
- **`main`**: Stable releases.
- **`alpha`**: Active development.
- **IMPORTANT**: Do NOT add Claude as co-author in commits
- Do NOT include any AI assistant attribution
- Commits should be made as the repository owner only

## Important Conventions

### Naming Conventions (STRICT REQUIREMENT)
- **ALL directories**: MUST be `lowercase`.
- **ALL Lua and XML files**: MUST be `lowercase`.
- **EXCEPTIONS**:
  - `BLU.toc` MUST be `UPPERCASE`.
- **Addon Name in Code**: `BLU` (uppercase).
- **Author**: `donniedice`
- **Email**: `60427166+donniedice@users.noreply.github.com`

**IMPORTANT**: Windows is case-insensitive but WoW's Lua is case-sensitive. All paths in XML/Lua must match exact case.

### Sound File Structure
- The project is transitioning its sound file structure. While the goal is to have consolidated sound files with volume handled by addon settings, the current implementation still uses volume variants in filenames (e.g., `gamename_soundtype_high.ogg`).
- The sound registry (`core/registry.lua`) contains logic to handle both consolidated and variant filenames.
- When working with sounds, refer to `core/registry.lua` and the existing files in `media/sounds/` to understand the current conventions.

### Localization
- Use `BLU:Loc(key, ...)` for all user-facing strings.
- All localizations are stored in `localization/`.
