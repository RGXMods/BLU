# BLU Addon Structure

This document outlines the current file structure of the BLU addon for v5.3.0-alpha.

## Directory Structure

```
BLU/
├── BLU.toc                    # Main addon TOC file (uppercase required by WoW)
├── blu.xml                    # Main XML loader
├── README.md                  # User documentation
├── STRUCTURE.md              # This file
├── CLAUDE.md                 # AI assistant guidance
│
├── core/                     # Core framework files
│   ├── core.xml             # Core module loader
│   ├── addon.lua            # Main addon namespace and utilities
│   ├── commands.lua         # Slash command handlers
│   ├── database.lua         # SavedVariables management
│   ├── events.lua           # Event system implementation
│   ├── framework.lua        # Core framework (timers, hooks, etc)
│   └── init.lua             # Initialization sequence
│
├── docs/                    # Documentation
│   ├── ARCHITECTURE.md     # System architecture overview
│   ├── SHAREDMEDIA_COMPATIBILITY.md # SharedMedia integration guide
│   ├── CHANGES.md          # Version history
│   ├── changelog.txt       # Legacy changelog
│   └── todo.md            # Development tasks
│
├── localization/           # Localization files
│   └── localization.lua    # Multi-language support (8 languages)
│
├── media/                  # Media assets
│   ├── images/            # Icons and textures
│   │   ├── icon.tga      # Addon icon
│   │   ├── play.blp      # UI elements
│   │   └── preview.png   # Preview image
│   └── sounds/            # Sound files organized by game
│       └── finalfantasy/  # Final Fantasy sounds
│           ├── victory.ogg
│           ├── itemget.ogg
│           ├── save.ogg
│           └── crystal.ogg
│
├── modules/                # Feature and system modules
│   ├── modules.xml        # Module loader
│   ├── config.lua         # Configuration defaults
│   ├── utils.lua          # Utility functions
│   ├── registry.lua       # Sound registry system
│   ├── loader.lua         # Dynamic module loader
│   ├── localization.lua   # Localization module
│   │
│   ├── features.xml       # Feature modules loader
│   ├── features/          # Event-based feature modules
│   │   ├── achievement.lua    # Achievement earned sounds
│   │   ├── battlepet.lua     # Battle pet level sounds
│   │   ├── delvecompanion.lua # Delve companion sounds
│   │   ├── honorrank.lua     # Honor rank sounds
│   │   ├── levelup.lua       # Level up sounds
│   │   ├── quest.lua         # Quest completion sounds
│   │   ├── renownrank.lua    # Renown rank sounds
│   │   ├── reputation.lua    # Reputation gain sounds
│   │   └── tradingpost.lua   # Trading post sounds
│   │
│   └── interface/         # UI components
│       ├── options.lua    # Main options panel registration
│       ├── widgets.lua    # Reusable UI widgets
│       ├── tabs.lua       # Tab system implementation
│       └── panels/        # Option panel tab content
│           ├── about.lua     # About tab with info
│           ├── general.lua   # General settings (volume, etc)
│           ├── modules.lua   # Module enable/disable
│           └── sounds.lua    # Sound selection per event
│
└── sound/                 # Sound system
    ├── sound.xml         # Sound system loader
    ├── soundpak.lua      # SharedMedia/LibStub bridge
    ├── browser.lua       # Sound browser UI
    └── packs/            # Sound pack definitions
        └── finalfantasy.lua # Final Fantasy sound mappings
```

## Module Architecture

### Core Systems (Always Loaded)
1. **Framework** (`core/framework.lua`) - Event system, timers, hooks
2. **Database** (`core/database.lua`) - Settings and profiles
3. **Events** (`core/events.lua`) - Event registration/firing
4. **Registry** (`modules/registry.lua`) - Sound management

### Feature Modules (Loaded on Demand)
- Each handles specific game events
- Has `Init()` and `Cleanup()` functions
- Registers/unregisters events dynamically

### Sound Packs (Loaded as Needed)
- Define sound mappings for each game
- Register sounds with central registry
- Support hot-swapping

## Key Design Principles

1. **No External Dependencies** - Custom framework replacing Ace3
2. **Modular Loading** - Only load what's needed
3. **Performance First** - Minimal overhead, lazy loading
4. **SharedMedia Compatible** - Optional LibStub support
5. **Clear Separation** - Code, assets, and data separated

## File Naming Conventions

- **Lowercase**: All Lua/XML files (`levelup.lua`, `modules.xml`)
- **Uppercase**: TOC file only (`BLU.toc`)
- **Underscores**: Multi-word files (`trading_post.lua`)
- **Sound Files**: `gamename_eventtype.ogg`

## Loading Order

1. `BLU.toc` → `blu.xml`
2. `core/core.xml` → Framework initialization
3. `modules/modules.xml` → Core modules
4. `sound/sound.xml` → Sound system
5. Feature modules loaded based on settings
6. Sound packs loaded when selected

## SavedVariables Structure

```lua
BLUDB = {
    profile = {
        enabled = true,
        soundVolume = 100,
        soundChannel = "Master",
        randomSounds = false,
        selectedSounds = {
            levelup = "finalfantasy",
            achievement = "zelda",
            quest = "default"
            -- etc...
        }
    }
}
```

## Development Guidelines

1. **Module Independence** - Modules should not depend on each other
2. **Event Cleanup** - Always unregister events in Cleanup()
3. **Namespace Pollution** - Keep global namespace clean
4. **Debug Support** - Use `BLU:PrintDebug()` for development
5. **User Experience** - Fail gracefully, provide feedback