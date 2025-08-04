# SharedMedia Compatibility Guide

## Overview

BLU supports integration with LibSharedMedia-3.0 (LSM) addons to automatically import sounds from popular SoundPak addons like:
- SharedMedia_Ayarei
- SharedMedia_Arey  
- ShadowPriest SoundPack
- Any other LSM-compatible sound addon

## How It Works

### 1. LibStub Detection (Optional Dependency)
```lua
-- BLU detects LibStub without requiring it as a dependency
local LibStub = _G.LibStub  -- Global LibStub if available
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true) or nil
```

### 2. Sound Registration Flow

When a SharedMedia addon registers sounds:
```lua
-- Example from SharedMedia addon:
LSM:Register("sound", "MySound", [[Interface\AddOns\MyAddon\sounds\mysound.ogg]])
```

BLU automatically:
1. Detects the new registration via LSM callbacks
2. Creates a BLU-compatible sound entry
3. Makes it available in the sound selection dropdowns

### 3. SoundPak Bridge Module

The `sound/soundpak.lua` module handles:
- LSM callback registration
- Sound discovery and importing
- Mapping between LSM names and BLU sound IDs
- Category detection based on sound names

## Implementation Details

### Sound ID Mapping
```lua
-- LSM sound name: "Arey - Level Up"
-- BLU sound ID: "soundpak_arey_level_up"
-- Display name: "SoundPak - Arey - Level Up"
```

### Category Detection
BLU attempts to categorize imported sounds based on keywords:
- "level", "ding", "levelup" → levelup
- "achieve", "complete", "success" → achievement  
- "quest", "accept", "turnin" → quest
- "reputation", "rep", "standing" → reputation
- etc.

### Volume and Channel Support
Imported sounds respect BLU's volume and channel settings:
- Master volume control (0-100%)
- Channel selection (Master, Sound, Music, Ambience)

## Adding SharedMedia Support to BLU

### Step 1: Enable LibStub Detection
Already implemented in `sound/soundpak.lua`:
```lua
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true) or nil
```

### Step 2: Register for Callbacks
```lua
if LSM then
    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
    LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
end
```

### Step 3: Import Existing Sounds
```lua
function SoundPakBridge:ScanExistingSounds()
    if not LSM then return end
    
    local soundList = LSM:List("sound")
    for _, soundName in ipairs(soundList) do
        local soundPath = LSM:Fetch("sound", soundName)
        if soundPath then
            self:RegisterExternalSound(soundName, soundPath)
        end
    end
end
```

## User Experience

### For Players
1. Install any SharedMedia sound addon
2. BLU automatically detects available sounds
3. Select imported sounds in BLU's options panel
4. Sounds appear with "SoundPak - " prefix

### For Developers
1. No code changes needed in SharedMedia addons
2. BLU handles all integration automatically
3. Sounds are available to all BLU features

## Troubleshooting

### Sounds Not Appearing
1. Ensure SharedMedia addon is loaded before BLU
2. Check if LibStub is available: `/run print(LibStub and "Found" or "Not Found")`
3. Use `/blutest` to check imported sounds

### Performance Considerations
- Sound scanning happens once at startup
- Minimal overhead for LSM integration
- No impact if LSM not present

## Future Enhancements

1. **Smart Categorization**: ML-based sound categorization
2. **Preview Integration**: Preview LSM sounds in BLU browser
3. **Favorites System**: Mark frequently used LSM sounds
4. **Export to WeakAuras**: Share BLU sound selections