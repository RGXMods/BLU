--=====================================================================================
-- BLU Loot Module
-- Placeholder module reserved for future loot event sound support
-- (rare drops, boss loot, item acquisition events)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local LootModule = {}

function LootModule:Init()
    BLU:PrintDebug("[Loot] Loot placeholder module initialized")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["loot"] = LootModule

if BLU.RegisterModule then
    BLU:RegisterModule(LootModule, "loot", "Loot Module")
end

return LootModule
