## Alpha 2
- Fixed - Missing debug message statements after refactoring
- Fixed - Trimmed input for slash command handling to avoid issues with whitespace
- Fixed - Corrected an issue where a missing `end` statement caused initialization errors
- Fixed - Prevented multiple reputation rank increases from triggering in quick succession - [core.lua]

- Updated - Refined game version handling to reduce redundancy - [initialization.lua]
- Updated - Consolidated event registration by game version - [initialization.lua]
- Updated - Moved all localization strings, including debug messages, to `localization.lua` - [localization.lua]
- Updated - Centralized debug message handling to improve code maintainability - [initialization.lua]
- Updated - Replaced repeated function blocks with centralized `HandleEvent` function - [core.lua]
- Updated - Improved logic for Delve Level-Up detection and sound triggering - [core.lua]
- Updated - Added a new halt timer message to prevent multiple executions - [localization.lua]
- Updated - Improved sound selection logic to consolidate valid sound IDs and reduce redundancy - [utils.lua]
- Updated - Enhanced slash command handling to log unknown commands and simplify toggles for debug mode and welcome message - [utils.lua]

- Added - Chat message output for Trade Post Activity Complete event - [core.lua, localization.lua]

## Alpha 1
- Fixed - Corrected an issue with `GetAddOnMetadata` causing an error during initialization - [initialization.lua].
- Fixed - Sound ID retrieval across game versions - [sounds.lua].
- Fixed - Countdown timer logic - [initialization.lua].
- Fixed - Proper loading of game-specific options - [options.lua].
- Fixed - AceConfigRegistry error due to invalid `soundOptions` reference in options panel - [options.lua].

- Updated - Improved scoping across all files to ensure proper access and modularity - [core.lua, initialization.lua, utils.lua, options.lua].
- Updated - Restructured the handling of shared events to align with game versions - [initialization.lua].
- Updated - Dynamic options initialization by game version - [options.lua].
- Updated - Combined Retail, Cata, and Vanilla options - [options.lua].
- Updated - Added detailed debug logging - [initialization.lua, core.lua, localization.lua].
- Updated - `release.yml` for alpha, beta, and stable release handling.

- Restructured - Centralized debug message handling - [localization.lua, core.lua, initialization.lua].
- Restructured - Moved event handler and sound configuration functions from [core.lua] to [initialization.lua].
- Restructured - Sound options by game version - [sounds.lua, core.lua].
- Restructured - Code organization to improve modularity and maintainability - [core.lua, initialization.lua, utils.lua, options.lua].

- Removed - Unused debug messages - [localization.lua].

- Added - Debug logging with toggle for enable/disable - [localization.lua].
- Added - New [initialization.lua] file to [/data/].
- Added - Tagging support: alpha (`v1.0.0-alpha`), beta (`v1.0.0-beta`), stable (`v1.0.0`).
- Added - New event registrations to cover all supported game versions - [initialization.lua].
