# Sound Files Directory

This directory contains all the actual sound files (.ogg format) organized by game.

## Directory Structure:
```
sounds/
├── FinalFantasy/
│   ├── victory.ogg
│   ├── levelup.ogg
│   └── ...
├── Zelda/
│   ├── secret.ogg
│   ├── item.ogg
│   └── ...
├── Pokemon/
│   ├── levelup.ogg
│   ├── evolution.ogg
│   └── ...
└── ...
```

## Adding New Sounds:
1. Create a folder for the game if it doesn't exist
2. Add .ogg files (optimize for size, typically 64-128 kbps)
3. Create a corresponding module in `/modules/sounds/GameName.lua`
4. Register the sounds in the module

## Sound Guidelines:
- Format: OGG Vorbis
- Bitrate: 64-128 kbps
- Length: 1-5 seconds (keep them short)
- Volume: Normalized to prevent clipping