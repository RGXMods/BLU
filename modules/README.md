# BLU Modular Architecture

## Overview
BLU v5.3.0 introduces a complete modular rewrite focused on performance and memory optimization. Only modules that are actively used will be loaded, significantly reducing CPU and memory usage.

## Module Structure

### Core Modules (Always Loaded)
- **Core.lua** - Essential addon functionality
- **ModuleLoader.lua** - Handles dynamic module loading/unloading
- **Config.lua** - Module configuration management

### Feature Modules (Loaded on Demand)
- **LevelUp.lua** - Character level-up sounds
- **Achievement.lua** - Achievement completion sounds
- **Reputation.lua** - Reputation gain sounds
- **Quest.lua** - Quest accept/turn-in sounds
- **BattlePet.lua** - Battle pet level-up sounds
- **DelveCompanion.lua** - Delve companion sounds
- **HonorRank.lua** - Honor rank sounds
- **RenownRank.lua** - Renown rank sounds
- **TradingPost.lua** - Trading post activity sounds

### Sound Modules (Loaded per Game)
- **Sounds/FinalFantasy.lua**
- **Sounds/Zelda.lua**
- **Sounds/Pokemon.lua**
- **Sounds/Mario.lua**
- etc...

## Benefits
1. **Reduced Memory Usage** - Only load sounds for selected games
2. **Faster Load Times** - Minimal initial loading
3. **Better Performance** - Lower CPU usage during gameplay
4. **Easier Maintenance** - Modular code structure
5. **User Customization** - Enable/disable specific features