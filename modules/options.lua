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

    local optionGroups = {
        { name = "ACHIEVEMENT_EARNED", key = "Achievement", defaultSound = defaultSounds[1] },
        { name = "BATTLE_PET_LEVEL_UP", key = "BattlePetLevel", defaultSound = defaultSounds[2] },
        { name = "HONOR_RANK_UP", key = "Honor", defaultSound = defaultSounds[5] },
        { name = "LEVEL_UP", key = "Level", defaultSound = defaultSounds[4] },
        { name = "QUEST_ACCEPTED", key = "QuestAccept", defaultSound = defaultSounds[7] },
        { name = "QUEST_COMPLETE", key = "Quest", defaultSound = defaultSounds[8] },
        { name = "RENOWN_RANK_UP", key = "Renown", defaultSound = defaultSounds[6] },
        { name = "REPUTATION_RANK_UP", key = "Rep", defaultSound = defaultSounds[6] },
        { name = "TRADE_POST_ACTIVITY_COMPLETE", key = "Post", defaultSound = defaultSounds[9] },
    }

    local colors = { "|cff05dffa", "|cffffffff" }
    local colorIndex = 1
    local yOffset = -60

    for _, groupInfo in ipairs(optionGroups) do
        local group = BLULib.Options.CreateGroup(optionsFrame, addon.L[groupInfo.name], yOffset, colors[colorIndex])
        self:CreateOptionWidgets(group, groupInfo.key, groupInfo.defaultSound)
        yOffset = yOffset - 120
        colorIndex = colorIndex % 2 + 1
    end
end

function options:CreateOptionWidgets(parent, key, defaultSound)
    local addon = self.addon

    local dropdown = BLULib.Options.CreateDropdown(parent, key .. "SoundSelect", soundOptions, function() return addon.db.profile[key .. "SoundSelect"] end, function(value) addon.db.profile[key .. "SoundSelect"] = value end)
    dropdown:SetPoint("TOPLEFT", 20, -40)

    local testButton = BLULib.Options.CreateButton(parent, "Test" .. key .. "Sound", function() BLULib.Utils.TestSound(addon, key .. "SoundSelect", key .. "Volume", defaultSound, "TEST_" .. key:upper() .. "_SOUND") end)
    testButton:SetPoint("LEFT", dropdown, "RIGHT", 150, 0)

    local slider = BLULib.Options.CreateSlider(parent, key .. "Volume", 0, 3, 1, function() return addon.db.profile[key .. "Volume"] end, function(value) addon.db.profile[key .. "Volume"] = value end)
    slider:SetPoint("LEFT", testButton, "RIGHT", 50, 0)
end

BLULib = BLULib or {}
BLULib.OptionsModule = options
