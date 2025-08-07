# BLU Addon - New Structure Plan

## Current Structure Issues:
- Mixed core and module files
- Nested interface folders
- Unclear separation of concerns
- Difficult to maintain and scale

## New Professional Structure:

```
BLU/
│
├── Core/
│   ├── Core.lua               # Main addon initialization (from framework.lua)
│   ├── Config.lua             # Configuration and defaults
│   ├── Database.lua           # SavedVariables management
│   ├── Commands.lua           # Slash command handling
│   ├── API.lua                # Public API functions
│   ├── Utils.lua              # Utility functions
│   ├── Registry.lua           # Sound registry system
│   ├── Loader.lua             # Module loader
│   └── SharedMedia.lua        # SharedMedia integration
│
├── Modules/
│   ├── Quest/
│   │   ├── Quest.lua          # Quest module logic
│   │   └── QuestPanel.lua     # Quest settings panel
│   ├── LevelUp/
│   │   └── LevelUp.lua        # Level up module
│   ├── Achievement/
│   │   └── Achievement.lua    # Achievement module
│   ├── Reputation/
│   │   └── Reputation.lua     # Reputation module
│   └── [other modules...]
│
├── Interface/
│   ├── Settings.lua           # Main settings panel
│   ├── Design.lua             # Narcissus-style design system
│   ├── Widgets.lua            # UI widget helpers
│   ├── Tabs.lua               # Tab system
│   ├── Panels/
│   │   ├── General.lua        # General settings panel
│   │   ├── Sounds.lua         # Sound library panel
│   │   └── About.lua          # About panel
│   └── Templates/
│       └── Templates.xml      # Reusable XML templates
│
├── Media/
│   ├── Sounds/
│   │   ├── finalfantasy/
│   │   ├── zelda/
│   │   └── [other sound packs...]
│   └── Textures/
│       └── icon.tga           # Addon icon
│
├── Localization/
│   ├── enUS.lua               # English strings
│   ├── deDE.lua               # German strings
│   └── [other languages...]
│
├── Libs/
│   └── [third-party libraries if needed]
│
├── BLU.toc                    # Table of Contents
├── BLU.xml                    # Main XML loader
├── README.md                  # Documentation
└── LICENSE                    # License file
```

## Benefits:
1. **Clear separation** - Each folder has a specific purpose
2. **Modular** - Easy to add/remove features
3. **Maintainable** - Know exactly where to find things
4. **Scalable** - Can grow without becoming messy
5. **Professional** - Follows industry standards

## Migration Steps:
1. Create new folder structure
2. Move files to appropriate locations
3. Update all file paths in TOC and XML
4. Update require/include statements
5. Test thoroughly

This structure will make the addon much more professional and easier to work with!