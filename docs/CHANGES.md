- Added - Dynamic game version handling for Retail, Cataclysm, and Vanilla - [initialization.lua, utils.lua]
- Added - Localization strings for all user-facing text - [localization.lua]
- Added - New debug messages for comprehensive tracking - [initialization.lua, utils.lua, localization.lua]
- Added - New initialization logic for addon - [initialization.lua, utils.lua, localization.lua]
- Added - New sound categories and corresponding muting logic - [sounds.lua]
- Added - Slash command handling with dynamic response messages - [initialization.lua, utils.lua, localization.lua]
- Added - Slash commands `/blu debug`, `/blu welcome`, `/blu help` - [initialization.lua, utils.lua, localization.lua]

- Fixed - Errors related to sound ID selection and volume handling - [sounds.lua]
- Fixed - Initialization bugs caused by incorrect scoping and event registration - [initialization.lua, utils.lua]
- Fixed - Localization issues and missing strings - [localization.lua]

- Removed - Obsolete sound entries and updated muting lists accordingly - [sounds.lua]
- Removed - Redundant and outdated files related to specific game versions - [cata.lua, vanilla.lua, options_c.lua, options_v.lua, retail.lua]

- Restructured - Color alternation logic for options panel dynamically based on available groups - [initialization.lua]
- Restructured - Event registration and handling logic to support different WoW versions - [initialization.lua, utils.lua]
- Restructured - Separated core functionalities into [initialization.lua, utils.lua, localization.lua] for modular design
- Restructured - Removed deprecated files and consolidated sound management - [core.lua, cata.lua, vanilla.lua, options_c.lua, options_v.lua, retail.lua]

- Updated - .toc files to reflect version increment to v5.0.0 - [BLU.toc, BLU_Cata.toc, BLU_Vanilla.toc]
- Updated - GitHub Actions workflow for more precise versioning and changelog parsing - [release.yml]
- Updated - README to include new features and compatibility with 'The War Within' - [README.md]
- Updated - Refactored sound management for better maintainability - [sounds.lua]