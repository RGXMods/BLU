# 🤖 AI Agent for BLU

This document provides guidance for any AI agent when working with the BLU repository.

## 🚀 Project Overview

BLU (Better Level-Up!) is a World of Warcraft addon that replaces default sounds with iconic audio from 50+ games. The project is currently in `v6.0.0-alpha` and has undergone a complete professional reorganization.

**Key Points:**
- **Target**: Retail WoW (The War Within 11.0.5)
- **Framework**: Custom lightweight, modular, event-driven framework.
- **Dependencies**: No external library dependencies.
- **Branding**: RGX Mods (RealmGX Community Project)
- **Testing**: A directory junction is in place for automatic in-game testing.

## 📂 Repository Structure

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
├── blu.xml             # Main XML loader (lowercase)
├── README.md           # Public documentation
└── agent.md            # This file
```

## 🏗️ Architecture

- **Loading Order**: `BLU.toc` -> `blu.xml` -> Core Systems -> Localization -> Interface -> Feature Modules.
- **Core Systems**: `core.lua` (main framework), `database.lua`, `config.lua`, `registry.lua` (sound system), `loader.lua`.
- **Modules**: Feature modules (e.g., `levelup`, `quest`) are loaded on-demand based on user settings to optimize performance.
- **Design**: The addon uses a custom lightweight framework that mimics some Ace3 API patterns for potential future migration.

## 🤖 AI Assistant Integration

This project uses `claude-code-router` to delegate tasks to specialized AI models:
- **`wow-ui-expert` (GPT-4o)**: For UI/UX design and implementation.
- **`lua-optimizer` (Deepseek)**: For performance and memory optimization.
- **`code-reviewer` (Gemini)**: For code quality, architecture, and security reviews.

## 📝 Common Development Tasks

### Testing the Addon
To test changes in-game, you need to manually copy the addon files to your World of Warcraft directory.

1.  Run the `copy_to_wow.bat` script in the root of the repository.
2.  This will copy all the necessary files to `C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\BLU`.
3.  After the script finishes, use `/reload` in-game to see the changes.

### Adding a New Feature Module
1.  Create `modules/NewFeature/NewFeature.lua`.
2.  Implement the module structure:
    ```lua
    local module = BLU:NewModule("NewFeature")
    function module:Init() ... end
    function module:Cleanup() ... end
    ```
3.  Add the new Lua file to `blu.xml` to be loaded.

### Git Workflow
- **`main`**: Stable releases.
- **`alpha`**: Active development.
- Commits should be made as the repository owner. Do not add AI assistants as co-authors.

## 📜 Important Conventions

### Naming Conventions (STRICT)
- **ALL directories**: MUST be `lowercase`.
- **ALL Lua and XML files**: MUST be `lowercase`.
- **EXCEPTIONS**:
  - `BLU.toc` MUST be `UPPERCASE`.
- **Addon Name in Code**: `BLU` (uppercase).
- **Author**: `donniedice`
- **Email**: `60427166+donniedice@users.noreply.github.com`

*Reasoning: Windows is case-insensitive, but WoW's Lua environment is case-sensitive. All paths in XML and Lua must match the exact case on the file system to prevent issues.*

### Sound File Structure
- The project is transitioning its sound file structure. While the goal is to have consolidated sound files with volume handled by addon settings, the current implementation still uses volume variants in filenames (e.g., `gamename_soundtype_high.ogg`).
- The sound registry (`core/registry.lua`) contains logic to handle both consolidated and variant filenames.
- When working with sounds, refer to `core/registry.lua` and the existing files in `media/sounds/` to understand the current conventions.

### Localization
- Use `BLU:Loc(key, ...)` for all user-facing strings.
- All localizations are stored in `localization/`.