# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BLU (Better Level-Up!) is a World of Warcraft addon that replaces default sounds with iconic audio from 50+ games. Currently in v5.2.13 with a complete professional reorganization.

**Key Points:**
- Retail WoW only (TWW 12.0.0)
- Ace3 library dependencies
- Professional folder structure with proper capitalization
- Modular architecture for performance
- RGX Mods branding (RealmGX Community Project)
- Manual copy script (`copy_to_wow.bat`) for testing

## Current Directory Structure

```
BLU/
├── data/               # Core Systems and Modules
│   ├── battlepets.lua
│   ├── core.lua
│   ├── initialization.lua
│   ├── localization.lua
│   ├── options.lua
│   ├── sounds.lua
│   └── utils.lua
├── Libs/               # Ace3 Libraries
├── modules/            # Feature modules (quest, levelup, etc) - (assuming these exist from initial structure, need to re-verify)
├── media/              # Sounds and textures (assuming these exist from initial structure)
│   ├── sounds/         # Game sound files (.ogg)
│   └── Textures/       # Icons and images (.tga, .blp, .png)
├── localization/       # Language files (assuming these exist from initial structure)
├── .github/            # GitHub Actions workflows
├── BLU.toc             # Table of Contents (uppercase)
├── blu.xml             # Main XML loader (lowercase)
├── README.md           # Public documentation
└── CLAUDE.md           # This file
```

## Architecture

### Loading Order
`BLU.toc` -> `blu.xml` -> Libraries -> Data Files.

### AI Assistant Integration
This project uses `claude-code-router` to delegate tasks to specialized AI models:
- **`wow-ui-expert` (GPT-4o)**: For UI/UX design and implementation.
- **`lua-optimizer` (Deepseek)**: For performance and memory optimization.
- **`code-reviewer` (Gemini)**: For code quality, architecture, and security reviews.

### Key Design Decisions
- Ace3 library dependencies
- Custom lightweight framework mimics Ace3 API for easier migration
- Feature modules only loaded when enabled (CPU/memory optimization)

## Common Development Tasks

### Testing the Addon
To test changes in-game, you need to manually copy the addon files to your World of Warcraft directory.

1.  Run the `copy_to_wow.bat` script in the root of the repository.
2.  This will copy all the necessary files to your WoW AddOns directory (retail and beta).
3.  After the script finishes, use `/reload` in-game to see the changes.

### Git Workflow
- **`main`**: Stable releases.
- **`dev`**: Active development.
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
- The sound registry (`data/sounds.lua` or similar) contains logic to handle both consolidated and variant filenames.
- When working with sounds, refer to `data/sounds.lua` and the existing files in `media/sounds/` to understand the current conventions.

### Localization
- Use `BLU:Loc(key, ...)` for all user-facing strings.
- All localizations are stored in `data/localization.lua`.
