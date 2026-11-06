-- BLU chat output must carry exactly one BLU prefix, even when a caller embeds its own tag.
local out = {}
_G.print = function(...) out[#out + 1] = table.concat({ ... }, " ") end
_G.CreateFrame = function() return setmetatable({}, { __index = function() return function() end end }) end
local src = assert(io.open("core/core.lua", "r")):read("*a")
local a = assert(src:find("local function StripEmbeddedPrefix", 1, true))
local b = assert(src:find("function BLU:NormalizeDebugScope", 1, true))
local CHAT_PREFIX, CHAT_ERROR_PREFIX = "[BLU]", "[BLU error]"
local BLU = {}
local chunk = assert(loadstring("local BLU, CHAT_PREFIX, CHAT_ERROR_PREFIX = ...\n" .. src:sub(a, b - 1) .. "\nreturn BLU"))
chunk(BLU, CHAT_PREFIX, CHAT_ERROR_PREFIX)
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end

BLU:Print("|cff00ccffBLU:|r Options cannot be opened in combat. Queued to open after combat.")
check(out[1] == "[BLU] Options cannot be opened in combat. Queued to open after combat.", "embedded colored tag is dropped, got: " .. tostring(out[1]))
BLU:Print("plain message")
check(out[2] == "[BLU] plain message", "plain messages are untouched")
BLU:Print("BLU: tagged without colour")
check(out[3] == "[BLU] tagged without colour", "plain 'BLU:' tag is dropped")
BLU:Print("|cff00ccffBLU:|r first |cff00ccffBLU:|r second")
check(out[4] == "[BLU] first |cff00ccffBLU:|r second", "only the leading tag is removed")
BLU:PrintError("|cff00ccffBLU:|r bad thing")
check(out[5] == "[BLU error] bad thing", "errors get the same treatment")
print = nil
io.write("chat-prefix-test OK\n")
