- Fixed - Version number updated in TOC files to v5.1.0 - [BLU.toc, BLU_Cata.toc, BLU_Vanilla.toc]
- Fixed - Corrected debug output localization for missing event handlers - [core.lua, initialization.lua]
- Fixed - Improved handling for pet level-up events to prevent misfires during initial load - [battlepets.lua]
  
- Updated - Enhanced pet level-up detection logic to handle journal updates and battle pet experience gains - [battlepets.lua]
- Updated - Integrated pet sound cooldown mechanism to prevent sound spam during level-ups - [battlepets.lua]
- Updated - Color alternation and localization keys for options panel elements - [options.lua, localization.lua]
  
- Restructured - Separated battle pet level tracking into its own module - [battlepets.lua, core.lua]
- Restructured - Centralized sound handling functions for player level, quest, and reputation events - [core.lua]
  
- Added - Support for pet level-up detection triggered by item use in the pet journal - [battlepets.lua]
- Added - Debug logging for pet level-up event and sound cooldowns - [battlepets.lua, localization.lua]
- Added - Delve Companion level-up detection using chat messages for Brann Bronzebeard - [core.lua, initialization.lua]