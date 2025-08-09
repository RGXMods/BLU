--=====================================================================================
-- BLU | Internal Sounds Module
-- Author: donniedice
-- Description: Manages BLU's built-in sound collection
--=====================================================================================

local addonName, BLU = ...

-- Create the module
local InternalSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["internal_sounds"] = InternalSounds

function InternalSounds:Init()
    BLU:PrintDebug("Internal sounds module initializing...")
    
    -- Register all built-in sound packs
    self:RegisterSoundPacks()
    
    BLU:PrintDebug("Internal sounds module initialized")
end

function InternalSounds:RegisterSoundPacks()
    -- Load all sound pack definitions
    local packFiles = {
        "finalfantasy",
        "zelda", 
        "pokemon",
        "mario",
        "sonic",
        "elderscrolls",
        "witcher",
        "diablo",
        "warcraft",
        "allgames"
    }
    
    for _, packName in ipairs(packFiles) do
        local packPath = "Interface\\AddOns\\BLU\\sound\\packs\\" .. packName .. ".lua"
        BLU:PrintDebug("Registering sound pack: " .. packName)
        
        -- Sound packs will auto-register when loaded via packs.xml
    end
    
    -- Verify sound registry has content
    if BLU.Registry and BLU.Registry.GetAllSounds then
        local sounds = BLU.Registry:GetAllSounds()
        local count = 0
        for _ in pairs(sounds) do
            count = count + 1
        end
        BLU:PrintDebug("Total sounds registered: " .. count)
    end
end

-- Get all internal sounds for a category
function InternalSounds:GetSoundsForCategory(category)
    if not BLU.Registry or not BLU.Registry.GetSoundsByCategory then
        return {}
    end
    
    return BLU.Registry:GetSoundsByCategory(category)
end

-- Test play a sound
function InternalSounds:TestSound(soundId)
    if BLU.Registry and BLU.Registry.PlaySound then
        BLU.Registry:PlaySound(soundId)
        BLU:Print("Playing test sound: " .. (soundId or "none"))
    end
end