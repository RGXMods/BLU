--=====================================================================================
-- BLU Prey Module
-- Placeholder module reserved for future prey/hunt-system sound support
-- (target-tracking, hunt-style progression events)
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local PreyModule = {}

function PreyModule:Init()
    BLU:PrintDebug("[Prey] Prey placeholder module initialized")
end

BLU.Modules = BLU.Modules or {}
BLU.Modules["prey"] = PreyModule

if BLU.RegisterModule then
    BLU:RegisterModule(PreyModule, "prey", "Prey Module")
end

return PreyModule
