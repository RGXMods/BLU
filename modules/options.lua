-- modules/options.lua
local addonName = ...
local BLU = _G["BLU"]

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
    self.addon:PrintDebug("Options module enabled!")
    BLULib.Options.Create(self.addon) -- Create the panel
    self:CreateOptions() -- Populate with widgets
end

function options:CreateOptions() 
    local addon = self.addon
    local soundsModule = addon:GetModule("Sounds")

    local optionsLayout = {
        { type = "header", text = addon.L["OPTIONS_PANEL_TITLE"] },
        { type = "group", name = "ACHIEVEMENT_EARNED", key = "Achievement", defaultSound = soundsModule.defaultSounds[1] },
        { type = "group", name = "BATTLE_PET_LEVEL_UP", key = "BattlePetLevel", defaultSound = soundsModule.defaultSounds[2] },
        { type = "group", name = "HONOR_RANK_UP", key = "Honor", defaultSound = soundsModule.defaultSounds[4] },
        { type = "group", name = "LEVEL_UP", key = "Level", defaultSound = soundsModule.defaultSounds[5] },
        { type = "group", name = "QUEST_ACCEPTED", key = "QuestAccept", defaultSound = soundsModule.defaultSounds[7] },
        { type = "group", name = "QUEST_COMPLETE", key = "Quest", defaultSound = soundsModule.defaultSounds[8] },
        { type = "group", name = "RENOWN_RANK_UP", key = "Renown", defaultSound = soundsModule.defaultSounds[6] },
        { type = "group", name = "REPUTATION_RANK_UP", key = "Rep", defaultSound = soundsModule.defaultSounds[6] },
        { type = "group", name = "TRADE_POST_ACTIVITY_COMPLETE", key = "Post", defaultSound = soundsModule.defaultSounds[9] },
        { type = "header", text = "|cff8080ff" .. GetAddOnMetadata(addon.name, "Version") .. "|r" },
    }

    local colors = { "|cff05dffa", "|cffffffff" }
    local colorIndex = 1
    local yOffset = -60

    for _, item in ipairs(optionsLayout) do
        if item.type == "header" then
            BLULib.Options.CreateHeader(addon.optionsFrame, item.text, yOffset)
            yOffset = yOffset - 40
        elseif item.type == "group" then
            local group = BLULib.Options.CreateGroup(addon.optionsFrame, addon.L[item.name], yOffset, colors[colorIndex])
            self:CreateOptionWidgets(group, item.key, item.defaultSound, soundsModule.soundOptions)
            yOffset = yOffset - 120
            colorIndex = (colorIndex % 2) + 1
        end
    end
end

function options:CreateOptionWidgets(parent, key, defaultSound, soundOptions)
    local addon = self.addon
    local dropdown = BLULib.Options.CreateDropdown(parent, key .. "SoundSelect", soundOptions, function() return addon.db.profile[key .. "SoundSelect"] end, function(value) addon.db.profile[key .. "SoundSelect"] = value end)
    dropdown:SetPoint("TOPLEFT", 20, -40)

    local testButton = BLULib.Options.CreateImageButton(parent, "Test" .. key .. "Sound", "Interface\Addons\BLU\images\play.blp", function() BLULib.Utils.TestSound(addon, key .. "SoundSelect", key .. "Volume", defaultSound, "TEST_" .. key:upper() .. "_SOUND") end)
    testButton:SetPoint("LEFT", dropdown, "RIGHT", 150, 0)

    local slider = BLULib.Options.CreateSlider(parent, addon.L[key:upper() .. "_VOLUME_LABEL"], 0, 3, 1, function() return addon.db.profile[key .. "Volume"] end, function(value) addon.db.profile[key .. "Volume"] = value end)
    slider:SetPoint("LEFT", testButton, "RIGHT", 20, 0)
end

BLULib = BLULib or {}
BLULib.CoreModule = core