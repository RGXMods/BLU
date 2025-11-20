# 🤖 AI Agent: Gemini for BLU

This document provides guidance for the Gemini AI agent when working with the BLU repository.

## 🚀 Project Overview

BLU (Better Level-Up!) is a World of Warcraft addon that replaces default sounds with iconic audio from 50+ games. The project is currently in `v5.2.13` and uses an Ace3-based framework.

**Key Points:**
- **Target**: Retail WoW (The War Within 12.0.0)
- **Framework**: Ace3-based framework.
- **Dependencies**: Ace3 libraries are used.
- **Branding**: RGX Mods (RealmGX Community Project)
- **Testing**: A directory junction is in place for automatic in-game testing.

## 🎯 My Purpose

My primary purpose is to assist with code quality, architecture, and best practices for the BLU addon. I am one of three specialized AI agents used in this project, and my role is defined as the **`code-reviewer`**.

My expertise, as configured in `.claude-code-router/agents/code-reviewer.json`, includes:
- Code quality, security, and best practices
- Architectural and design pattern review
- Error handling and edge case analysis
- WoW API usage validation
- Performance and maintainability assessment

## 🛠️ My Capabilities

*   **Code Analysis:** I can analyze the codebase to understand file structure, symbol relationships, and adherence to best practices.
*   **File Operations:** I can read, write, and modify files within the project.
*   **Shell Commands:** I can execute shell commands for tasks like searching, listing files, and running scripts.
*   **Project Information:** I can provide information about the project based on its files.

## 🤖 AI Assistant Integration

This project uses `claude-code-router` to delegate tasks to specialized AI models:
- **`wow-ui-expert` (GPT-4o)**: For UI/UX design and implementation.
- **`lua-optimizer` (Deepseek)**: For performance and memory optimization.
- **`code-reviewer` (Gemini)**: For code quality, architecture, and security reviews.

I can be invoked directly with the `gemini` command or automatically when keywords like `review`, `quality`, `bug`, `security`, or `architecture` are used.

## 📂 Repository Structure

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
├── modules/            # Feature modules (quest, levelup, etc)
├── media/              # Sounds and textures
│   ├── sounds/         # Game sound files (.ogg)
│   └── Textures/       # Icons and images (.tga, .blp, .png)
├── localization/       # Language files
├── .github/            # GitHub Actions workflows
├── .claude-code-router/ # AI agent configurations
├── BLU.toc             # Table of Contents (uppercase)
├── blu.xml             # Main XML loader (lowercase)
├── README.md           # Public documentation
└── gemini.md           # This file
```

## 🏗️ Architecture

- **Loading Order**: `BLU.toc` -> `blu.xml` -> Libraries -> Data Files.
- **Core Systems**: `data/core.lua` (main framework), `Libs/AceDB-3.0` (database), `Libs/AceConfig-3.0` (config), `data/sounds.lua` (sound system), `data/initialization.lua` (initialization).
- **Modules**: Feature modules (e.g., `levelup`, `quest`) are loaded on-demand based on user settings to optimize performance.
- **Design**: The addon uses an Ace3 framework.

## 📝 Common Development Tasks

### Testing the Addon
To test changes in-game, you need to manually copy the addon files to your World of Warcraft directory.

1.  Run the `copy_to_wow.bat` script in the root of the repository.
2.  This will copy all the necessary files to your WoW AddOns directory (retail and beta).
3.  After the script finishes, use `/reload` in-game to see the changes.

### Adding a New Feature Module
1.  Create `modules/NewFeature/NewFeature.lua`.
2.  Implement the module structure (Ace3 based).
3.  Add the new Lua file to `blu.xml` to be loaded.

### Git Workflow
- **`main`**: Stable releases.
- **`dev`**: Active development.
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
- The sound registry (`data/sounds.lua` or similar) contains logic to handle both consolidated and variant filenames.
- When working with sounds, refer to `data/sounds.lua` and the existing files in `media/sounds/` to understand the current conventions.

### Localization
- Use `BLU:Loc(key, ...)` for all user-facing strings.
- All localizations are stored in `data/localization.lua`.
