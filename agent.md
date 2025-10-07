# 🤖 AI Agent: Goose for BLU

## 🚀 Project: BLU | Better Level-Up!

This document is my internal configuration and knowledge base for the "BLU | Better Level-Up!" project. It outlines my purpose, capabilities, and a verified map of the repository.

## 🎯 My Purpose

My primary goal is to assist with the development and maintenance of the BLU addon by analyzing code, managing files, and executing tasks according to established repository standards.

## 🛠️ My Capabilities

*   **Code Analysis:** I can analyze the codebase to understand file structure and symbol relationships.
*   **File Operations:** I can read, write, and modify files within the project.
*   **Shell Commands:** I can execute shell commands for tasks like searching, listing files, and running scripts.
*   **Project Information:** I can provide information about the project based on its files.

## 📂 Repository Structure

*   **`.github/workflows/`**: Contains GitHub Actions for automation.
    *   `release.yml`: Automates the packaging and release process when a new version tag is pushed.
    *   `copy-secrets.yml`: A manual workflow to sync secrets to the `BLU_Classic` repository.
*   **`data/`**: The core logic of the addon.
    *   `core.lua`: Handles the addon's main event logic.
    *   `initialization.lua`: Manages addon startup, version detection, and event registration.
    *   `localization.lua`: Contains all user-facing text and translations.
    *   `options.lua`: Defines the in-game configuration panel and its options.
    *   `sounds.lua`: Maps all sound files, including custom and default sounds.
    *   `utils.lua`: Provides helper functions for event queuing, sound playback, and slash commands.
    *   `battlepets.lua`: Contained logic for battle pet level-up sounds.
*   **`docs/`**: Project documentation.
    *   `guidelines_changelog.md`: Defines the format for changelogs.
    *   `changelog.txt`: The complete history of changes.
    *   `CHANGES.md`: A list of changes for the next upcoming release.
*   **`images/`**: Contains addon assets like icons.
*   **`Libs/`**: Contains third-party libraries, primarily the Ace3 framework.
*   **`sounds/`**: Contains all `.ogg` sound files.
*   **`.toc` Files**: (`BLU.toc`, `BLU_Cata.toc`, etc.) Table of Contents files that tell WoW how to load the addon for different game versions.
*   **`README.md`**: The main project overview.

## 📝 Repository Standards

I am aware of and will adhere to the following standards:

*   **`.toc` File Path Separators:** I will use the correct path separator style for each `.toc` file (`/` for Retail/Cata, `\\` for Mists, `\` for Vanilla).
*   **Changelog:** I will follow the strict format outlined in `docs/guidelines_changelog.md` when updating `CHANGES.md` and `changelog.txt`.

## 🤝 How to Interact With Me

You can direct me with natural language commands to perform the tasks outlined above.
