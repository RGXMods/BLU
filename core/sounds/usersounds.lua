--=====================================================================================
-- BLU - usersounds.lua
-- User Custom Sounds pack
-- Auto-detects custom sound slots from shared AddOns folders.
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local UserSounds = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["usersounds"] = UserSounds

local PACK_ID   = "user_custom_sounds"
local PACK_NAME = "User Custom Sounds"
local AUTO_SLOT_COUNT = 99
local AUTO_SLOT_EXTENSIONS = {"ogg", "mp3", "wav"}
local AUTO_SLOT_NAME_PATTERNS = {
    "custom%02d",
    "sound%02d",
    "usersound%02d",
    "blu_custom%02d",
}
local AUTO_SLOT_PATH_PATTERNS = {
    "Interface\\AddOns\\%s.%s",
    "Interface\\AddOns\\sounds\\%s.%s",
    "Interface\\AddOns\\" .. addonName .. "\\%s.%s",
    "Interface\\AddOns\\" .. addonName .. "\\sounds\\%s.%s",
    "Interface\\AddOns\\" .. addonName .. "\\media\\sounds\\%s.%s",
}
local CUSTOM_SOUND_SEARCH_PATHS = {
    "Interface\\AddOns\\%s",
    "Interface\\AddOns\\sounds\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\sounds\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\user\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\user\\sounds\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\media\\%s",
    "Interface\\AddOns\\" .. addonName .. "\\media\\sounds\\%s",
}
local CanLoadSoundFile
local ResolveCustomSoundPath

local function NormalizeEntryPath(soundPath)
    if type(soundPath) ~= "string" then
        return nil
    end

    local normalized = soundPath:gsub("/", "\\")
    if normalized == "" then
        return nil
    end

    return normalized
end

local function BuildDisplayNameFromPath(filePath, fallbackName)
    return string.match(filePath or "", "([^\\]+)%.[^%.]+$") or fallbackName
end

local function NormalizeSearchToken(value)
    if type(value) ~= "string" then
        return nil
    end

    local token = value:lower()
    token = token:gsub("^interface\\addons\\", "")
    token = token:gsub("%.[^%.\\]+$", "")
    token = token:gsub("[_%-%s]+", "")
    token = token:gsub("[^%w]", "")
    if token == "" then
        return nil
    end

    return token
end

local function IsSubsequence(needle, haystack)
    if type(needle) ~= "string" or type(haystack) ~= "string" then
        return false
    end

    local pos = 1
    for i = 1, #needle do
        local char = needle:sub(i, i)
        pos = string.find(haystack, char, pos, true)
        if not pos then
            return false
        end
        pos = pos + 1
    end

    return true
end

local function HasSupportedExtension(soundPath)
    if type(soundPath) ~= "string" then
        return false
    end

    local lowerPath = soundPath:lower()
    for _, extension in ipairs(AUTO_SLOT_EXTENSIONS) do
        if lowerPath:sub(-(#extension + 1)) == "." .. extension then
            return true
        end
    end

    return false
end

local function NormalizeCandidateFiles(candidateFiles)
    if type(candidateFiles) ~= "table" then
        return nil
    end

    local normalized = {}
    local seen = {}

    for _, candidatePath in ipairs(candidateFiles) do
        local normalizedPath = NormalizeEntryPath(candidatePath)
        if normalizedPath and not seen[normalizedPath] then
            seen[normalizedPath] = true
            table.insert(normalized, normalizedPath)
        end
    end

    if #normalized == 0 then
        return nil
    end

    return normalized
end

local function AddEntry(entries, seenPaths, soundPath, displayName, autoDetected, allowUnverified, candidateFiles)
    local normalizedPath = NormalizeEntryPath(soundPath)
    if not normalizedPath then
        BLU:PrintDebug("[UserSounds] Skipped invalid custom sound path")
        return false
    end

    if seenPaths[normalizedPath] then
        BLU:PrintDebug("[UserSounds] Skipped duplicate custom sound path '" .. tostring(normalizedPath) .. "'")
        return false
    end

    if not CanLoadSoundFile(normalizedPath) then
        if allowUnverified then
            BLU:PrintDebug("[UserSounds] Accepting unverified custom sound path '" .. tostring(normalizedPath) .. "'")
        else
            BLU:PrintDebug("[UserSounds] Probe failed for custom sound path '" .. tostring(normalizedPath) .. "'")
            return false
        end
    end

    table.insert(entries, {
        name = displayName or BuildDisplayNameFromPath(normalizedPath),
        file = normalizedPath,
        autoDetected = autoDetected == true,
        candidateFiles = NormalizeCandidateFiles(candidateFiles),
    })
    seenPaths[normalizedPath] = true
    BLU:PrintDebug("[UserSounds] Accepted custom sound path '" .. tostring(normalizedPath) .. "'")
    return true
end

CanLoadSoundFile = function(soundPath)
    if type(soundPath) ~= "string" or soundPath == "" then
        BLU:PrintDebug("[UserSounds] CanLoadSoundFile rejected invalid path")
        return false
    end

    local muted = false
    local unmuteRequired = false

    if MuteSoundFile and UnmuteSoundFile then
        local ok = pcall(MuteSoundFile, soundPath)
        muted = ok
        unmuteRequired = ok
    end

    local ok, willPlay, handle = pcall(PlaySoundFile, soundPath, "Master")

    if handle and StopSound then
        pcall(StopSound, handle)
    end

    if unmuteRequired then
        pcall(UnmuteSoundFile, soundPath)
    end

    local canLoad = ok and willPlay == true
    BLU:PrintDebug("[UserSounds] Probe for '" .. tostring(soundPath) .. "' => " .. tostring(canLoad))
    return canLoad
end

local function TryPlayableCandidate(candidatePath)
    if type(candidatePath) ~= "string" or candidatePath == "" then
        return false
    end

    local ok, willPlay, handle = pcall(PlaySoundFile, candidatePath, "Master")
    if handle and StopSound then
        pcall(StopSound, handle)
    end

    local playable = ok and willPlay == true
    BLU:PrintDebug("[UserSounds] Active verify for '" .. tostring(candidatePath) .. "' => " .. tostring(playable))
    return playable
end

local function CollectAutoDetectedEntries()
    BLU:PrintDebug("[UserSounds] CollectAutoDetectedEntries scanning " .. tostring(AUTO_SLOT_COUNT) .. " slots")
    local entries = {}
    local seenPaths = {}

    for slot = 1, AUTO_SLOT_COUNT do
        for _, namePattern in ipairs(AUTO_SLOT_NAME_PATTERNS) do
            local slotName = string.format(namePattern, slot)
            local foundForPattern = false

            for _, pathPattern in ipairs(AUTO_SLOT_PATH_PATTERNS) do
                for _, extension in ipairs(AUTO_SLOT_EXTENSIONS) do
                    local soundPath = string.format(pathPattern, slotName, extension)
                    if AddEntry(entries, seenPaths, soundPath, slotName, true) then
                        BLU:PrintDebug("[UserSounds] Auto-detected custom sound at '" .. tostring(soundPath) .. "'")
                        foundForPattern = true
                        break
                    end
                end

                if foundForPattern then
                    break
                end
            end

            if foundForPattern then
                break
            end
        end
    end

    BLU:PrintDebug("[UserSounds] Auto-detected " .. tostring(#entries) .. " candidate custom sounds")
    return entries
end

local function CollectConfiguredEntries(entries, seenPaths, globalName, sourceLabel)
    BLU:PrintDebug("[UserSounds] CollectConfiguredEntries called for '" .. tostring(globalName) .. "'")
    local configured = _G[globalName]
    if type(configured) ~= "table" then
        BLU:PrintDebug("[UserSounds] No configured custom sound table found for '" .. tostring(globalName) .. "'")
        return
    end

    local function addConfiguredPath(rawPath, displayName, candidateFiles)
        local resolvedPath = rawPath
        local resolvedCandidates = candidateFiles

        if type(rawPath) == "string" and ResolveCustomSoundPath then
            local candidatePath, candidateList = ResolveCustomSoundPath(rawPath)
            if candidatePath then
                resolvedPath = candidatePath
                resolvedCandidates = candidateList or candidateFiles
                BLU:PrintDebug("[UserSounds] Resolved configured custom sound '" .. tostring(rawPath) .. "' to '" .. tostring(candidatePath) .. "'")
            end
        end

        AddEntry(entries, seenPaths, resolvedPath, displayName, false, true, resolvedCandidates)
    end

    for index, entry in ipairs(configured) do
        if type(entry) == "string" then
            addConfiguredPath(entry, nil, nil)
        elseif type(entry) == "table" then
            addConfiguredPath(entry.file or entry.path, entry.name, entry.candidateFiles)
        else
            BLU:PrintDebug("[UserSounds] Skipped unsupported " .. tostring(sourceLabel) .. " entry at index " .. tostring(index))
        end
    end
end

local function CollectGeneratedManifestEntries(entries, seenPaths)
    BLU:PrintDebug("[UserSounds] CollectGeneratedManifestEntries called")
    local manifest = _G.BLU_UserCustomSoundManifest
    if type(manifest) ~= "table" then
        BLU:PrintDebug("[UserSounds] No generated custom sound manifest found")
        return
    end

    for index, entry in ipairs(manifest) do
        if type(entry) == "string" then
            AddEntry(entries, seenPaths, entry, nil, true, true, {entry})
        elseif type(entry) == "table" then
            local filePath = entry.file or entry.path
            AddEntry(entries, seenPaths, filePath, entry.name, true, true, entry.candidateFiles or {filePath})
        else
            BLU:PrintDebug("[UserSounds] Skipped unsupported generated manifest entry at index " .. tostring(index))
        end
    end
end

local function NormalizeStoredProfileEntry(entry)
    if type(entry) ~= "table" then
        return entry
    end

    local normalizedPath = NormalizeEntryPath(entry.file or entry.path)
    local candidateFiles = NormalizeCandidateFiles(entry.candidateFiles)
    if not normalizedPath or not candidateFiles or #candidateFiles <= 1 then
        return entry
    end

    for _, candidatePath in ipairs(candidateFiles) do
        if TryPlayableCandidate(candidatePath) then
            if candidatePath ~= normalizedPath then
                BLU:PrintDebug("[UserSounds] Normalized stored custom sound path from '" .. tostring(normalizedPath) .. "' to '" .. tostring(candidatePath) .. "'")
                entry.file = candidatePath
                entry.path = nil
                entry.candidateFiles = {candidatePath}
            end
            break
        end
    end

    return entry
end

local function FindKnownCustomSoundMatch(soundInput)
    local wanted = NormalizeSearchToken(soundInput)
    if not wanted then
        return nil
    end

    local function collectKnownEntries(results, source)
        if type(source) ~= "table" then
            return
        end

        for _, entry in ipairs(source) do
            if type(entry) == "string" then
                results[#results + 1] = {
                    name = BuildDisplayNameFromPath(entry),
                    file = entry,
                }
            elseif type(entry) == "table" then
                results[#results + 1] = {
                    name = entry.name or BuildDisplayNameFromPath(entry.file or entry.path),
                    file = entry.file or entry.path,
                }
            end
        end
    end

    local candidates = {}
    if BLU.db and type(BLU.db.userCustomSounds) == "table" then
        collectKnownEntries(candidates, BLU.db.userCustomSounds)
    end
    collectKnownEntries(candidates, _G.BLU_UserCustomSounds)
    collectKnownEntries(candidates, _G.BLU_UserCustomSoundManifest)

    local bestPath
    local bestScore = math.huge
    local bestCandidates

    for _, candidate in ipairs(candidates) do
        local filePath = NormalizeEntryPath(candidate.file)
        if filePath and filePath ~= "" then
            local baseName = BuildDisplayNameFromPath(filePath, candidate.name)
            local nameToken = NormalizeSearchToken(candidate.name)
            local baseToken = NormalizeSearchToken(baseName)
            local pathToken = NormalizeSearchToken(filePath)

            local function scoreToken(token)
                if not token then
                    return
                end
                local startIndex = string.find(token, wanted, 1, true)
                if startIndex then
                    local score = (#token - #wanted) + startIndex
                    if score < bestScore then
                        bestScore = score
                        bestPath = filePath
                        bestCandidates = {filePath}
                    end
                elseif #wanted >= 4 and IsSubsequence(wanted, token) then
                    local score = (#token - #wanted) + 50
                    if score < bestScore then
                        bestScore = score
                        bestPath = filePath
                        bestCandidates = {filePath}
                    end
                end
            end

            scoreToken(nameToken)
            scoreToken(baseToken)
            scoreToken(pathToken)
        end
    end

    return bestPath, bestCandidates
end

ResolveCustomSoundPath = function(soundInput)
    local normalizedInput = NormalizeEntryPath(soundInput)
    if not normalizedInput then
        return nil
    end

    local explicitPath = normalizedInput:lower():find("^interface\\addons\\") or normalizedInput:find("\\")
    local explicitExtension = HasSupportedExtension(normalizedInput)

    if normalizedInput:lower():find("^interface\\addons\\") or normalizedInput:find("\\") then
        if HasSupportedExtension(normalizedInput) and CanLoadSoundFile(normalizedInput) then
            BLU:PrintDebug("[UserSounds] Resolved explicit custom sound path '" .. tostring(normalizedInput) .. "'")
            return normalizedInput
        end

        if explicitExtension then
            BLU:PrintDebug("[UserSounds] Falling back to explicit custom sound path '" .. tostring(normalizedInput) .. "'")
            return normalizedInput
        end
    end

    local filename = normalizedInput:gsub("^%s+", ""):gsub("%s+$", "")
    if filename == "" then
        return nil
    end

    local knownPath, knownCandidates = FindKnownCustomSoundMatch(filename)
    if knownPath then
        BLU:PrintDebug("[UserSounds] Resolved fuzzy custom sound input '" .. tostring(soundInput) .. "' to known file '" .. tostring(knownPath) .. "'")
        return knownPath, knownCandidates
    end

    if not explicitExtension then
        BLU:PrintDebug("[UserSounds] Attempting supported extension resolution for '" .. tostring(filename) .. "' using .ogg/.mp3/.wav")
    end

    local candidateNames = {}
    if HasSupportedExtension(filename) then
        table.insert(candidateNames, filename)
    else
        for _, extension in ipairs(AUTO_SLOT_EXTENSIONS) do
            table.insert(candidateNames, filename .. "." .. extension)
        end
    end

    local candidatePaths = {}
    local seenCandidatePaths = {}

    local function addCandidatePath(path)
        local normalizedPath = NormalizeEntryPath(path)
        if normalizedPath and not seenCandidatePaths[normalizedPath] then
            seenCandidatePaths[normalizedPath] = true
            table.insert(candidatePaths, normalizedPath)
        end
    end

    for _, candidateName in ipairs(candidateNames) do
        for _, pathPattern in ipairs(CUSTOM_SOUND_SEARCH_PATHS) do
            local candidatePath = string.format(pathPattern, candidateName)
            addCandidatePath(candidatePath)
            if CanLoadSoundFile(candidatePath) then
                BLU:PrintDebug("[UserSounds] Resolved shorthand custom sound '" .. tostring(soundInput) .. "' to '" .. tostring(candidatePath) .. "'")
                return candidatePath, candidatePaths
            end
        end
    end

    if not explicitExtension then
        for _, candidatePath in ipairs(candidatePaths) do
            if TryPlayableCandidate(candidatePath) then
                BLU:PrintDebug("[UserSounds] Resolved shorthand custom sound '" .. tostring(soundInput) .. "' via active verify to '" .. tostring(candidatePath) .. "'")
                return candidatePath, {candidatePath}
            end
        end
    end

    if explicitExtension then
        for _, pathPattern in ipairs(CUSTOM_SOUND_SEARCH_PATHS) do
            local candidatePath = string.format(pathPattern, filename)
            BLU:PrintDebug("[UserSounds] Falling back to explicit-extension custom sound path '" .. tostring(candidatePath) .. "' for input '" .. tostring(soundInput) .. "'")
            return candidatePath, {candidatePath}
        end
    end

    if explicitPath and not explicitExtension then
        BLU:PrintDebug("[UserSounds] Falling back to explicit custom sound path without extension '" .. tostring(normalizedInput) .. "'")
        return normalizedInput, {normalizedInput}
    end

    if not explicitExtension and #candidatePaths > 0 then
        BLU:PrintDebug("[UserSounds] Falling back to candidate custom sound paths for input '" .. tostring(soundInput) .. "'")
        return candidatePaths[1], candidatePaths
    end

    BLU:PrintDebug("[UserSounds] Failed to resolve custom sound input '" .. tostring(soundInput) .. "'")
    return nil
end

local function CollectEntries()
    local entries = CollectAutoDetectedEntries()
    local seenPaths = {}

    for _, entry in ipairs(entries) do
        if entry.file then
            seenPaths[entry.file] = true
        end
    end

    if BLU.db and type(BLU.db.userCustomSounds) == "table" then
        for index, entry in ipairs(BLU.db.userCustomSounds) do
            if type(entry) == "string" then
                local resolvedPath, candidateFiles = ResolveCustomSoundPath(entry)
                AddEntry(entries, seenPaths, resolvedPath or entry, nil, false, true, candidateFiles)
            elseif type(entry) == "table" then
                entry = NormalizeStoredProfileEntry(entry)
                local rawPath = entry.file or entry.path
                local resolvedPath, candidateFiles = ResolveCustomSoundPath(rawPath)
                AddEntry(entries, seenPaths, resolvedPath or rawPath, entry.name, false, true, candidateFiles or entry.candidateFiles)
            else
                BLU:PrintDebug("[UserSounds] Skipped unsupported profile custom sound entry at index " .. tostring(index))
            end
        end
    else
        BLU:PrintDebug("[UserSounds] No profile custom sounds configured")
    end

    CollectGeneratedManifestEntries(entries, seenPaths)
    CollectConfiguredEntries(entries, seenPaths, "BLU_UserCustomSounds", "manual")
    BLU:PrintDebug("[UserSounds] Total custom sound candidates after configured merge: " .. tostring(#entries))
    return entries
end

-- Clear all previously registered user custom sounds from the registry
local function ClearRegisteredSounds()
    if not (BLU.SoundRegistry and BLU.SoundRegistry.UnregisterSound and BLU.SoundRegistry.GetAllSounds) then
        BLU:PrintDebug("[UserSounds] ClearRegisteredSounds skipped; SoundRegistry unavailable")
        return
    end
    local prefix = PACK_ID .. ":"
    local toRemove = {}
    for soundId in pairs(BLU.SoundRegistry:GetAllSounds()) do
        if string.sub(soundId, 1, #prefix) == prefix then
            table.insert(toRemove, soundId)
        end
    end
    for _, soundId in ipairs(toRemove) do
        BLU.SoundRegistry:UnregisterSound(soundId)
    end
    BLU:PrintDebug("[UserSounds] Cleared " .. tostring(#toRemove) .. " previously registered custom sounds")
end

-- Read auto-detected custom sound slots and register valid entries
function UserSounds:Register()
    BLU:PrintDebug("[UserSounds] Register called")
    ClearRegisteredSounds()

    local entries = CollectEntries()
    if #entries == 0 then
        BLU:PrintDebug("[UserSounds] No user custom sounds found.")
        return 0
    end

    if not (BLU.SoundRegistry and BLU.SoundRegistry.RegisterSound) then
        BLU:PrintDebug("[UserSounds] SoundRegistry not ready.")
        return 0
    end

    local count = 0
    for i, entry in ipairs(entries) do
        if type(entry) == "table" and type(entry.file) == "string" and entry.file ~= "" then
            local soundId     = PACK_ID .. ":" .. tostring(i)
            local displayName = entry.name
                or BuildDisplayNameFromPath(entry.file)
                or ("Sound " .. i)

            BLU.SoundRegistry:RegisterSound(soundId, {
                name     = displayName,
                file     = entry.file,
                candidateFiles = entry.candidateFiles,
                category = "all",
                source   = "UserCustom",
                packId   = PACK_ID,
                packName = PACK_NAME,
            })
            count = count + 1
            BLU:PrintDebug("[UserSounds] Registered custom sound '" .. tostring(soundId) .. "' from '" .. tostring(entry.file) .. "'")
        end
    end

    BLU:PrintDebug(string.format("[UserSounds] Registered %d user custom sound(s).", count))
    return count
end

function UserSounds:Init()
    BLU:PrintDebug("[UserSounds] Init called")
    self:Register()

    -- Expose public refresh API so /blu refresh also picks up user sounds
    local existingRefresh = BLU.RefreshUserSounds
    BLU.RefreshUserSounds = function()
        BLU:PrintDebug("[UserSounds] RefreshUserSounds invoked")
        local count = UserSounds:Register()
        if BLU.RefreshSoundPackUI then BLU.RefreshSoundPackUI() end
        return count
    end
    BLU:PrintDebug("[UserSounds] Existing refresh hook present: " .. tostring(existingRefresh ~= nil))

    BLU:PrintDebug("[UserSounds] User custom sounds module initialized.")
end

function UserSounds:AddCustomSound(soundPath, displayName)
    BLU:PrintDebug("[UserSounds] AddCustomSound called for '" .. tostring(soundPath) .. "'")
    if not (BLU.db) then
        return false, "Database not ready"
    end

    local resolvedPath, candidateFiles = ResolveCustomSoundPath(soundPath)
    if not resolvedPath then
        return false, "Could not find a compatible .ogg, .mp3, or .wav file for '" .. tostring(soundPath) .. "'"
    end

    BLU.db.userCustomSounds = BLU.db.userCustomSounds or {}
    local resolvedName = displayName
    if not resolvedName then
        local normalizedInput = NormalizeEntryPath(soundPath)
        if normalizedInput and not HasSupportedExtension(normalizedInput) and not normalizedInput:find("\\") then
            resolvedName = normalizedInput
        end
    end
    table.insert(BLU.db.userCustomSounds, {
        file = resolvedPath,
        name = resolvedName,
        candidateFiles = candidateFiles,
    })

    if BLU.RefreshUserSounds then
        BLU:RefreshUserSounds()
    end

    return true, resolvedName or BuildDisplayNameFromPath(resolvedPath), resolvedPath
end

function UserSounds:PromoteResolvedCustomSound(previousPath, resolvedPath)
    BLU:PrintDebug("[UserSounds] PromoteResolvedCustomSound called for '" .. tostring(previousPath) .. "' => '" .. tostring(resolvedPath) .. "'")
    if not (BLU.db and type(BLU.db.userCustomSounds) == "table") then
        return false, "No profile custom sounds configured"
    end

    local normalizedPrevious = NormalizeEntryPath(previousPath)
    local normalizedResolved = NormalizeEntryPath(resolvedPath)
    if not normalizedPrevious or not normalizedResolved or normalizedPrevious == normalizedResolved then
        return false, "No custom sound update required"
    end

    for _, entry in ipairs(BLU.db.userCustomSounds) do
        if type(entry) == "table" then
            local entryPath = NormalizeEntryPath(entry.file or entry.path)
            if entryPath == normalizedPrevious then
                entry.file = normalizedResolved
                entry.path = nil
                entry.candidateFiles = {normalizedResolved}
                if not entry.name or entry.name == "" or entry.name == BuildDisplayNameFromPath(normalizedPrevious) then
                    entry.name = BuildDisplayNameFromPath(normalizedResolved, entry.name)
                end

                if BLU.RefreshUserSounds then
                    BLU:RefreshUserSounds()
                end

                BLU:PrintDebug("[UserSounds] Promoted custom sound path to '" .. tostring(normalizedResolved) .. "'")
                return true
            end
        end
    end

    return false, "Custom sound not found"
end

function UserSounds:RemoveCustomSound(matchValue)
    BLU:PrintDebug("[UserSounds] RemoveCustomSound called for '" .. tostring(matchValue) .. "'")
    if not (BLU.db and type(BLU.db.userCustomSounds) == "table") then
        return false, "No profile custom sounds configured"
    end

    local normalizedMatch = NormalizeEntryPath(matchValue)
    for index = #BLU.db.userCustomSounds, 1, -1 do
        local entry = BLU.db.userCustomSounds[index]
        local entryPath = type(entry) == "table" and NormalizeEntryPath(entry.file or entry.path) or NormalizeEntryPath(entry)
        local entryName = type(entry) == "table" and entry.name or nil
        if entryPath == normalizedMatch or entryName == matchValue then
            table.remove(BLU.db.userCustomSounds, index)
            if BLU.RefreshUserSounds then
                BLU:RefreshUserSounds()
            end
            return true
        end
    end

    return false, "Custom sound not found"
end

function UserSounds:GetCustomSoundEntries()
    BLU:PrintDebug("[UserSounds] GetCustomSoundEntries called")
    local results = {}
    local seen = {}

    local function addResult(entry)
        if type(entry) ~= "table" then
            return
        end

        local normalizedPath = NormalizeEntryPath(entry.file)
        if not normalizedPath then
            return
        end

        local key = normalizedPath:lower()
        if seen[key] then
            if entry.removable and not seen[key].removable then
                seen[key].removable = true
                seen[key].index = entry.index
                seen[key].source = entry.source or seen[key].source
            end
            return
        end

        entry.file = normalizedPath
        entry.name = entry.name or BuildDisplayNameFromPath(normalizedPath)
        results[#results + 1] = entry
        seen[key] = entry
    end

    if BLU.db and type(BLU.db.userCustomSounds) == "table" then
        for index, entry in ipairs(BLU.db.userCustomSounds) do
            local filePath = type(entry) == "table" and (entry.file or entry.path) or entry
            local displayName = type(entry) == "table" and entry.name or nil
            addResult({
                index = index,
                file = filePath,
                name = displayName,
                source = "Profile",
                removable = true,
            })
        end
    end

    if BLU.SoundRegistry and BLU.SoundRegistry.GetAllSounds then
        for soundId, soundData in pairs(BLU.SoundRegistry:GetAllSounds()) do
            if type(soundData) == "table" and (
                soundData.source == "UserCustom"
                or soundData.packId == PACK_ID
                or soundData.packName == PACK_NAME
            ) then
                addResult({
                    id = soundId,
                    file = soundData.file,
                    name = soundData.name,
                    source = "Loaded",
                    removable = false,
                })
            end
        end
    end

    table.sort(results, function(a, b)
        return string.lower(a.name or "") < string.lower(b.name or "")
    end)

    return results
end

function UserSounds:ClearCustomSounds()
    BLU:PrintDebug("[UserSounds] ClearCustomSounds called")
    if not (BLU.db) then
        return false, "Database not ready"
    end

    BLU.db.userCustomSounds = {}

    if BLU.RefreshUserSounds then
        BLU:RefreshUserSounds()
    end

    return true
end

if BLU.RegisterModule then
    BLU:RegisterModule(UserSounds, "usersounds", "User Custom Sounds")
end
