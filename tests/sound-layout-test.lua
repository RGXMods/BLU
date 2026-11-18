-- BLU's sound folders: sounds\wow_default\ (the game's own sounds), sounds\game\ (other games' sounds) and
-- sounds\user\ (shipped empty for the player's own files). Every built-in sound must point at a file that exists in
-- its folder, and a file in sounds\user\ must be found by its name.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local ADDON = arg and arg[1] or "BLU"
local function exists(p) local f = io.open(p, "rb"); if f then f:close(); return true end return false end
local function read(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return s end

check(exists("sounds/user/README.txt"), "sounds/user ships with its README")
check(not exists("media/sounds/level_default_med.ogg"), "the old flat media/sounds folder is gone")

local src = read("core/sounds/internal_sounds.lua")
local n = 0
for rel in src:gmatch('ADDON_PATH %.%. "(sounds\\\\wow_default\\\\[%w_%-]+%.ogg)"') do
  n = n + 1
  check(exists((rel:gsub("\\\\", "/"))), rel .. " exists")
end
check(n >= 8, "the WoW default sounds point into sounds/wow_default (" .. n .. ")")
check(not src:find('media\\\\sounds', 1, true), "no built-in sound still points at media/sounds")
local games = 0
for fileId in src:gmatch('file_id = "([%w_%-]+)"') do
  games = games + 1
  for _, v in ipairs({ "low", "med", "high" }) do
    check(exists("sounds/game/" .. fileId .. "_" .. v .. ".ogg"), "sounds/game/" .. fileId .. "_" .. v .. ".ogg exists")
  end
end
check(games > 50, "the game packs point into sounds/game (" .. games .. ")")
for f in io.popen("ls sounds/wow_default"):lines() do check(f:find("_default_", 1, true), f .. " in wow_default is a WoW default sound") end
for f in io.popen("ls sounds/game"):lines() do check(not f:find("_default_", 1, true), f .. " in game is not a WoW default sound") end

-- A player's file in sounds\user is found by name, and a slot-named one is picked up on its own.
local files = {}
_G.PlaySoundFile = function(path) if files[path:lower()] then return true, 1 end return false end
_G.StopSound = function() end
local registered = {}
_G.BLU = { db = {}, Modules = {}, PrintDebug = function() end,
  SoundRegistry = { RegisterSound = function(_, id, d) registered[#registered + 1] = d end, UnregisterSound = function() end, GetAllSounds = function() return {} end } }
assert(loadfile("core/sounds/usersounds.lua"))(ADDON)
local US = BLU.Modules["usersounds"]
local USER = "Interface\\AddOns\\" .. ADDON .. "\\sounds\\user\\"
check(US.ADDON_USER_FOLDER == USER, "the shipped user folder is exposed")
files[(USER .. "sonar_boop_med.ogg"):lower()] = true
check(US.ResolveCustomSoundPath("sonar_boop_med") == USER .. "sonar_boop_med.ogg", "a name in sounds\\user resolves")
files[(USER .. "custom07.ogg"):lower()] = true
US:Register()
local slot = false
for _, r in ipairs(registered) do if r.file == USER .. "custom07.ogg" then slot = true end end
check(slot, "a slot-named file in sounds\\user is picked up on its own")
print("sound-layout-test OK")
