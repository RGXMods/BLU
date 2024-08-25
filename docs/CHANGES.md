- Fixed - Corrected an issue with `GetAddOnMetadata` causing an error during initialization - [initialization.lua]
- Fixed - Corrected the initialization of `VersionNumber` to ensure proper scoping and availability across files - [initialization.lua, options.lua]
- Fixed - Sound ID retrieval across game versions - [sounds.lua]
- Fixed - Countdown timer logic - [initialization.lua]
- Fixed - Proper loading of game-specific options - [options.lua]
- Fixed - AceConfigRegistry error due to invalid `soundOptions` reference in options panel - [options.lua]

- Updated - Improved scoping across all files to ensure proper access and modularity - [core.lua, initialization.lua, utils.lua, options.lua]
- Updated - Restructured the handling of shared events to align with game versions - [initialization.lua]
- Updated - Integrated delayed initialization for `VersionNumber` using the `PLAYER_LOGIN` event - [initialization.lua]
- Updated - Dynamic options initialization by game version - [options.lua]
- Updated - Combined Retail, Cata, and Vanilla options - [options.lua]
- Updated - Added detailed debug logging - [initialization.lua, core.lua, debug.lua]
- Updated - `release.yml` for alpha, beta, and stable release handling

- Restructured - Centralized debug message handling - [debug.lua, core.lua, initialization.lua]
- Restructured - Moved event handler and sound configuration functions from [core.lua] to [initialization.lua]
- Restructured - Sound options by game version - [sounds.lua, core.lua]
- Restructured - Code organization to improve modularity and maintainability - [core.lua, initialization.lua, utils.lua, options.lua]

- Removed - Unused debug messages - [debug.lua]

- Added - Debug logging with toggle for enable/disable - [debug.lua]
- Added - New [initialization.lua] file to [/data/]
- Added - Tagging support: alpha (`v1.0.0-alpha`), beta (`v1.0.0-beta`), stable (`v1.0.0`)
- Added - New event registrations to cover all supported game versions - [initialization.lua]