-- modules/options.lua
local options = {}

options.defaults = {
    profile = {
        debugMode = false,
        showWelcomeMessage = true,
        AchievementSoundSelect = 35,
        AchievementVolume = 2.0,
        BattlePetLevelSoundSelect = 37,
        BattlePetLevelVolume = 2.0,
        HonorSoundSelect = 27,
        HonorVolume = 2.0,
        LevelSoundSelect = 24,
        LevelVolume = 2.0,
        PostSoundSelect = 55,
        PostVolume = 2.0,
        QuestAcceptSoundSelect = 26,
        QuestAcceptVolume = 2.0,
        QuestSoundSelect = 25,
        QuestVolume = 2.0,
        RenownSoundSelect = 21,
        RenownVolume = 2.0,
        RepSoundSelect = 15,
        RepVolume = 2.0,
    },
}

function options:OnEnable()
    self.addon:Print("Options module enabled!")
    self:CreateOptions()
end

function options:CreateOptions()
    local addon = self.addon
    local optionsFrame = addon.optionsFrame

    -- Achievement Group
    local achievementGroup = CreateFrame("Frame", optionsFrame:GetName() .. "AchievementGroup", optionsFrame)
    achievementGroup:SetSize(500, 100)
    achievementGroup:SetPoint("TOPLEFT", 20, -60)

    local achievementLabel = achievementGroup:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    achievementLabel:SetPoint("TOPLEFT", 0, 0)
    achievementLabel:SetText(BLU_L["ACHIEVEMENT_EARNED"])

    local achievementDropdown = BLULib.Options.CreateDropdown(achievementGroup, "AchievementSoundSelect", soundOptions, function() return addon.db.profile.AchievementSoundSelect end, function(value) addon.db.profile.AchievementSoundSelect = value end)
    achievementDropdown:SetPoint("TOPLEFT", 20, -30)

    local achievementTestButton = BLULib.Options.CreateButton(achievementGroup, "TestAchievementSound", function() BLULib.Utils.TestSound(addon, "AchievementSoundSelect", "AchievementVolume", defaultSounds[1], "TEST_ACHIEVEMENT_SOUND") end)
    achievementTestButton:SetPoint("LEFT", achievementDropdown, "RIGHT", 10, 0)

    local achievementSlider = BLULib.Options.CreateSlider(achievementGroup, "AchievementVolume", 0, 3, 1, function() return addon.db.profile.AchievementVolume end, function(value) addon.db.profile.AchievementVolume = value end)
    achievementSlider:SetPoint("LEFT", achievementTestButton, "RIGHT", 10, 0)
end

BLULib = BLULib or {}
BLULib.OptionsModule = options
