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
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["RenownSoundSelect"])
    local volumeLevel = self.db.profile["RenownVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[5])
end

function BLU:HandlePerksActivityCompleted()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED")
    local sound = SelectSound(self.db.profile["PostSoundSelect"])
    local volumeLevel = self.db.profile["PostVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[9])
end

function BLU:HandlePetBattleLevelChanged()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    local volumeLevel = self.db.profile["BattlePetLevelVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[2])
end

function BLU:HandleAchievementEarned()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("ACHIEVEMENT_EARNED")
    local sound = SelectSound(self.db.profile["AchievementSoundSelect"])
    local volumeLevel = self.db.profile["AchievementVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[1])
end

function BLU:HandleHonorLevelUpdate()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("HONOR_LEVEL_UPDATE")
    local sound = SelectSound(self.db.profile["HonorSoundSelect"])
    local volumeLevel = self.db.profile["HonorVolume"]
    PlaySelectedSound(sound, volumeLevel, defaultSounds[3])
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
