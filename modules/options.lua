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

    local yOffset = -60

    -- Achievement Group
    local achievementGroup = self:CreateOptionGroup(optionsFrame, "Achievement", yOffset)
    self:CreateOptionWidgets(achievementGroup, "Achievement", defaultSounds[1])
    yOffset = yOffset - 120

    -- Battle Pet Level Up Group
    local battlePetGroup = self:CreateOptionGroup(optionsFrame, "BattlePetLevel", yOffset)
    self:CreateOptionWidgets(battlePetGroup, "BattlePetLevel", defaultSounds[2])
    yOffset = yOffset - 120

    -- Honor Rank Up Group
    local honorGroup = self:CreateOptionGroup(optionsFrame, "Honor", yOffset)
    self:CreateOptionWidgets(honorGroup, "Honor", defaultSounds[5])
    yOffset = yOffset - 120

    -- Level Up Group
    local levelUpGroup = self:CreateOptionGroup(optionsFrame, "Level", yOffset)
    self:CreateOptionWidgets(levelUpGroup, "Level", defaultSounds[4])
    yOffset = yOffset - 120

    -- Quest Accepted Group
    local questAcceptedGroup = self:CreateOptionGroup(optionsFrame, "QuestAccept", yOffset)
    self:CreateOptionWidgets(questAcceptedGroup, "QuestAccept", defaultSounds[7])
    yOffset = yOffset - 120

    -- Quest Complete Group
    local questCompleteGroup = self:CreateOptionGroup(optionsFrame, "Quest", yOffset)
    self:CreateOptionWidgets(questCompleteGroup, "Quest", defaultSounds[8])
    yOffset = yOffset - 120

    -- Renown Rank Up Group
    local renownGroup = self:CreateOptionGroup(optionsFrame, "Renown", yOffset)
    self:CreateOptionWidgets(renownGroup, "Renown", defaultSounds[6])
    yOffset = yOffset - 120

    -- Reputation Rank Up Group
    local reputationGroup = self:CreateOptionGroup(optionsFrame, "Rep", yOffset)
    self:CreateOptionWidgets(reputationGroup, "Rep", defaultSounds[6])
    yOffset = yOffset - 120

    -- Trading Post Group
    local tradingPostGroup = self:CreateOptionGroup(optionsFrame, "Post", yOffset)
    self:CreateOptionWidgets(tradingPostGroup, "Post", defaultSounds[9])
end

function options:CreateOptionGroup(parent, name, yOffset)
    local group = CreateFrame("Frame", parent:GetName() .. name .. "Group", parent)
    group:SetSize(500, 100)
    group:SetPoint("TOPLEFT", 20, yOffset)

    local label = group:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetText(BLU_L[name .. "_LABEL"] or name)

    return group
end

function options:CreateOptionWidgets(parent, name, defaultSound)
    local addon = self.addon

    local dropdown = BLULib.Options.CreateDropdown(parent, name .. "SoundSelect", soundOptions, function() return addon.db.profile[name .. "SoundSelect"] end, function(value) addon.db.profile[name .. "SoundSelect"] = value end)
    dropdown:SetPoint("TOPLEFT", 20, -30)

    local testButton = BLULib.Options.CreateButton(parent, "Test" .. name .. "Sound", function() BLULib.Utils.TestSound(addon, name .. "SoundSelect", name .. "Volume", defaultSound, "TEST_" .. name:upper() .. "_SOUND") end)
    testButton:SetPoint("LEFT", dropdown, "RIGHT", 10, 0)

    local slider = BLULib.Options.CreateSlider(parent, name .. "Volume", 0, 3, 1, function() return addon.db.profile[name .. "Volume"] end, function(value) addon.db.profile[name .. "Volume"] = value end)
    slider:SetPoint("LEFT", testButton, "RIGHT", 10, 0)
end

BLULib = BLULib or {}
BLULib.OptionsModule = options
