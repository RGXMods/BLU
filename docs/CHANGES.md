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