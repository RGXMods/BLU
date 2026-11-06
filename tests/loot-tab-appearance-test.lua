-- The Loot tab must expose the "Appearance Collected" (transmog) trigger.
local function read(path)
    local f = assert(io.open(path, "rb"))
    local s = f:read("*a")
    f:close()
    return s
end

local function check(cond, msg)
    if not cond then error("CHECK FAILED: " .. msg, 2) end
end

local tabs = read("core/interface/options/tabs.lua")
check(tabs:find('text = "Loot",%s+eventType = "loot"'), "Loot tab must use the event sound panel, not the placeholder")
check(not tabs:find("lootPanel", 1, true), "Loot placeholder panel must be gone")

local panel = read("core/interface/options/sound_panel.lua")
check(panel:find('eventType == "loot"', 1, true), "sound panel must build a loot page")
check(panel:find('"Appearance Collected Sound", dropY, "transmog"', 1, true), "loot page must offer the transmog category dropdown")
check(panel:find('loot = "collectibles"', 1, true), "loot tab toggle must drive the collectibles module")

local config = read("core/systems/config.lua")
check(config:find('transmog = "medium"', 1, true), "transmog volume default")
check(config:find('transmog = "Master"', 1, true), "transmog channel default")

print("loot-tab-appearance-test OK")
