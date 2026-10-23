--=====================================================================================
-- BLU Collectibles Module
-- Plays category sounds when a mount, pet, toy, or transmog appearance is acquired.
-- Sounds are selected per category (mount/pet/toy/transmog) in the options panel.
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local CollectiblesModule = {}

local PER_TRIGGER_COOLDOWN = 1.0   -- seconds between same collectible type fires

local EVENT_ID_MOUNT = "collectibles_mount_added"
local EVENT_ID_PET = "collectibles_pet_added"
local EVENT_ID_TOY = "collectibles_toy_added"
local EVENT_ID_TRANSMOG = "collectibles_transmog_source_added"
local EVENT_ID_TRANSMOG_COSMETIC = "collectibles_transmog_cosmetic_source_added"

CollectiblesModule.lastSoundAt = {}

local function IsEnabled()
    if not BLU.db or BLU.db.enabled == false then return false end
    if BLU.db.modules and BLU.db.modules.collectibles == false then return false end
    return true
end

function CollectiblesModule:PlayCategoryTrigger(category)
    if not IsEnabled() then return false end

    local now = GetTime and GetTime() or 0
    local last = self.lastSoundAt[category] or 0
    if (now - last) < PER_TRIGGER_COOLDOWN then return false end
    self.lastSoundAt[category] = now

    BLU:PlayCategorySound(category)
    if BLU.db and BLU.db.debugMode then
        BLU:Print(BLU:Loc("DEBUG_COLLECTIBLE_ACQUIRED", category))
    end
    return true
end

function CollectiblesModule:OnMountAdded(event, mountID)
    return self:PlayCategoryTrigger("mount")
end

function CollectiblesModule:OnPetAdded(event, petID)
    return self:PlayCategoryTrigger("pet")
end

function CollectiblesModule:OnToyAdded(event, toyID)
    return self:PlayCategoryTrigger("toy")
end

function CollectiblesModule:OnTransmogSourceAdded(event, itemModifiedAppearanceID)
    return self:PlayCategoryTrigger("transmog")
end

function CollectiblesModule:Init()
    BLU:RegisterEvent("NEW_MOUNT_ADDED", function(...) self:OnMountAdded(...) end, EVENT_ID_MOUNT)
    BLU:RegisterEvent("NEW_PET_ADDED", function(...) self:OnPetAdded(...) end, EVENT_ID_PET)
    BLU:RegisterEvent("NEW_TOY_ADDED", function(...) self:OnToyAdded(...) end, EVENT_ID_TOY)
    BLU:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", function(...) self:OnTransmogSourceAdded(...) end, EVENT_ID_TRANSMOG)
    BLU:RegisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", function(...) self:OnTransmogSourceAdded(...) end, EVENT_ID_TRANSMOG_COSMETIC)

    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "Collectibles"))
end

function CollectiblesModule:Cleanup()
    BLU:UnregisterEvent("NEW_MOUNT_ADDED", EVENT_ID_MOUNT)
    BLU:UnregisterEvent("NEW_PET_ADDED", EVENT_ID_PET)
    BLU:UnregisterEvent("NEW_TOY_ADDED", EVENT_ID_TOY)
    BLU:UnregisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED", EVENT_ID_TRANSMOG)
    BLU:UnregisterEvent("TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED", EVENT_ID_TRANSMOG_COSMETIC)

    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "Collectibles"))
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["collectibles"] = CollectiblesModule

if BLU.RegisterModule then
    BLU:RegisterModule(CollectiblesModule, "collectibles", "Collectibles Module")
end

return CollectiblesModule
