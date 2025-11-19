--=====================================================================================
-- BLU - sharedmedia.lua
-- Integration with LibSharedMedia and external sound pack addons
--=====================================================================================

local addonName, _ = ...
local BLU = _G["BLU"]

-- Create SharedMedia module
local SharedMedia = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["sharedmedia"] = SharedMedia

-- Storage for external sounds
SharedMedia.externalSounds = {}
SharedMedia.soundCategories = {}

-- Improved addon name extraction function
local function ExtractAddonNameFromPath(path)
    if not path or type(path) ~= "string" then return "SharedMedia" end

    -- Pattern to match Interface/Addons/ or Interface/AddOns/
    -- and capture the addon folder name
    local _, _, addonFolder = string.find(path, "Interface\\Add[oO]ns\\([^\]+")
    
    if addonFolder then
        BLU:PrintDebug(string.format("Extracted addon folder: '%s' from path: '%s'", addonFolder, path))
        return addonFolder
    end
    return "SharedMedia" -- Fallback
end

-- Initialize SharedMedia integration
function SharedMedia:Init()
    BLU:PrintDebug("SharedMedia:Init() called.")
    -- Try to load LibSharedMedia
    self.LSM = LibStub and LibStub("LibSharedMedia-3.0", true) or nil
    BLU:PrintDebug("LSM found: " .. tostring(self.LSM ~= nil))
    
    if not self.LSM then
        BLU:PrintDebug("LibSharedMedia not found - no external sounds will be loaded.")
    else
        BLU:PrintDebug("LibSharedMedia found - scanning for sounds")
        -- Register callbacks
        self.LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
        self.LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
        
        -- Scan existing sounds
        self:ScanExternalSounds()
    end
    
    -- Make functions available
    BLU.GetExternalSounds = function() return self:GetExternalSounds() end
    BLU.GetSoundCategories = function() return self:GetSoundCategories() end
    BLU.PlayExternalSound = function(_, name) return self:PlayExternalSound(name) end
    
    BLU:PrintDebug("SharedMedia integration initialized")
end

-- Scan for external sounds from SharedMedia
function SharedMedia:ScanExternalSounds()
    if not self.LSM then return end
    
    -- Clear existing
    wipe(self.externalSounds)
    wipe(self.soundCategories)
    
    -- Get all registered sounds
    local soundList = self.LSM:List("sound")
    
    BLU:PrintDebug(string.format("SharedMedia:ScanExternalSounds() found %d sounds from LSM.", #soundList))
    for i, soundName in ipairs(soundList) do
        local soundPath = self.LSM:Fetch("sound", soundName)
        if soundPath then
            local packName = ExtractAddonNameFromPath(soundPath)
            
            -- Register with BLU SoundRegistry
            BLU.SoundRegistry:RegisterSound("external:"..soundName, {
                name = soundName,
                file = soundPath,
                category = "all", -- External sounds are available for all categories
                source = "SharedMedia",
                packId = packName,
                packName = packName
            })
        end
    end
end

-- Play external sound
function SharedMedia:PlayExternalSound(name)
    local soundPath = self.LSM:Fetch("sound", name)
    if not soundPath then
        BLU:PrintDebug("External sound not found: " .. name)
        return false
    end
    
    -- Get volume and channel from BLU settings
    local volume = (BLU.db.profile.soundVolume or 100) / 100
    local channel = "Master"
    
    -- Play the sound
    local willPlay, handle = PlaySoundFile(soundPath, channel)
    
    if willPlay then
        BLU:PrintDebug(string.format("Playing external sound: %s", name))
        
        -- Show in chat if enabled
        if BLU.db.profile.debugMode then
            BLU:Print(string.format("|cff00ff00Playing:|r %s (External)", name))
        end
        
        return true
    else
        BLU:PrintError("Failed to play external sound: " .. name)
        return false
    end
end

-- Handle new media registration
function SharedMedia:OnMediaRegistered(event, mediatype, key)
    if mediatype ~= "sound" then return end
    
    BLU:PrintDebug("New sound registered: " .. key)
    
    -- Rescan sounds
    self:ScanExternalSounds()
end

-- Handle global media changes
function SharedMedia:OnMediaSetGlobal(event, mediatype, key)
    if mediatype ~= "sound" then return end
    
    -- Rescan sounds
    self:ScanExternalSounds()
end