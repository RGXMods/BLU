-- BLU must find sounds where the docs say it does: its own user folders, and other addons' sound
-- folders. The game cannot list folders, so a fake file system stands in for the client.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local files, probes = {}, 0
local addons = { "Blizzard_Foo", "BLU", "OtherAuraAddon", "MyVoicePack", "OtherMeterAddon", "SoundsOfWar" }
_G.PlaySoundFile = function(path)
  probes = probes + 1
  if files[path:lower()] then return true, 1 end
  return false
end
_G.StopSound = function() end
_G.C_AddOns = {
  GetNumAddOns = function() return #addons end,
  GetAddOnInfo = function(i) return addons[i] end,
}
local registered = {}
_G.BLU = {
  db = {}, Modules = {}, PrintDebug = function() end,
  SoundRegistry = {
    RegisterSound = function(_, id, data) registered[#registered + 1] = data end,
    UnregisterSound = function() end, GetAllSounds = function() return {} end,
  },
}
assert(loadfile("core/sounds/usersounds.lua"))("BLU")
local US = BLU.Modules["usersounds"]
local resolve = US.ResolveCustomSoundPath
local ADDON = "BLU"

local function has(path) files[path:lower()] = true end

-- 1. The documented personal folder: a slot-named file is picked up automatically.
has("Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\custom01.ogg")
US:Register()
local found = false
for _, r in ipairs(registered) do if r.file:lower():find("user\\sounds\\custom01.ogg", 1, true) then found = true end end
check(found, "a file in BLU\\user\\sounds is auto-detected")

-- 2. Other addons' folders are NOT searched by name: a bare name that is only there is not found.
has("Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg")
check(resolve("roar") == nil, "a bare name is not guessed from another addon's folder")
probes = 0
resolve("definitely-not-there")
check(probes > 0 and probes <= 60, "a miss only probes BLU's documented folders (" .. probes .. " probes)")
check(type(US.lastSearchedPaths) == "table" and #US.lastSearchedPaths > 0, "a miss records where it looked")

-- 3. BLU's documented folders resolve a bare name, with extension guessing.
has("Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\boom.ogg")
check(resolve("boom") == "Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\boom.ogg", "BLU's user folder resolves a bare name")

-- 4. A full path to any addon works, with or without the extension.
has("Interface\\AddOns\\SoundsOfWar\\horn.mp3")
check(resolve("Interface\\AddOns\\SoundsOfWar\\horn.mp3") == "Interface\\AddOns\\SoundsOfWar\\horn.mp3", "explicit path kept")
check(resolve("Interface\\AddOns\\SoundsOfWar\\horn") == "Interface\\AddOns\\SoundsOfWar\\horn.mp3", "explicit path without extension finds the file")
probes = 0
resolve("Interface\\AddOns\\Elsewhere\\x.ogg")
check(probes <= 2, "no addon-wide search for an explicit path (" .. probes .. " probes)")

-- 5. An exact registered sound name resolves to that sound's file; near matches do not.
BLU.SoundRegistry.GetAllSounds = function()
  return { pack1 = { name = "Alliance March", file = "Interface\\AddOns\\Pack\\am_med.ogg", packId = "pack" } }
end
check(resolve("alliance march") == "Interface\\AddOns\\Pack\\am_med.ogg", "exact registered name resolves")
check(resolve("alliance") == nil, "a partial name does not fuzzy-match")

-- 6. A failed add explains where to put the file.
local ok, err = US:AddCustomSound("nothere")
check(ok == false and err:find("user\\sounds", 1, true) and err:lower():find("restart", 1, true), "failure message names the folder and the restart")

-- 7. The designated BLU_Sounds folder: a plain folder next to BLU, so a BLU update never touches the files.
local FOLDER = "Interface\\AddOns\\BLU_Sounds\\"
check(US.FOLDER == FOLDER, "the designated folder is exposed")
has(FOLDER .. "custom05.ogg")
for k in pairs(registered) do registered[k] = nil end
US:Register()
local foundDesignated = false
for _, r in ipairs(registered) do if r.file:lower():find("blu_sounds\\custom05.ogg", 1, true) then foundDesignated = true end end
check(foundDesignated, "a slot-named file in BLU_Sounds is auto-detected")
has(FOLDER .. "thunder.ogg")
has("Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\thunder.ogg")
check(resolve("thunder") == FOLDER .. "thunder.ogg", "a bare name resolves in BLU_Sounds before BLU's own folders")
local missOk, missErr = US:AddCustomSound("nothere-either")
check(missOk == false and missErr:find("BLU_Sounds", 1, true) and missErr:find("survives", 1, true) and missErr:lower():find("restart", 1, true),
  "the failure message names the designated folder, that it survives updates, and the restart")

print("user-sounds-search-test OK")
