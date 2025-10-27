-- modules/battlepets.lua
local addonName = ...
local BLU = _G["BLU"]

function battlepets:OnEnable()
    self.addon:Print("Battle Pets module enabled!")
    self.addon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "HandleBattlePetLevelUp")
    self.addon:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", "HandleBattlePetLevelUp")
    self.addon:RegisterEvent("UNIT_PET_EXPERIENCE", "HandleBattlePetLevelUp")
    self.addon:RegisterEvent("PET_JOURNAL_LIST_UPDATE", "HandleBattlePetLevelUp")
end

function battlepets:HandleBattlePetLevelUp()
    self.addon:HandleEvent("BATTLE_PET_LEVEL_UP", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
end

BLULib = BLULib or {}
BLULib.BattlePetsModule = battlepets