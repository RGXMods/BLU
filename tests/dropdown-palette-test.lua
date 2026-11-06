-- BLU dropdown menus and card headers must use BLU's palette, not the framework default.
local function read(path)
    local f = assert(io.open(path, "rb")); local s = f:read("*a"); f:close(); return s
end
local function check(cond, msg) if not cond then error("CHECK FAILED: " .. msg, 2) end end

local design = read("core/interface/design.lua")
check(design:find("Design.ListSkin = {", 1, true), "design defines ListSkin")
check(design:find("Design.InlineButtonColors = {", 1, true), "design defines InlineButtonColors")
check(design:find("header:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)", 1, true), "card header border matches the card and controls")
check(not design:find("header:SetBackdropBorderColor(unpack(Design.Colors.Accent))", 1, true), "card header no longer uses the mismatched accent border")

for _, path in ipairs({ "core/interface/options/sound_panel.lua", "core/interface/options/combat.lua", "core/interface/options/profiles.lua" }) do
    local s = read(path)
    local calls, skinned = 0, 0
    for block in s:gmatch("Drops:ForceWidth%b()") do
        calls = calls + 1
        if block:find("skin = BLU.Modules.design.ListSkin", 1, true) then skinned = skinned + 1 end
    end
    check(calls > 0, path .. " has ForceWidth calls")
    check(calls == skinned, path .. ": every ForceWidth call must pass the BLU list skin (" .. skinned .. "/" .. calls .. ")")
end
print("palette-test OK")
