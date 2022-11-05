BLU.defaults = {
	profile = {
		LevelSoundSelect = 1, -- final fantasy
		MuteLevelDefault = false,
		RepSoundSelect = 1, -- final fantasy
		MuteRepDefault = false,
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
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
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				LevelSoundSelect = {
					type = "select",
					order = 1,
					name = "",
					values = {"Final Fantasy", "Kingdom Hearts 3", "Maplestory", "Fortnite", "League of Legends", "Minecraft", "Modern Warfare 2", "Morrowind", "Old School Runescape", "Pokemon", "Path of Exile", "Sonic The Hedgehog", "Super Mario Bros 3", "Skyrim", "Warcraft 3"},
				},
				MuteLevelDefault = {
					type = "toggle",
					order = 2,
					name = "Mute Default",
					desc = "Mute Default Level Up Sound",
					-- inline getter/setter example
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
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				RepSoundSelect = {
					type = "select",
					order = 1,
					name = "",
					values = {"Final Fantasy", "Kingdom Hearts 3", "Maplestory", "Fortnite", "League of Legends", "Minecraft", "Modern Warfare 2", "Morrowind", "Old School Runescape", "Pokemon", "Path of Exile", "Sonic The Hedgehog", "Super Mario Bros 3", "Skyrim", "Warcraft 3"},
				},
				MuteRepDefault = {
					type = "toggle",
					order = 2,
					name = "Mute Default",
					desc = "Mute Default Rep Up Sound",
					-- inline getter/setter example
					get = function(info) return BLU.db.profile.MuteRepDefault end,
					set = function(info, value) BLU.db.profile.MuteRepDefault = value end,
				},
			},
		},
	},
}



-- for documentation on the info table
-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function BLU:GetValue(info)
	return self.db.profile[info[#info]]
end

function BLU:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
