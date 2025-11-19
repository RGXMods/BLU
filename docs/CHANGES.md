## Version 6.0.0-alpha.5 (2025-11-05)

### 🚀 Features & Improvements

- **Core:**
    - Updated the `core/initialization.lua` file to dynamically load modules from the `modules` directory.
    - Updated the `core/commands.lua` file to dynamically get the list of testable events from the `BLU.Modules` table.
- **Documentation:**
    - Updated the `gemini.md`, `CLAUDE.md`, and `agent.md` files to reflect the current state of the addon.
    - Updated the `README.md` file to be more accurate and up-to-date.
- **Build:**
    - Updated the `.github/workflows/release.yml` file to upload the addon to Wago.io and WoWInterface.
- **Other:**
    - Updated the `BLU.toc` file to the correct version.
    - Updated the `blu.xml` file to include the `widgets.lua` file and remove the old options files.

---

## Version 6.0.0-alpha.4 (2025-10-31)

### 🐞 Bug Fixes & Improvements

-   **Core:**
    -   Fixed a syntax error in `core/internal_sounds.lua` that prevented the addon from loading correctly.
    -   Added a safer check in `core/sounds.lua` to prevent errors if the database is not ready.
-   **UI:**
    -   Fixed an error in the "About" panel that occurred when opening the options panel.
    -   Fixed the version number display in the options panel to remove the double 'v'.
-   **Sounds:**
    -   Fixed an issue where BLU game sounds were not correctly nested in the dropdown menus.

---

## Version 6.0.0-alpha.3 (2025-10-28)

### 🚀 Features & Improvements

-   **Sound System:**
    -   Implemented muting/unmuting of default WoW sounds when the addon is enabled/disabled.
-   **UI:**
    -   Added information about the BLU Classic addon to the "About" panel.
    -   Removed the "None" option from the volume selection dropdown for BLU internal sounds.

---

## Version 6.0.0-alpha.2 (2025-10-28)

### 🐞 Bug Fixes & Improvements

-   **Dropdown Menus:**
    -   Fixed an issue where SharedMedia sounds were not appearing in the sound selection dropdowns.
    -   Fixed a bug that caused an error when the "Installed Packs" page was viewed.
    -   Corrected the logic for the "Default Sound" option to play the intended BLU default sounds.
    -   Fixed the nesting of the "BLU WoW Defaults" category in the dropdowns.
    -   Fixed an issue with the volume dropdown visibility for BLU's internal sounds.
-   **Development:**
    -   Added a `copy_to_wow.bat` script for manual testing.
    -   Updated documentation to reflect the new manual testing process.
    -   Refactored internal sound packs for better organization and to fix nesting issues in the options panel.