--=====================================================================================
-- BLU | Better Level Up! - retail.lua
--=====================================================================================

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
    self:RegisterEvent("UPDATE_FACTION", "HandleUpdateFaction")
end

--=====================================================================================
-- Event Handlers for Retail-specific Events
--=====================================================================================
function BLU:HandleUpdateFaction()
    self:DelveLevelUpChatFrameHook()
end

function BLU:HandleRenownLevelChanged()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["RenownSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["RenownVolume"], defaultSounds[5])
end

function BLU:HandlePerksActivityCompleted()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PERKS_ACTIVITY_COMPLETED")
    local sound = SelectSound(self.db.profile["PostSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["PostVolume"], defaultSounds[9])
end

function BLU:HandlePetBattleLevelChanged()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("PET_BATTLE_LEVEL_CHANGED")
    local sound = SelectSound(self.db.profile["BattlePetLevelSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["BattlePetLevelVolume"], defaultSounds[2])
end

function BLU:HandleAchievementEarned()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("ACHIEVEMENT_EARNED")
    local sound = SelectSound(self.db.profile["AchievementSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["AchievementVolume"], defaultSounds[1])
end

function BLU:HandleHonorLevelUpdate()
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("HONOR_LEVEL_UPDATE")
    local sound = SelectSound(self.db.profile["HonorSoundSelect"])
    PlaySelectedSound(sound, self.db.profile["HonorVolume"], defaultSounds[3])
end

--=====================================================================================
-- ChatFrame Hooks for Delve Level-Up Detection
--=====================================================================================
function BLU:DelveLevelUpChatFrameHook()
    if delveChatFrameHooked then return end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", function(_, _, msg)
        self:PrintDebugMessage("Incoming chat message: " .. msg)
        local level = string.match(msg, "Brann Bronzebeard has reached Level (%d+)%p?")
        if level then
            self:PrintDebugMessage("Brann Bronzebeard has reached Level " .. level)
            self:DelveLevelUpDetected(level)
        else
            self:PrintDebugMessage("No Delve Level found in chat message.")
        end
        return false
    end)

    delveChatFrameHooked = true
end

--=====================================================================================
-- Handle Delve Level-Up Detection
--=====================================================================================
function BLU:DelveLevelUpDetected(level)
    if functionsHalted then 
        self:PrintDebugMessage("FUNCTIONS_HALTED")
        return 
    end
    self:PrintDebugMessage("DELVE_LEVEL_UP_DETECTED", level)
    local sound = SelectSound(self.db.profile.DelveLevelUpSoundSelect)
    if not sound then
        self:PrintDebugMessage("ERROR_SOUND_NOT_FOUND")
        return
    end
    PlaySelectedSound(sound, self.db.profile.DelveLevelUpVolume, defaultSounds[6])
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
