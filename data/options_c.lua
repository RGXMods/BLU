--=====================================================================================
-- Default Profile Settings
--=====================================================================================
BLU.defaults = {
    profile = {
        AchievementSoundSelect = 35,
        AchievementVolume = 2.0,
        LevelSoundSelect = 24,
        LevelVolume = 2.0,
        RepSoundSelect = 15,
        RepVolume = 2.0,
        QuestAcceptSoundSelect = 26,
        QuestAcceptVolume = 2.0,
        QuestSoundSelect = 25,
        QuestVolume = 2.0,
    },
}

--=====================================================================================
-- Options Definition
--=====================================================================================
BLU.options = {
    type = "group",
    name = "",
    handler = BLU,
    args = {
        group1 = {
            type = "header",
            order = 1,
            name = "|cff05dffaBLU|r |cffffffff|| |cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!|r",
        },
        group2 = {
            type = "group",
            order = 2,
            name = "|cffffffffAchievement Earned!|r",
            inline = true,
            get = "GetValue",
            set = "SetValue",
            args = {
                AchievementSoundSelect = {
                    type = "select",
                    order = 1,
                    name = "",
                    desc = "|cff05dffaSelect a sound to play when an Achievement is earned!|r",
                    values = soundOptions,
                },
                TestAchievementSound = {
                    type = "execute",
                    order = 2,
                    image = "Interface\\Addons\\BLU\\images\\play.blp",
                    imageWidth = 20,
                    imageHeight = 20,
                    name = "",
                    desc = "Test Achievement Earned Sound!",
                    func = TestAchievementSound,
                },
                AchievementVolume = {
                    type = "range",
                    order = 3,
                    name = "|cffffffffVolume|r",
                    desc = "|cff05dffaAdjust Achievement Earned! Sound Volume!|r",
                    min = 0,
                    max = 3,
                    step = 1,
                },
            },
        },
		group3 = {
			type = "group",
			order = 3,
			name = "|cff05dffaLevel-Up!|r",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
                LevelSoundSelect = {
                    type = "select",
                    order = 1,
                    name = "",
                    values = soundOptions,
                },
                TestLevelSound = {
                    type = "execute",
                    order = 2,
                    image = "Interface\\Addons\\BLU\\images\\play.blp",
                    imageWidth = 20,
                    imageHeight = 20,
                    name = "",
                    desc = "",
                    func = TestLevelSound,
                },
                LevelVolume = {
                    type = "range",
                    order = 3,
                    name = "|cff05dffaVolume|r",
                    desc = "|cffffffffAdjust Level-Up! Sound Volume|r",
                    min = 0,
                    max = 3, 
                    step = 1,
                },
            },
        },
		group4 = {
			type = "group",
			order = 4,
			name = "|cffffffffReputation Rank-Up!|r",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
                RepSoundSelect = {
                    type = "select",
                    order = 1,
                    name = "",
                    values = soundOptions,
                },
                TestRepSound = {
                    type = "execute",
                    order = 2,
                    image = "Interface\\Addons\\BLU\\images\\play.blp",
                    imageWidth = 20,
                    imageHeight = 20,
                    name = "",
                    desc = "",
                    func = TestRepSound,
                },
                RepVolume = {
                    type = "range",
                    order = 3,
                    name = "|cffffffffVolume|r",
                    desc = "|cff05dffaAdjust Reputation Rank-Up! Sound Volume|r",
                    min = 0,
                    max = 3, 
                    step = 1,
                },
            },
        },
		group5 = {
			type = "group",
			order = 5,
			name = "|cff05dffaQuest Accepted!|r",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
                QuestAcceptSoundSelect = {
                    type = "select",
                    order = 1,
                    name = "",
                    values = soundOptions,
                },
                TestQuestAcceptSound = {
                    type = "execute",
                    order = 2,
                    image = "Interface\\Addons\\BLU\\images\\play.blp",
                    imageWidth = 20,
                    imageHeight = 20,
                    name = "",
                    desc = "",
                    func = TestQuestAcceptSound,
                },
                QuestAcceptVolume = {
                    type = "range",
                    order = 3,
                    name = "|cff05dffaVolume|r",
                    desc = "|cffffffffAdjust Quest Accepted! Sound Volume|r",
                    min = 0,
                    max = 3, 
                    step = 1,
                },
            },
        },
		group6 = {
			type = "group",
			order = 6,
			name = "|cffffffffQuest Turn-In!|r",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
                QuestSoundSelect = {
                    type = "select",
                    order = 1,
                    name = "",
                    values = soundOptions,
                },
                TestQuestSound = {
                    type = "execute",
                    order = 2,
                    image = "Interface\\Addons\\BLU\\images\\play.blp",
                    imageWidth = 20,
                    imageHeight = 20,
                    name = "",
                    desc = "",
                    func = TestQuestSound,
                },
                QuestVolume = {
                    type = "range",
                    order = 3,
                    name = "|cffffffffVolume|r",
                    desc = "|cff05dffaAdjust Quest Turn-In! Sound Volume|r",
                    min = 0,
                    max = 3, 
                    step = 1,
                },
            },
        },
		group7 = {
			type = "header",
			order = 7,
			name = "|cff8080ff" .. VersionNumber .. "|r",
		},
	},
}
--=====================================================================================
--=====================================================================================
function BLU:GetValue(info)
	return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
	self.db.profile[info[#info]] = value
end