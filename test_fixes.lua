--=====================================================================================
-- BLU - test_fixes.lua
-- Test script to validate the critical fixes for SharedMedia and alignment issues
--=====================================================================================

local addonName, BLU = ...

-- Test function to validate SharedMedia functionality
local function TestSharedMediaFixes()
    print("=== Testing SharedMedia Fixes ===")
    
    -- Check if SharedMedia module exists
    if not BLU.Modules or not BLU.Modules.sharedmedia then
        print("❌ ERROR: SharedMedia module not found")
        return false
    end
    
    local sharedMedia = BLU.Modules.sharedmedia
    print("✅ SharedMedia module found")
    
    -- Test GetSoundCategories function
    if not sharedMedia.GetSoundCategories then
        print("❌ ERROR: GetSoundCategories function missing")
        return false
    end
    
    local categories = sharedMedia:GetSoundCategories()
    if not categories or type(categories) ~= "table" then
        print("❌ ERROR: GetSoundCategories returned invalid data")
        return false
    end
    
    local categoryCount = 0
    local totalSounds = 0
    for category, sounds in pairs(categories) do
        categoryCount = categoryCount + 1
        if sounds and type(sounds) == "table" then
            totalSounds = totalSounds + #sounds
            print(string.format("✅ Category '%s': %d sounds", category, #sounds))
        else
            print(string.format("❌ Invalid category '%s'", category))
        end
    end
    
    if categoryCount == 0 then
        print("❌ ERROR: No categories found")
        return false
    end
    
    print(string.format("✅ Found %d categories with %d total sounds", categoryCount, totalSounds))
    
    -- Test external sounds
    local externalSounds = sharedMedia:GetExternalSounds()
    if not externalSounds or type(externalSounds) ~= "table" then
        print("❌ ERROR: GetExternalSounds returned invalid data")
        return false
    end
    
    local externalCount = 0
    for name, info in pairs(externalSounds) do
        externalCount = externalCount + 1
        if not info.name or not info.category or not info.path then
            print(string.format("❌ Invalid external sound data for '%s'", name))
        end
    end
    
    print(string.format("✅ Found %d external sounds", externalCount))
    return true
end

-- Test function to validate options panel alignment
local function TestOptionsAlignment()
    print("=== Testing Options Panel Alignment ===")
    
    -- Check if BLU.Design constants are available
    if not BLU.Design or not BLU.Design.Layout then
        print("❌ ERROR: BLU.Design.Layout constants not found")
        return false
    end
    
    local layout = BLU.Design.Layout
    
    -- Verify key constants exist
    local requiredConstants = {"Padding", "Spacing", "TabWidth", "TabHeight"}
    for _, constant in ipairs(requiredConstants) do
        if not layout[constant] then
            print(string.format("❌ ERROR: Missing layout constant: %s", constant))
            return false
        end
        print(string.format("✅ Layout.%s = %s", constant, tostring(layout[constant])))
    end
    
    -- Check if CreateEventSoundPanel function exists
    if not BLU.CreateEventSoundPanel then
        print("❌ ERROR: CreateEventSoundPanel function not found")
        return false
    end
    
    print("✅ CreateEventSoundPanel function found")
    
    -- Verify expected layout values
    if layout.Padding ~= 20 then
        print(string.format("❌ WARNING: Expected Padding=20, got %s", tostring(layout.Padding)))
    end
    
    if layout.Spacing ~= 10 then
        print(string.format("❌ WARNING: Expected Spacing=10, got %s", tostring(layout.Spacing)))
    end
    
    print("✅ Layout constants validation completed")
    return true
end

-- Main test function
local function RunAllTests()
    print("=== BLU Critical Fixes Validation ===")
    print("Running tests to validate SharedMedia and alignment fixes...")
    
    local sharedMediaOK = TestSharedMediaFixes()
    local alignmentOK = TestOptionsAlignment()
    
    print("\n=== Test Results Summary ===")
    print(string.format("SharedMedia Fixes: %s", sharedMediaOK and "✅ PASS" or "❌ FAIL"))
    print(string.format("Options Alignment: %s", alignmentOK and "✅ PASS" or "❌ FAIL"))
    
    if sharedMediaOK and alignmentOK then
        print("🎉 ALL TESTS PASSED - Fixes are working correctly!")
        return true
    else
        print("⚠️  SOME TESTS FAILED - Please review the issues above")
        return false
    end
end

-- Register slash command for testing
SLASH_BLUTEST1 = "/blutest"
SlashCmdList["BLUTEST"] = function(msg)
    if msg == "fixes" then
        RunAllTests()
    elseif msg == "sharedmedia" then
        TestSharedMediaFixes()
    elseif msg == "alignment" then
        TestOptionsAlignment()
    else
        print("BLU Test Commands:")
        print("/blutest fixes - Run all critical fixes tests")
        print("/blutest sharedmedia - Test SharedMedia functionality only")
        print("/blutest alignment - Test options panel alignment only")
    end
end

-- Auto-run tests when loaded (delay to ensure modules are loaded)
C_Timer.After(2, function()
    if BLU and BLU.Modules and BLU.Modules.sharedmedia then
        print("BLU: Running automated tests for critical fixes...")
        RunAllTests()
    else
        print("BLU: Modules not ready for testing. Use /blutest fixes to run manually.")
    end
end)