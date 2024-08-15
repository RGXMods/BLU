v5.0.0-alpha-------------------------------------------------------------
- Restructured - Centralized debug message handling [debug.lua, core.lua, initialization.lua]
- Restructured - Moved event handler and sound configuration functions from [core.lua] to [initialization.lua]
- Restructured - Sound options by game version [sounds.lua, core.lua]

- Updated - Dynamic options initialization by game version [options.lua]
- Updated - Combined Retail, Cata, and Vanilla options [options.lua]
- Updated - Added detailed debug logging [initialization.lua, core.lua, debug.lua]
- Updated - `release.yml` for alpha, beta, and stable release handling

- Fixed - Sound ID retrieval across game versions [sounds.lua]
- Fixed - Countdown timer logic [initialization.lua]
- Fixed - Proper loading of game-specific options [options.lua]

- Removed - Unused debug messages [debug.lua]

- Added - Debug logging with toggle for enable/disable [debug.lua]
- Added - New [initialization.lua] file to [/data/]
- Added - Tagging support: alpha (`v1.0.0-alpha`), beta (`v1.0.0-beta`), stable (`v1.0.0`)
