--v0.0.9
BLU.defaults = {
	profile = {
		LevelSoundSelect = 1,
		MuteLevelDefault = false,
		RepSoundSelect = 1,
		MuteRepDefault = false,
		RenownSoundSelect = 1,
		MuteRenownDefault = false,
	},
}
BLU.options = {
	type = "group",
	name = "Sound Settings",
	handler = BLU,
	args = {
		group1 = {
			type = "group",
			order = 1,
			name = "Level Up!",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
				LevelSoundSelect = {
					type = "select",
					order = 1,
					name = "",
					values = {"Default", "EverQuest", "Final Fantasy", "Fortnite", "Kingdom Hearts 3", "League of Legends", "Legend of Zelda", "Maplestory", "Minecraft", "Modern Warfare 2", "Morrowind", "Old School Runescape", "Path of Exile", "Pokemon", "Skyrim", "Sonic The Hedgehog", "Super Mario Bros 3", "Warcraft 3", "Witcher 3"},
				},
				TestLevelSound = {
					type = "execute",
					order = 2,
					name = "Test Level Sound",
					desc = "Test Currently Selected Sound File",
					func = TestLevelSound,
					},
				MuteLevelDefault = {
					type = "toggle",
					order = 3,
					name = "Mute Default",
					desc = "Mute Default Level Up Sound",
					get = function(info) return BLU.db.profile.MuteLevelDefault end,
					set = function(info, value) BLU.db.profile.MuteLevelDefault = value end,
				},
			},
		},
		group2 = {
			type = "group",
			order = 2,
			name = "Rep Up!",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
				RepSoundSelect = {
					type = "select",
					order = 1,
					name = "",
					values = {"Default", "EverQuest", "Final Fantasy", "Fortnite", "Kingdom Hearts 3", "League of Legends", "Legend of Zelda", "Maplestory", "Minecraft", "Modern Warfare 2", "Morrowind", "Old School Runescape", "Path of Exile", "Pokemon", "Skyrim", "Sonic The Hedgehog", "Super Mario Bros 3", "Warcraft 3", "Witcher 3"},
				},
				TestRepSound = {
					type = "execute",
					order = 2,
					name = "Test Rep Sound",
					desc = "Test Currently Selected Sound File",
					func = TestRepSound,
					},
				MuteRepDefault = {
					type = "toggle",
					order = 3,
					name = "Mute Default",
					desc = "Mute Default Rep Up Sound",
					get = function(info) return BLU.db.profile.MuteRepDefault end,
					set = function(info, value) BLU.db.profile.MuteRepDefault = value end,
				},
			},
		},
		group3 = {
			type = "group",
			order = 3,
			name = "Renown Up!",
			inline = true,
			get = "GetValue",
			set = "SetValue",
			args = {
				RenownSoundSelect = {
					type = "select",
					order = 1,
					name = "",
					values = {"Default", "EverQuest", "Final Fantasy", "Fortnite", "Kingdom Hearts 3", "League of Legends", "Legend of Zelda", "Maplestory", "Minecraft", "Modern Warfare 2", "Morrowind", "Old School Runescape", "Path of Exile", "Pokemon", "Skyrim", "Sonic The Hedgehog", "Super Mario Bros 3", "Warcraft 3", "Witcher 3"},
				},
				TestRenownSound = {
					type = "execute",
					order = 2,
					name = "Test Renown Sound",
					desc = "Test Currently Selected Sound File",
					func = TestRenownSound,
					},
				MuteRenownDefault = {
					type = "toggle",
					order = 3,
					name = "Mute Default",
					desc = "Mute Default Level Up Sound",
					get = function(info) return BLU.db.profile.MuteRenownDefault end,
					set = function(info, value) BLU.db.profile.MuteRenownDefault = value end,
				},
			},
		},
	},
}
function BLU:GetValue(info)
	return self.db.profile[info[#info]]
end
function BLU:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
