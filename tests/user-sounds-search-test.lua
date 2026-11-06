-- BLU must find sounds where the docs say it does: its own user folders, and other addons' sound
-- folders. The game cannot list folders, so a fake file system stands in for the client.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local files, probes = {}, 0
local addons = { "Blizzard_Foo", "BLU", "WeakAuras", "MyVoicePack", "Details", "SoundsOfWar" }
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

-- 2. A name that lives in another addon's sound folder is found by name.
has("Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg")
check(resolve("roar") == "Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg", "finds roar.ogg inside another addon's media\\sounds")

has("Interface\\AddOns\\SoundsOfWar\\horn.mp3")
check(resolve("horn") == "Interface\\AddOns\\SoundsOfWar\\horn.mp3", "finds horn.mp3 at the top of another addon, with an extension guess")

-- 3. BLU's own documented folders win over other addons.
has("Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\boom.ogg")
has("Interface\\AddOns\\MyVoicePack\\sounds\\boom.ogg")
check(resolve("boom") == "Interface\\AddOns\\" .. ADDON .. "\\user\\sounds\\boom.ogg", "BLU's user folder takes priority")

-- 4. Likely sound packs are searched before everything else, and Blizzard/BLU folders never are.
has("Interface\\AddOns\\Details\\media\\ding.ogg")
has("Interface\\AddOns\\SoundsOfWar\\media\\ding.ogg")
check(resolve("ding"):find("SoundsOfWar", 1, true), "a folder that looks like a sound pack is tried before a generic addon")
probes = 0
resolve("definitely-not-there")
check(probes > 0 and probes <= 6000 + 200, "a miss stays bounded (" .. probes .. " probes)")

-- 5. An explicit path is used as given, with no search through other addons.
probes = 0
check(resolve("Interface\\AddOns\\Elsewhere\\x.ogg") == "Interface\\AddOns\\Elsewhere\\x.ogg", "explicit path is kept")
check(probes <= 2, "no addon-wide search for an explicit path (" .. probes .. " probes)")

-- 6. Without the add-on listing APIs the search degrades to the documented folders.
_G.C_AddOns = nil
_G.GetNumAddOns, _G.GetAddOnInfo = nil, nil
check(resolve("roar") ~= "Interface\\AddOns\\MyVoicePack\\media\\sounds\\roar.ogg", "no addon listing: other addons are not searched")

print("user-sounds-search-test OK")
