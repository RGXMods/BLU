-- BLU looks up a typed custom sound name through the framework's resolver (RGXSound:ResolveFile), handing it
-- BLU's own folders with the designated BLU_Sounds folder first. With the real framework file reachable
-- (RGXFW_PATH or a sibling checkout), the player's own spellings are checked end to end.
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local ADDON = arg and arg[1] or "BLU"
local files = {}
local muteBlocksPlay, muted = false, {}
_G.MuteSoundFile = function(p) muted[p] = true end
_G.UnmuteSoundFile = function(p) muted[p] = nil end
_G.PlaySoundFile = function(path)
  if muteBlocksPlay and muted[path] then return false end
  if files[path:lower()] then return true, 1 end
  return false
end
_G.StopSound = function() end
_G.BLU = {
  db = {}, Modules = {}, PrintDebug = function() end,
  SoundRegistry = { RegisterSound = function() end, UnregisterSound = function() end, GetAllSounds = function() return {} end },
}
assert(loadfile("core/sounds/usersounds.lua"))(ADDON)
local US = BLU.Modules["usersounds"]
local FOLDER = "Interface\\AddOns\\BLU_Sounds\\"

-- 1. Delegation: BLU passes the typed text and its folders, designated folder first, and uses the answer.
local seen
_G.RGXSound = { ResolveFile = function(_, input, opts) seen = { input = input, folders = opts and opts.folders }; return FOLDER .. "x.ogg", { FOLDER .. "x.ogg" } end }
check(US.ResolveCustomSoundPath("sonar boop med") == FOLDER .. "x.ogg", "the framework's answer is used")
check(seen and seen.input == "sonar boop med", "the typed text is passed through")
check(seen.folders and seen.folders[1] == FOLDER, "BLU_Sounds is the first folder")
check(seen.folders[2] == "Interface\\AddOns\\", "BLU's other documented folders follow")

-- 2. A miss through the framework fails the add with the where-to-put-it message and records where it looked.
_G.RGXSound = { ResolveFile = function() return nil, { FOLDER .. "nope.ogg" } end }
local ok, err = US:AddCustomSound("nope")
check(ok == false and err:find("BLU_Sounds", 1, true), "a miss still explains the folder")
check(US.lastSearchedPaths and US.lastSearchedPaths[1] == FOLDER .. "nope.ogg", "the framework's tried list is kept")

-- 3. Without the framework resolver, a name typed with its extension is found even when a muted probe says no.
_G.RGXSound = nil
muteBlocksPlay = true
files[(FOLDER .. "sonar_boop_med.ogg"):lower()] = true
check(US.ResolveCustomSoundPath("sonar_boop_med.ogg") == FOLDER .. "sonar_boop_med.ogg", "extension input survives a mute-blocking client")
muteBlocksPlay = false

-- 4. The real framework resolver, when its source is reachable.
local fw = os.getenv("RGXFW_PATH")
local candidates = { fw and (fw .. "/libraries/sound/sound.lua"), "../fw/libraries/sound/sound.lua", "../RGX-Framework/libraries/sound/sound.lua" }
local chunk
for _, p in ipairs(candidates) do if p then chunk = loadfile(p); if chunk then break end end end
if chunk then
  local modules = {}
  _G.RGXFramework = { RegisterModule = function(_, n, m) modules[n] = m end }
  chunk("RGX-Framework", {})
  check(_G.RGXSound and _G.RGXSound.ResolveFile, "the framework sound module loads")
  for _, typed in ipairs({ "sonar_boop_med", "sonar_boop_med.ogg", "sonar boop med", "Sonar_Boop_Med" }) do
    local got = US.ResolveCustomSoundPath(typed)
    check(got and got:lower() == (FOLDER .. "sonar_boop_med.ogg"):lower(), "'" .. typed .. "' finds BLU_Sounds\\sonar_boop_med.ogg (got " .. tostring(got) .. ")")
  end
  local added, name, path = US:AddCustomSound("sonar_boop_med")
  check(added == true and path:lower() == (FOLDER .. "sonar_boop_med.ogg"):lower(), "the add stores the found file")
  print("user-sounds-framework-test OK (real framework resolver)")
else
  print("user-sounds-framework-test OK (framework source not reachable; real resolver not exercised)")
end
