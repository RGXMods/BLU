-- Warcraft III Music pack: every track is declared once and ships all three volume variants.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local function read(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return s end
local src = read("core/sounds/internal_sounds.lua")
check(src:find('id = "warcraft_3_music"', 1, true), "the Warcraft III Music pack is declared")
local ids, count = {}, 0
for soundId, fileId, duration in src:gmatch('{soundId = "(wc3_music_[%w_]+)", name = "[^"]+", file_id = "([%w_]+)", duration = (%d+)}') do
  count = count + 1
  check(soundId == fileId, soundId .. ": soundId and file_id match")
  check(not ids[soundId], soundId .. ": declared once"); ids[soundId] = true
  check(tonumber(duration) >= 30, soundId .. ": music has a real duration")
  for _, variant in ipairs({ "low", "med", "high" }) do
    local f = io.open("media/sounds/" .. fileId .. "_" .. variant .. ".ogg", "rb")
    check(f, fileId .. "_" .. variant .. ".ogg exists")
    local head = f:read(4); local size = f:seek("end"); f:close()
    check(head == "OggS" and size > 50000, fileId .. "_" .. variant .. ".ogg is a real Ogg file")
  end
end
check(count == 12, "all 12 tracks are declared (found " .. count .. ")")
check(src:find("duration = soundData.duration or 2.0", 1, true), "registration honours a per-sound duration")
print("WC3 MUSIC PACK OK  (" .. count .. " tracks, 3 volume variants each)")
