-- Shipped code uses the framework's budgeted, labelled timers (RGX:After), never raw C_Timer.
local function check(c, m) if not c then error("CHECK FAILED: " .. m, 2) end end
local p = io.popen('grep -rln "C_Timer" core modules 2>/dev/null')
local hits = {}
for line in p:lines() do hits[#hits + 1] = line end
p:close()
check(#hits == 0, "raw C_Timer in shipped code: " .. table.concat(hits, ", "))
print("no-raw-timers-test OK")
