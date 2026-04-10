--=====================================================================================
-- BLU Collectibles Module
-- Placeholder module reserved for future collectible milestone sound support
-- (mounts, pets, toys, transmog, and similar acquisition events)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local CollectiblesModule = {}

function CollectiblesModule:Init()
    BLU:PrintDebug("[Collectibles] Collectibles placeholder module initialized")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["collectibles"] = CollectiblesModule

if BLU.RegisterModule then
    BLU:RegisterModule(CollectiblesModule, "collectibles", "Collectibles Module")
end

return CollectiblesModule
