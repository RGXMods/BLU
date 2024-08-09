--=====================================================================================
-- Event Registration
--=====================================================================================
function BLU:OnEnable()
    self:PrintDebugMessage("ENABLING_ADDON")
    self:RegisterSharedEvents()
    self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "HandleRenownLevelChanged")
    self:RegisterEvent("PERKS_ACTIVITY_COMPLETED", "HandlePerksActivityCompleted")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED", "HandlePetBattleLevelChanged")
    self:RegisterEvent("ACHIEVEMENT_EARNED", "HandleAchievementEarned")
    self:RegisterEvent("HONOR_LEVEL_UPDATE", "HandleHonorLevelUpdate")
end

--=====================================================================================
-- Event Handlers for Retail-specific Events
--=====================================================================================
function BLU:HandleRenownLevelChanged()
    if functionsHalted then return end
    self:PlaySelectedSound("MAJOR_FACTION_RENOWN_LEVEL_CHANGED", "RenownSoundSelect", "RenownVolume")
end

function BLU:HandlePerksActivityCompleted()
    if functionsHalted then return end
    self:PlaySelectedSound("PERKS_ACTIVITY_COMPLETED", "PostSoundSelect", "PostVolume")
end

function BLU:HandlePetBattleLevelChanged()
    if functionsHalted then return end
    self:PlaySelectedSound("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume")
end

function BLU:HandleAchievementEarned()
    if functionsHalted then return end
    self:PlaySelectedSound("ACHIEVEMENT_EARNED", "AchievementSoundSelect", "AchievementVolume")
end

function BLU:HandleHonorLevelUpdate()
    if functionsHalted then return end
    self:PlaySelectedSound("HONOR_LEVEL_UPDATE", "HonorSoundSelect", "HonorVolume")
end

--=====================================================================================
-- Retail-specific Mute Sounds Function
--=====================================================================================
function BLU:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        self:PrintDebugMessage("MUTE_SOUND", soundID)
        MuteSoundFile(soundID)
    end
end
