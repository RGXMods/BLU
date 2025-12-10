-- =====================================================================================
-- BLU | Better Level-Up! - battlepets.lua
-- =====================================================================================
-- Optimized battle pet level-up detection
-- 
-- CHANGES FROM ORIGINAL:
-- 1. Removed redundant full journal scanning on every BAG_UPDATE_DELAYED
-- 2. Removed redundant full journal scanning on every UNIT_PET_EXPERIENCE
-- 3. Added debouncing to prevent rapid successive checks
-- 4. Tracks only summoned pet instead of entire journal
-- 5. Detects training stone usage via spell cast events
-- 6. Comprehensive item/spell ID list for all training stones
-- 7. Properly ignores login/reload events

-- Wait for BLU to be available (it's created in core.lua which loads before this)
local BLU = BLU
if not BLU then
    local waitFrame = CreateFrame("Frame")
    waitFrame:RegisterEvent("ADDON_LOADED")
    waitFrame:SetScript("OnEvent", function(self, event, addonName)
        if addonName == "BLU" then
            BLU = _G.BLU
            self:UnregisterAllEvents()
        end
    end)
    return
end

BLU_L = BLU_L or {}

-- =====================================================================================
-- Comprehensive Battle Pet Item IDs
-- These are ITEM IDs that can grant pet XP or levels
-- =====================================================================================
local PET_BATTLE_ITEMS = {
    -- =================================================================================
    -- BANDAGES & HEALING
    -- =================================================================================
    [86143] = true,   -- Battle Pet Bandage
    [125439] = true,  -- Battle Pet Bandage (alternate)
    
    -- =================================================================================
    -- PET TREATS (XP Boost)
    -- =================================================================================
    [98112] = true,   -- Lesser Pet Treat (+25% XP for 1 hour)
    [98114] = true,   -- Pet Treat (+50% XP for 1 hour)
    [142409] = true,  -- Pet Treat (alternate ID)
    [142410] = true,  -- Lesser Pet Treat (alternate ID)
    
    -- =================================================================================
    -- PET BISCUITS (Size/Appearance)
    -- =================================================================================
    [71153] = true,   -- Magical Pet Biscuit
    [89906] = true,   -- Magical Mini-Treat
    [168791] = true,  -- Magical Pet Biscuit (alternate)
    [180704] = true,  -- Infused Pet Biscuit
    [163205] = true,  -- Ghostly Pet Biscuit
    
    -- =================================================================================
    -- ULTIMATE BATTLE-TRAINING STONES (Instant Level 25)
    -- =================================================================================
    [122457] = true,  -- Ultimate Battle-Training Stone
    [127755] = true,  -- Fel-Touched Battle-Training Stone (+10000 XP)
    
    -- =================================================================================
    -- FLAWLESS BATTLE-TRAINING STONES (+1 Level, Any Pet Type)
    -- =================================================================================
    [116429] = true,  -- Flawless Battle-Training Stone
    [177161] = true,  -- Flawless Battle-Training Stone (variant)
    [177162] = true,  -- Flawless Battle-Training Stone (variant)
    [177163] = true,  -- Flawless Battle-Training Stone (variant)
    [177164] = true,  -- Flawless Battle-Training Stone (variant)
    [177165] = true,  -- Flawless Battle-Training Stone (variant)
    [177166] = true,  -- Flawless Battle-Training Stone (variant)
    [177167] = true,  -- Flawless Battle-Training Stone (variant)
    [177168] = true,  -- Flawless Battle-Training Stone (variant)
    [177169] = true,  -- Flawless Battle-Training Stone (variant)
    [177170] = true,  -- Flawless Battle-Training Stone (variant)
    
    -- =================================================================================
    -- TYPE-SPECIFIC BATTLE-TRAINING STONES - WoD Era (116xxx series)
    -- =================================================================================
    [116374] = true,  -- Beast Battle-Training Stone
    [116416] = true,  -- Humanoid Battle-Training Stone
    [116417] = true,  -- Mechanical Battle-Training Stone
    [116418] = true,  -- Critter Battle-Training Stone
    [116419] = true,  -- Dragonkin Battle-Training Stone
    [116420] = true,  -- Elemental Battle-Training Stone
    [116421] = true,  -- Flying Battle-Training Stone
    [116422] = true,  -- Magic Battle-Training Stone
    [116423] = true,  -- Undead Battle-Training Stone
    [116424] = true,  -- Aquatic Battle-Training Stone
    
    -- =================================================================================
    -- TYPE-SPECIFIC BATTLE-TRAINING STONES - Legacy (126xxx series)
    -- =================================================================================
    [126988] = true,  -- Humanoid Battle-Training Stone
    [126989] = true,  -- Dragonkin Battle-Training Stone
    [126990] = true,  -- Flying Battle-Training Stone
    [126991] = true,  -- Undead Battle-Training Stone
    [126992] = true,  -- Critter Battle-Training Stone
    [126993] = true,  -- Magic Battle-Training Stone
    [126994] = true,  -- Elemental Battle-Training Stone
    [126995] = true,  -- Beast Battle-Training Stone
    [126996] = true,  -- Aquatic Battle-Training Stone
    [126997] = true,  -- Mechanical Battle-Training Stone
    
    -- =================================================================================
    -- TYPE-SPECIFIC BATTLE-TRAINING STONES - Family Variants (173xxx series)
    -- =================================================================================
    [173266] = true,  -- Humanoid Battle-Training Stone (Family)
    [173267] = true,  -- Dragonkin Battle-Training Stone (Family)
    [173268] = true,  -- Flying Battle-Training Stone (Family)
    [173269] = true,  -- Undead Battle-Training Stone (Family)
    [173270] = true,  -- Critter Battle-Training Stone (Family)
    [173271] = true,  -- Magic Battle-Training Stone (Family)
    [173272] = true,  -- Elemental Battle-Training Stone (Family)
    [173273] = true,  -- Beast Battle-Training Stone (Family)
    [173274] = true,  -- Aquatic Battle-Training Stone (Family)
    [173275] = true,  -- Mechanical Battle-Training Stone (Family)
    
    -- =================================================================================
    -- BATTLE-STONES (Quality Upgrade to Rare)
    -- =================================================================================
    [92741] = true,   -- Flawless Battle-Stone
    [98715] = true,   -- Marked Flawless Battle-Stone
    [113193] = true,  -- Mythical Battle-Pet Stone
    
    -- =================================================================================
    -- SPECIAL ITEMS
    -- =================================================================================
    [366246] = true,  -- Purewater Pet Fish
    [340027] = true,  -- Pouch of Razor Sharp Teeth
}

-- =====================================================================================
-- Battle Pet Spell IDs (fired on UNIT_SPELLCAST_SUCCEEDED when items are used)
-- =====================================================================================
local PET_BATTLE_SPELLS = {
    -- Ultimate Battle-Training Stone (instant level 25)
    [181062] = true,
    
    -- Flawless Battle-Training Stone (+1 level)
    [165851] = true,
    
    -- Type-specific training stone spells (+1 level / +2000 XP)
    [162984] = true,  -- Beast
    [162985] = true,  -- Critter
    [162986] = true,  -- Dragonkin
    [162987] = true,  -- Elemental
    [162988] = true,  -- Flying
    [162989] = true,  -- Magic
    [162990] = true,  -- Mechanical
    [162991] = true,  -- Undead
    [162992] = true,  -- Humanoid
    [162993] = true,  -- Aquatic
    
    -- Fel-Touched Battle-Training Stone (+10000 XP)
    [187567] = true,
    
    -- Pet Treats (XP boost)
    [174003] = true,  -- Lesser Pet Treat
    [174005] = true,  -- Pet Treat
    
    -- Battle-Stone (quality upgrade)
    [134644] = true,  -- Flawless Battle-Stone
}

-- =====================================================================================
-- Local State (module-scoped)
-- =====================================================================================
local summonedPetLevel = nil
local summonedPetGUID = nil
local lastSoundTime = 0
local pendingCheck = false
local initialized = false
local initialLoadComplete = false  -- Prevents false triggers on login/reload

local SOUND_COOLDOWN = 2           -- Seconds between sounds
local CHECK_DELAY = 0.5            -- Delay after item use to check level
local INIT_DELAY = 5               -- Seconds to wait after login before enabling detection

-- =====================================================================================
-- Helper Functions
-- =====================================================================================

-- Check if we can play a sound (cooldown)
local function CanPlaySound()
    if not initialLoadComplete then
        return false
    end
    
    local now = GetTime()
    if now - lastSoundTime < SOUND_COOLDOWN then
        return false
    end
    lastSoundTime = now
    return true
end

-- Get summoned pet info
local function GetSummonedPetInfo()
    if not C_PetJournal or not C_PetJournal.GetSummonedPetGUID then
        return nil, nil
    end
    
    local petGUID = C_PetJournal.GetSummonedPetGUID()
    if not petGUID then
        return nil, nil
    end
    
    local speciesID, _, level = C_PetJournal.GetPetInfoByPetID(petGUID)
    return petGUID, level
end

-- Check if item ID is a pet battle item
local function IsPetBattleItem(itemID)
    return PET_BATTLE_ITEMS[itemID] or false
end

-- Check if spell ID is a pet battle spell
local function IsPetBattleSpell(spellID)
    return PET_BATTLE_SPELLS[spellID] or false
end

-- Update summoned pet tracking (stores current level as baseline)
local function UpdateSummonedPetTracking()
    local guid, level = GetSummonedPetInfo()
    summonedPetGUID = guid
    summonedPetLevel = level
    
    if BLU.debugMode and guid then
        BLU:PrintDebugMessage("Tracking summoned pet: Level " .. tostring(level))
    end
end

-- Check for level-up (after training stone or item use)
local function CheckForLevelUp()
    if not initialLoadComplete then
        pendingCheck = false
        return
    end
    
    if BLU.functionsHalted then
        pendingCheck = false
        return
    end
    
    local guid, newLevel = GetSummonedPetInfo()
    
    if not guid or not newLevel then
        pendingCheck = false
        return
    end
    
    -- Only trigger if we have a previous level AND it increased
    -- This prevents false positives on initial tracking
    if guid == summonedPetGUID and summonedPetLevel and summonedPetLevel > 0 and newLevel > summonedPetLevel then
        BLU:PrintDebugMessage("BATTLE_PET_LEVEL_UP_TRIGGERED")
        
        if CanPlaySound() then
            BLU:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
        end
    end
    
    -- Update tracking
    summonedPetGUID = guid
    summonedPetLevel = newLevel
    pendingCheck = false
end

-- =====================================================================================
-- Event Frame for Pet-Specific Events
-- =====================================================================================
local eventFrame = CreateFrame("Frame")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if not BLU then return end
    
    if event == "PLAYER_LOGIN" then
        -- Initialize tracking after login
        local version = BLU:GetGameVersion()
        if version == "retail" or version == "mists" then
            initialized = true
            
            -- Delay to let the journal populate and avoid false triggers
            C_Timer.After(INIT_DELAY, function()
                UpdateSummonedPetTracking()
                initialLoadComplete = true
                BLU:PrintDebugMessage("INIT_LOAD_COMPLETE")
            end)
        end
        return
    end
    
    -- Ignore all events until initial load is complete
    if not initialLoadComplete then return end
    if BLU.functionsHalted then return end
    
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unitTarget, castGUID, spellID = ...
        
        if unitTarget ~= "player" then return end
        if not IsPetBattleSpell(spellID) then return end
        
        BLU:PrintDebugMessage("Pet training spell detected: " .. tostring(spellID))
        
        -- Schedule a check after the spell effect applies
        pendingCheck = true
        C_Timer.After(CHECK_DELAY, function()
            if pendingCheck then
                CheckForLevelUp()
            end
        end)
        
    elseif event == "PET_BATTLE_LEVEL_CHANGED" then
        -- Direct level-up event (from actual pet battles)
        local petID, newLevel = ...
        
        BLU:PrintDebugMessage("BATTLE_PET_LEVEL_UP_TRIGGERED")
        
        if CanPlaySound() then
            BLU:HandleEvent("PET_BATTLE_LEVEL_CHANGED", "BattlePetLevelSoundSelect", "BattlePetLevelVolume", defaultSounds[2], "BATTLE_PET_LEVEL_UP_TRIGGERED")
        end
        
        -- Update tracking if this was our summoned pet
        if summonedPetGUID and petID == summonedPetGUID then
            summonedPetLevel = newLevel
        end
        
    elseif event == "COMPANION_UPDATE" then
        -- Pet summoned or dismissed - update tracking
        local companionType = ...
        if companionType == "CRITTER" or companionType == nil then
            C_Timer.After(0.1, UpdateSummonedPetTracking)
        end
        
    elseif event == "PET_JOURNAL_LIST_UPDATE" then
        -- Only check if we're expecting a change from an item use
        if pendingCheck then
            C_Timer.After(0.1, function()
                if pendingCheck then
                    CheckForLevelUp()
                end
            end)
        end
    end
end)

-- Register events (version check happens in PLAYER_LOGIN)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
eventFrame:RegisterEvent("COMPANION_UPDATE")
eventFrame:RegisterEvent("PET_JOURNAL_LIST_UPDATE")

-- =====================================================================================
-- Public Functions (can be called from core.lua if needed)
-- =====================================================================================

function BLU:InitializePetLevelCache()
    local version = self:GetGameVersion()
    if version ~= "retail" and version ~= "mists" then
        return
    end
    
    initialized = true
    C_Timer.After(INIT_DELAY, function()
        UpdateSummonedPetTracking()
        initialLoadComplete = true
        self:PrintDebugMessage("INIT_LOAD_COMPLETE")
    end)
end

function BLU:CleanupPetTracking()
    summonedPetGUID = nil
    summonedPetLevel = nil
    pendingCheck = false
    initialized = false
    initialLoadComplete = false
end

-- Expose check functions for external use
function BLU:IsPetBattleItem(itemID)
    return IsPetBattleItem(itemID)
end

function BLU:IsPetBattleSpell(spellID)
    return IsPetBattleSpell(spellID)
end

-- =====================================================================================
-- Expose item/spell tables for debugging or external access
-- =====================================================================================
BLU.PET_BATTLE_ITEMS = PET_BATTLE_ITEMS
BLU.PET_BATTLE_SPELLS = PET_BATTLE_SPELLS