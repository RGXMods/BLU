# BLU Directory Structure

```
BLU/
├── blu.toc                 # Main TOC file
├── blu.xml                 # Main XML loader
├── core/                   # Core systems
│   ├── core.xml           # Core XML loader
│   ├── framework.lua      # Main framework (no dependencies)
│   ├── database.lua       # Settings/SavedVariables
│   ├── events.lua         # Event system
│   └── init.lua          # Initialization
├── modules/               # All modules
│   ├── modules.xml       # Modules XML loader
│   ├── loader.lua        # Module loader system
│   ├── localization.lua  # Localization module
│   ├── options.lua       # Options UI
│   ├── registry.lua      # Sound registry
│   ├── utils.lua         # Utilities
│   └── features/         # Feature modules
│       ├── features.xml
│       ├── levelup.lua
│       ├── achievement.lua
│       ├── reputation.lua
│       ├── quest.lua
│       ├── battlepet.lua
│       ├── delvecompanion.lua
│       ├── honorrank.lua
│       ├── renownrank.lua
│       └── tradingpost.lua
├── sound/                # Sound system
│   ├── sound.xml        # Sound XML loader
│   ├── soundpak.lua     # SoundPak integration
│   ├── browser.lua      # Game sound browser
│   └── packs/           # Sound pack modules
│       ├── finalfantasy.lua
│       ├── zelda.lua
│       ├── pokemon.lua
│       └── ...
├── media/               # Media files
│   ├── sounds/          # Actual .ogg files
│   │   ├── finalfantasy/
│   │   ├── zelda/
│   │   └── ...
│   └── images/          # Icons and textures
│       └── icon.tga
├── legacy/              # Old code for reference
└── docs/                # Documentation
```

## Key Changes:
1. All lowercase filenames
2. Single core/ directory for framework
3. Single sound/ directory for sound system
4. media/ directory for actual files
5. Clear separation of code and assets