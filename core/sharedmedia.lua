--=====================================================================================
-- BLU - sharedmedia.lua
-- Integration with LibSharedMedia and generic external sound pack bridging
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
SharedMedia.manualBridgePaths = {}
SharedMedia.callbacksRegistered = false
SharedMedia.eventsRegistered = false
SharedMedia.pendingRescan = false
SharedMedia.kittyHookInstalled = false
SharedMedia._invokedDBMPackFunctions = {}
SharedMedia.enableGenericFallbackScan = false

local SHARED_MEDIA_ADDON_EVENT_ID = "sharedmedia_addon_loaded"
local SHARED_MEDIA_LOGIN_EVENT_ID = "sharedmedia_player_login"
local MAX_BRIDGED_SOUNDS_PER_SCAN = 3000
local MAX_TABLES_PER_SOURCE_SCAN = 1500
local MAX_SCAN_DEPTH = 8
local IGNORED_GLOBALS = {
    ["_G"] = true,
    ["BLU"] = true,
    ["math"] = true,
    ["string"] = true,
    ["table"] = true,
    ["coroutine"] = true,
    ["debug"] = true,
    ["bit"] = true,
    ["bit32"] = true,
    ["utf8"] = true,
    ["io"] = true,
    ["os"] = true,
    ["package"] = true,
}

local function SortCaseInsensitive(a, b)
    return string.lower(a) < string.lower(b)
end

local function SafeUnpack(values)
    if unpack then
        return unpack(values)
    end

    return table.unpack(values)
end

local function ForEachTableEntrySafe(tbl, callback)
    if type(tbl) ~= "table" then
        return false
    end

    local key = nil
    while true do
        local ok, nextKey, nextValue = pcall(next, tbl, key)
        if not ok then
            return false
        end

        if nextKey == nil then
            return true
        end

        local continue = callback(nextKey, nextValue)
        if continue == false then
            return true
        end

        key = nextKey
    end
end

local function NormalizePath(path)
    if type(path) ~= "string" then
        return nil
    end

    local ok, normalized = pcall(string.gsub, path, "/", "\\")
    if not ok or type(normalized) ~= "string" then
        return nil
    end

    return normalized
end

local function IsAudioPath(path)
    local normalized = NormalizePath(path)
    if not normalized then
        return false
    end

    local lower = string.lower(normalized)
    if not string.find(lower, "interface\\addons\\", 1, true) then
        return false
    end

    return string.match(lower, "%.ogg$")
        or string.match(lower, "%.mp3$")
        or string.match(lower, "%.wav$")
end

local function ExtractAddonNameFromPath(path)
    local normalized = NormalizePath(path)
    if not normalized then
        return "SharedMedia"
    end

    local addonFolder = string.match(normalized, "[Ii]nterface\\[Aa]dd[oO]ns\\([^\\]+)")
    if addonFolder and addonFolder ~= "" then
        return addonFolder
    end

    return "SharedMedia"
end

local function BuildBridgeDisplayName(addonFolder, normalizedPath)
    local fileName = string.match(normalizedPath, "([^\\]+)%.[^%.]+$") or normalizedPath
    local parentFolder = string.match(normalizedPath, "\\([^\\]+)\\[^\\]+%.[^%.]+$")

    if parentFolder and parentFolder ~= "" and parentFolder ~= addonFolder then
        return string.format("%s - %s/%s", addonFolder, parentFolder, fileName)
    end

    return string.format("%s - %s", addonFolder, fileName)
end

local function HashString(input)
    local hash = 5381
    for i = 1, #input do
        hash = (hash * 33 + string.byte(input, i)) % 4294967295
    end
    return hash
end

local function ShouldIgnoreGlobal(name)
    if type(name) ~= "string" then
        return true
    end

    if IGNORED_GLOBALS[name] then
        return true
    end

    if string.match(name, "^C_%u")
        or string.match(name, "^Enum")
        or string.match(name, "^LE_")
        or string.match(name, "^SLASH_")
        or string.match(name, "^BINDING_")
        or string.match(name, "^CHAT_")
        or string.match(name, "^ERR_")
        or string.match(name, "^ITEM_") then
        return true
    end

    return false
end

local function IsLikelySoundContainerName(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    local lower = string.lower(name)
    return string.find(lower, "sound", 1, true)
        or string.find(lower, "media", 1, true)
        or string.find(lower, "pack", 1, true)
        or string.find(lower, "audio", 1, true)
        or string.find(lower, "voice", 1, true)
        or string.find(lower, "music", 1, true)
        or string.find(lower, "kitty", 1, true)
        or string.find(lower, "dbm", 1, true)
end

local function IsLikelyMediaProviderName(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    local lower = string.lower(name)
    return string.find(lower, "sharedmedia", 1, true)
        or string.find(lower, "sound", 1, true)
        or string.find(lower, "audio", 1, true)
        or string.find(lower, "voice", 1, true)
        or string.find(lower, "music", 1, true)
        or string.find(lower, "kitty", 1, true)
        or string.find(lower, "dbm", 1, true)
        or string.find(lower, "media", 1, true)
        or string.find(lower, "pack", 1, true)
end

local function AddAddonGlobalCandidate(candidateSet, candidateName)
    if type(candidateName) ~= "string" or candidateName == "" then
        return
    end

    candidateSet[candidateName] = true
    candidateSet[string.gsub(candidateName, "%-", "_")] = true
    candidateSet[string.gsub(candidateName, "[^%w_]", "_")] = true
end

local function GetAddonGlobalCandidates()
    local candidateSet = {}

    if C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetAddOnInfo then
        for i = 1, C_AddOns.GetNumAddOns() do
            local info = C_AddOns.GetAddOnInfo(i)
            if type(info) == "table" then
                AddAddonGlobalCandidate(candidateSet, info.name)
            elseif type(info) == "string" then
                AddAddonGlobalCandidate(candidateSet, info)
            end
        end
    elseif GetNumAddOns and GetAddOnInfo then
        for i = 1, GetNumAddOns() do
            local name = GetAddOnInfo(i)
            AddAddonGlobalCandidate(candidateSet, name)
        end
    end

    local candidates = {}
    for name in pairs(candidateSet) do
        local value = _G[name]
        if type(value) == "table" then
            table.insert(candidates, value)
        end
    end

    return candidates
end

local function GetAddOnCount()
    if C_AddOns and C_AddOns.GetNumAddOns then
        return C_AddOns.GetNumAddOns()
    end

    if GetNumAddOns then
        return GetNumAddOns()
    end

    return 0
end

local function GetAddOnMetadataValue(index, key)
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local ok, value = pcall(C_AddOns.GetAddOnMetadata, index, key)
        if ok then
            return value
        end
    elseif GetAddOnMetadata then
        local ok, value = pcall(GetAddOnMetadata, index, key)
        if ok then
            return value
        end
    end

    return nil
end

function SharedMedia:TryBindLSM()
    BLU:PrintDebug("[SharedMedia] TryBindLSM called")
    if self.LSM then
        BLU:PrintDebug("[SharedMedia] LSM already bound")
        return true
    end

    local libStub = _G.LibStub
    if not libStub then
        return false
    end

    local ok, lsm = pcall(function()
        return libStub("LibSharedMedia-3.0", true)
    end)

    if not ok or not lsm then
        return false
    end

    self.LSM = lsm

    if not self.callbacksRegistered then
        self.LSM.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaRegistered")
        self.LSM.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaSetGlobal")
        self.callbacksRegistered = true
    end

    BLU:PrintDebug("LibSharedMedia found and callbacks registered.")
    return true
end

function SharedMedia:ClearExternalFromRegistry()
    BLU:PrintDebug("[SharedMedia] ClearExternalFromRegistry called")
    if not BLU.SoundRegistry or not BLU.SoundRegistry.GetAllSounds or not BLU.SoundRegistry.UnregisterSound then
        return
    end

    local removeIds = {}
    for soundId, soundData in pairs(BLU.SoundRegistry:GetAllSounds()) do
        if soundData and soundData.source == "SharedMedia" then
            table.insert(removeIds, soundId)
        end
    end

    for _, soundId in ipairs(removeIds) do
        BLU.SoundRegistry:UnregisterSound(soundId)
    end
end

function SharedMedia:QueueRescan(delaySeconds)
    BLU:PrintDebug("[SharedMedia] QueueRescan called with delay " .. tostring(delaySeconds or 0))
    if self.pendingRescan then
        BLU:PrintDebug("[SharedMedia] Rescan already pending")
        return
    end

    self.pendingRescan = true

    local function runRescan()
        self.pendingRescan = false

        local ok, err = pcall(function()
            self:ScanExternalSounds()
        end)

        if not ok then
            BLU:PrintError("SharedMedia rescan failed: " .. tostring(err))
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(delaySeconds or 0, runRescan)
    else
        runRescan()
    end
end

function SharedMedia:NotifyExternalSoundsUpdated()
    BLU:PrintDebug("[SharedMedia] NotifyExternalSoundsUpdated called")
    if BLU.SoundRegistry then
        BLU.SoundRegistry.uiSoundCache = {}
    end

    if type(BLU.RefreshSoundPackUI) == "function" then
        local ok, err = pcall(BLU.RefreshSoundPackUI)
        if not ok then
            BLU:PrintDebug("Failed to refresh Sounds panel after media update: " .. tostring(err))
        end
    end
end

function SharedMedia:RegisterBridgePath(path, preferredPackName)
    BLU:PrintDebug("[SharedMedia] RegisterBridgePath called for '" .. tostring(path) .. "'")
    if not IsAudioPath(path) then
        return false
    end

    local normalizedPath = NormalizePath(path)
    local lowerPath = string.lower(normalizedPath)

    if string.find(lowerPath, "interface\\addons\\blu\\", 1, true) then
        return false
    end

    self._registeredBridgePaths = self._registeredBridgePaths or {}
    if self._registeredBridgePaths[lowerPath] then
        return false
    end

    local packName = preferredPackName or ExtractAddonNameFromPath(normalizedPath)
    local lowerPack = string.lower(packName or "")
    if lowerPack == "sharedmedia" or lowerPack == "blizzard" then
        return false
    end

    self._lsmPathSet = self._lsmPathSet or {}
    if self._lsmPathSet[lowerPath] then
        return false
    end

    local displayName = BuildBridgeDisplayName(packName, normalizedPath)
    local soundId = string.format("bridge:%s:%08x", string.gsub(lowerPack, "[^%w]", "_"), HashString(lowerPath))

    if BLU.SoundRegistry and BLU.SoundRegistry.RegisterSound then
        BLU.SoundRegistry:RegisterSound(soundId, {
            name = displayName,
            file = normalizedPath,
            category = "all",
            source = "SharedMedia",
            packId = packName,
            packName = packName,
            isBridge = true,
        })
    end

    self.externalSounds[soundId] = {
        name = displayName,
        file = normalizedPath,
        packId = packName,
        packName = packName,
        isBridge = true,
    }

    self._registeredBridgePaths[lowerPath] = true
    BLU:PrintDebug("[SharedMedia] Registered bridge sound '" .. tostring(soundId) .. "' from pack '" .. tostring(packName) .. "'")
    return true
end

local function CollectPathsFromValue(value, foundPaths, visitedTables, scanState, depth)
    if scanState.totalFound >= MAX_BRIDGED_SOUNDS_PER_SCAN then
        return
    end

    local valueType = type(value)

    if valueType == "string" then
        if IsAudioPath(value) then
            local normalizedPath = NormalizePath(value)
            local lowerPath = string.lower(normalizedPath)
            if not foundPaths[lowerPath] then
                foundPaths[lowerPath] = normalizedPath
                scanState.totalFound = scanState.totalFound + 1
            end
        end
        return
    end

    if valueType ~= "table" then
        return
    end

    if depth > MAX_SCAN_DEPTH then
        return
    end

    if visitedTables[value] then
        return
    end

    if scanState.sourceTableCount >= MAX_TABLES_PER_SOURCE_SCAN then
        return
    end

    visitedTables[value] = true
    scanState.sourceTableCount = scanState.sourceTableCount + 1

    local iterated = ForEachTableEntrySafe(value, function(key, nestedValue)
        if type(key) == "string" and IsAudioPath(key) then
            local normalizedPath = NormalizePath(key)
            local lowerPath = string.lower(normalizedPath)
            if not foundPaths[lowerPath] then
                foundPaths[lowerPath] = normalizedPath
                scanState.totalFound = scanState.totalFound + 1
            end
        end

        CollectPathsFromValue(nestedValue, foundPaths, visitedTables, scanState, depth + 1)

        if scanState.totalFound >= MAX_BRIDGED_SOUNDS_PER_SCAN then
            return false
        end
    end)

    if not iterated then
        scanState.forbiddenTables = (scanState.forbiddenTables or 0) + 1
    end
end

function SharedMedia:ScanGenericBridgeSources()
    BLU:PrintDebug("[SharedMedia] ScanGenericBridgeSources called")
    local foundPaths = {}
    local scanState = { totalFound = 0, sourceTableCount = 0 }

    -- Scan known pack-returning global APIs if available.
    if type(_G.KittyGetSoundPacks) == "function" then
        local ok, kittyPacks = pcall(_G.KittyGetSoundPacks)
        if ok and type(kittyPacks) == "table" then
            scanState.sourceTableCount = 0
            CollectPathsFromValue(kittyPacks, foundPaths, {}, scanState, 0)
        end
    end

    -- Scan DBM-specific registries when present.
    if type(_G.DBM) == "table" then
        local dbm = _G.DBM
        local dbmLists = {"Victory", "Defeat", "Music", "DungeonMusic", "BattleMusic"}
        for _, listName in ipairs(dbmLists) do
            if type(dbm[listName]) == "table" then
                scanState.sourceTableCount = 0
                CollectPathsFromValue(dbm[listName], foundPaths, {}, scanState, 0)
            end

            if scanState.totalFound >= MAX_BRIDGED_SOUNDS_PER_SCAN then
                break
            end
        end
    end

    -- Conservative fallback: only scan globals whose names strongly suggest
    -- they are media/sound pack containers. Broad _G crawling can hit WoW's
    -- script execution limit on large addon stacks, so keep this disabled
    -- for normal startup unless explicitly enabled.
    if self.enableGenericFallbackScan and scanState.totalFound < MAX_BRIDGED_SOUNDS_PER_SCAN then
        ForEachTableEntrySafe(_G, function(globalName, globalValue)
            if not ShouldIgnoreGlobal(globalName)
                and IsLikelySoundContainerName(globalName)
                and type(globalValue) == "table" then
                scanState.sourceTableCount = 0
                CollectPathsFromValue(globalValue, foundPaths, {}, scanState, 0)

                if scanState.totalFound >= MAX_BRIDGED_SOUNDS_PER_SCAN then
                    return false
                end
            end
        end)
    end

    local registeredBridgeCount = 0
    for _, normalizedPath in pairs(foundPaths) do
        if self:RegisterBridgePath(normalizedPath) then
            registeredBridgeCount = registeredBridgeCount + 1
        end
    end

    return registeredBridgeCount
end

function SharedMedia:ApplyManualBridgePaths()
    BLU:PrintDebug("[SharedMedia] ApplyManualBridgePaths called")
    local registered = 0

    for _, entry in pairs(self.manualBridgePaths) do
        if type(entry) == "table" and type(entry.path) == "string" then
            if self:RegisterBridgePath(entry.path, entry.packName) then
                registered = registered + 1
            end
        end
    end

    return registered
end

function SharedMedia:RegisterExternalSoundEntries(packName, soundEntries, persistManual)
    BLU:PrintDebug("[SharedMedia] RegisterExternalSoundEntries called for pack '" .. tostring(packName) .. "'")
    if type(soundEntries) ~= "table" then
        return 0
    end

    local registered = 0

    ForEachTableEntrySafe(soundEntries, function(key, value)
        local candidatePath = nil

        if type(value) == "string" then
            candidatePath = value
        elseif type(value) == "table" then
            candidatePath = value.path or value.file or value.sound
        elseif type(key) == "string" and type(value) == "boolean" and value then
            candidatePath = key
        end

        if type(candidatePath) == "string" and IsAudioPath(candidatePath) then
            local normalizedPath = NormalizePath(candidatePath)
            if normalizedPath then
                local lowerPath = string.lower(normalizedPath)
                if persistManual then
                    self.manualBridgePaths[lowerPath] = {
                        path = normalizedPath,
                        packName = packName,
                    }
                end

                if self:RegisterBridgePath(normalizedPath, packName) then
                    registered = registered + 1
                end
            end
        end
    end)

    return registered
end

function SharedMedia:RegisterExternalSoundPack(packName, soundEntries)
    BLU:PrintDebug("[SharedMedia] RegisterExternalSoundPack called for pack '" .. tostring(packName) .. "'")
    return self:RegisterExternalSoundEntries(packName, soundEntries, true)
end

function SharedMedia:EnsureKittyBridgeHook()
    BLU:PrintDebug("[SharedMedia] EnsureKittyBridgeHook called")
    if self.kittyHookInstalled then
        return
    end

    local originalRegister = _G.KittyRegisterSoundPack
    if type(originalRegister) ~= "function" then
        return
    end

    self.kittyHookInstalled = true

    _G.KittyRegisterSoundPack = function(name, options, ...)
        local result = {pcall(originalRegister, name, options, ...)}
        local ok = table.remove(result, 1)
        if not ok then
            error(result[1])
        end

        if type(options) == "table" then
            -- Use addon-folder grouping for pack identity so UI groups by source addon.
            self:RegisterExternalSoundEntries(nil, options, false)
            self:NotifyExternalSoundsUpdated()
        end

        self:QueueRescan(0.05)
        return SafeUnpack(result)
    end

    BLU:PrintDebug("SharedMedia bridge hooked KittyRegisterSoundPack.")
end

function SharedMedia:ScanKittySoundPacks()
    BLU:PrintDebug("[SharedMedia] ScanKittySoundPacks called")
    if type(_G.KittyGetSoundPacks) ~= "function" then
        return 0
    end

    local ok, kittyPacks = pcall(_G.KittyGetSoundPacks)
    if not ok or type(kittyPacks) ~= "table" then
        return 0
    end

    local registered = 0
    ForEachTableEntrySafe(kittyPacks, function(_, packData)
        if type(packData) == "table" then
            -- Group HearKitty sounds by addon folder derived from their file path.
            registered = registered + self:RegisterExternalSoundEntries(nil, packData, false)
        end
    end)

    return registered
end

function SharedMedia:InvokeDBMPackRegistrars()
    BLU:PrintDebug("[SharedMedia] InvokeDBMPackRegistrars called")
    if type(_G.DBM) ~= "table" then
        return 0
    end

    local metadataKeys = {
        "X-DBM-CountPack-GlobalName",
        "X-DBM-VictoryPack-GlobalName",
        "X-DBM-DefeatPack-GlobalName",
        "X-DBM-MusicPack-GlobalName",
    }

    local invoked = 0
    local addonCount = GetAddOnCount()
    for index = 1, addonCount do
        for _, metadataKey in ipairs(metadataKeys) do
            local globalFunctionName = GetAddOnMetadataValue(index, metadataKey)
            if type(globalFunctionName) == "string" and globalFunctionName ~= "" and not self._invokedDBMPackFunctions[globalFunctionName] then
                local insertFunction = _G[globalFunctionName]
                if type(insertFunction) == "function" then
                    local ok = pcall(insertFunction)
                    if ok then
                        self._invokedDBMPackFunctions[globalFunctionName] = true
                        invoked = invoked + 1
                    end
                end
            end
        end
    end

    return invoked
end

function SharedMedia:Init()
    BLU:PrintDebug("SharedMedia:Init() called.")
    self:EnsureKittyBridgeHook()

    if not self.eventsRegistered then
        BLU:RegisterEvent("ADDON_LOADED", function(event, loadedAddonName)
            self:OnAddonLoaded(loadedAddonName)
        end, SHARED_MEDIA_ADDON_EVENT_ID)

        BLU:RegisterEvent("PLAYER_LOGIN", function()
            self:OnPlayerLogin()
        end, SHARED_MEDIA_LOGIN_EVENT_ID)

        self.eventsRegistered = true
    end

    self:ScanExternalSounds()

    BLU.GetExternalSounds = function()
        return self:GetExternalSounds()
    end

    BLU.GetSoundCategories = function()
        return self:GetSoundCategories()
    end

    BLU.PlayExternalSound = function(_, name)
        return self:PlayExternalSound(name)
    end

    BLU.RefreshExternalSounds = function()
        self:QueueRescan(0)
    end

    -- Public bridge API for non-LSM addons.
    BLU.RegisterExternalSoundPack = function(_, packName, soundEntries)
        return self:RegisterExternalSoundPack(packName, soundEntries)
    end

    BLU:PrintDebug("SharedMedia integration initialized")
end

function SharedMedia:ScanExternalSounds()
    BLU:PrintDebug("[SharedMedia] ScanExternalSounds called")
    wipe(self.externalSounds)
    wipe(self.soundCategories)
    self._registeredBridgePaths = {}
    self._lsmPathSet = {}
    self:EnsureKittyBridgeHook()
    self:ClearExternalFromRegistry()

    local lsmCount = 0
    local lsmPackCount = 0

    if self:TryBindLSM() then
        local soundList = self.LSM:List("sound") or {}

        for _, soundName in ipairs(soundList) do
            local soundPath = self.LSM:Fetch("sound", soundName)
            if type(soundPath) == "string" and soundPath ~= "" then
                local packName = ExtractAddonNameFromPath(soundPath)
                local normalizedPath = NormalizePath(soundPath)
                if normalizedPath then
                    self._lsmPathSet[string.lower(normalizedPath)] = true
                end

                self.externalSounds[soundName] = {
                    name = soundName,
                    file = soundPath,
                    packId = packName,
                    packName = packName,
                }

                self.soundCategories[packName] = self.soundCategories[packName] or {}
                table.insert(self.soundCategories[packName], soundName)

                if BLU.SoundRegistry and BLU.SoundRegistry.RegisterSound then
                    BLU.SoundRegistry:RegisterSound("external:" .. soundName, {
                        name = soundName,
                        file = soundPath,
                        category = "all",
                        source = "SharedMedia",
                        packId = packName,
                        packName = packName,
                    })
                end

                lsmCount = lsmCount + 1
            end
        end
    end

    for _, categorySounds in pairs(self.soundCategories) do
        table.sort(categorySounds, SortCaseInsensitive)
        lsmPackCount = lsmPackCount + 1
    end

    local kittyBridgeCount = self:ScanKittySoundPacks()
    local dbmRegistrarCount = self:InvokeDBMPackRegistrars()
    local bridgeCount = self:ScanGenericBridgeSources()
    local manualBridgeCount = self:ApplyManualBridgePaths()
    self:NotifyExternalSoundsUpdated()

    BLU:PrintDebug(string.format(
        "SharedMedia scan complete: %d LSM sounds across %d LSM packs, %d Kitty sounds, %d DBM registrar hooks, %d bridged sounds, %d manual bridge sounds.",
        lsmCount,
        lsmPackCount,
        kittyBridgeCount,
        dbmRegistrarCount,
        bridgeCount,
        manualBridgeCount
    ))
end

function SharedMedia:GetExternalSounds()
    BLU:PrintDebug("[SharedMedia] GetExternalSounds called")
    return self.externalSounds
end

function SharedMedia:GetSoundCategories()
    BLU:PrintDebug("[SharedMedia] GetSoundCategories called")
    return self.soundCategories
end

function SharedMedia:PlayExternalSound(name)
    BLU:PrintDebug("[SharedMedia] PlayExternalSound called for '" .. tostring(name) .. "'")
    if not self:TryBindLSM() then
        BLU:PrintDebug("LibSharedMedia unavailable; cannot play external sound.")
        return false
    end

    local soundPath = self.LSM:Fetch("sound", name)
    if not soundPath then
        BLU:PrintDebug("External sound not found: " .. tostring(name))
        return false
    end

    local willPlay = PlaySoundFile(soundPath, "Master")
    if willPlay then
        BLU:PrintDebug(string.format("Playing external sound: %s", tostring(name)))
        return true
    end

    BLU:PrintError("Failed to play external sound: " .. tostring(name))
    return false
end

function SharedMedia:OnAddonLoaded(loadedAddonName)
    BLU:PrintDebug("[SharedMedia] OnAddonLoaded called for '" .. tostring(loadedAddonName) .. "'")
    if not IsLikelyMediaProviderName(loadedAddonName) then
        return
    end

    -- Rescan after likely media-provider addons load so non-LSM and late
    -- registrations are captured without hammering startup.
    self:EnsureKittyBridgeHook()
    if self:TryBindLSM() then
        BLU:PrintDebug("SharedMedia addon load update: " .. tostring(loadedAddonName))
    end
    self:QueueRescan(0.25)
end

function SharedMedia:OnPlayerLogin()
    BLU:PrintDebug("[SharedMedia] OnPlayerLogin called")
    self:QueueRescan(1.0)
end

function SharedMedia:OnMediaRegistered(event, mediatype, key)
    BLU:PrintDebug("[SharedMedia] OnMediaRegistered called for mediatype='" .. tostring(mediatype) .. "', key='" .. tostring(key) .. "'")
    if mediatype ~= "sound" then
        return
    end

    BLU:PrintDebug("New shared media sound registered: " .. tostring(key))
    self:QueueRescan(0.1)
end

function SharedMedia:OnMediaSetGlobal(event, mediatype, key)
    BLU:PrintDebug("[SharedMedia] OnMediaSetGlobal called for mediatype='" .. tostring(mediatype) .. "', key='" .. tostring(key) .. "'")
    if mediatype ~= "sound" then
        return
    end

    self:QueueRescan(0.1)
end
