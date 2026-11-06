-- BLU must keep a manifest written by the BLU_UserSounds companion addon and trust its paths.
local function read(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return s end
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end

-- The shipped generated file must not wipe a manifest defined by an addon that loaded first.
BLU_UserCustomSoundManifest = { { file = "Interface\\AddOns\\MySounds\\deep\\er\\x.ogg", name = "x" } }
assert(loadfile("core/sounds/user_sounds_generated.lua"))()
check(#BLU_UserCustomSoundManifest == 1, "existing manifest survives BLU loading its own generated file")
BLU_UserCustomSoundManifest = nil
assert(loadfile("core/sounds/user_sounds_generated.lua"))()
check(type(BLU_UserCustomSoundManifest) == "table", "creates an empty manifest when none exists")

local toc = read(arg and arg[1] or "BLU_Forever.toc")
check(toc:find("## OptionalDeps: BLU_UserSounds", 1, true), "TOC lists the companion addon so it loads first")

local us = read("core/sounds/usersounds.lua")
check(us:find('allowUnverified ~= "manifest"', 1, true), "manifest entries are not probed one by one")
local n = select(2, us:gsub('"manifest"', ""))
check(n >= 3, "both manifest entry forms are marked trusted")
print("user-sounds-manifest-test OK")
