--v0.0.11
BLU = LibStub("AceAddon-3.0"):NewAddon("BLU", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
function BLU:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("BLUDB", self.defaults, true)
	AC:RegisterOptionsTable("BLU_Options", self.options)
	self.optionsFrame = ACD:AddToBlizOptions("BLU_Options", "Better Level Up!")
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	AC:RegisterOptionsTable("BLU_Profiles", profiles)
	ACD:AddToBlizOptions("BLU_Profiles", "Profiles", "Better Level Up!")
	self:RegisterChatCommand("lu", "SlashCommand")
	self:RegisterChatCommand("blu", "SlashCommand")
end
function BLU:OnEnable()
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	self:RegisterEvent("ACHIEVEMENT_EARNED")
end
function BLU:PLAYER_LEVEL_UP(self, event, ...)
	if BLU.db.profile.LevelSoundSelect == 1 then
			PlaySoundFile(569593)
		elseif BLU.db.profile.LevelSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function BLU:QUEST_TURNED_IN(self, event, ...)
	if BLU.db.profile.QuestSoundSelect == 1 then
			PlaySoundFile(567439)
		elseif BLU.db.profile.QuestSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
local TrackedFactions={};
local Event_Frame_Rep=CreateFrame("Frame");
Event_Frame_Rep:RegisterEvent("PLAYER_LOGIN");
Event_Frame_Rep:RegisterEvent("UPDATE_FACTION");
Event_Frame_Rep:RegisterEvent("QUEST_LOG_UPDATE");
Event_Frame_Rep:SetScript("OnEvent",
	function()
	   for i=1,GetNumFactions() do
	       local _,_,newstanding,_,_,_,_,_,isheader,_,hasrep,_,_,faction=GetFactionInfo(i);
	       if faction and (not isheader or hasrep) and (newstanding or 0)>0 then
	           local oldstanding=TrackedFactions[faction];
						 		if oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 1 then
	                	PlaySoundFile(568016)
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 2 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
	           			elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 3 then
	                	PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 4 then
			             	PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 5 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 6 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 7 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 8 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 9 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 10 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 11 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 12 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 13 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 14 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 15 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 16 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 17 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 18 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 19 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	           		end
	           TrackedFactions[faction]=newstanding;
	       end
	   end
end);
function BLU:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(self, event, ...)
		if BLU.db.profile.RenownSoundSelect == 1 then
				PlaySoundFile(569593)
			elseif BLU.db.profile.RenownSoundSelect == 2 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 3 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 4 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 5 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 6 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 7 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 8 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 9 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 10 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 11 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 12 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 13 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 14 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 15 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 16 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 17 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 18 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
			elseif BLU.db.profile.RenownSoundSelect == 19 then
				PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
		end
end
function BLU:ACHIEVEMENT_EARNED(self, event, ...)
	if BLU.db.profile.AchievementSoundSelect == 1 then
			PlaySoundFile(569143)
		elseif BLU.db.profile.AchievementSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function TestLevelSound()
	if BLU.db.profile.LevelSoundSelect == 1 then
			PlaySoundFile(569593)
		elseif BLU.db.profile.LevelSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.LevelSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function TestRepSound()
	if BLU.db.profile.RepSoundSelect == 1 then
			PlaySoundFile(568016)
		elseif BLU.db.profile.RepSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.RepSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function TestRenownSound()
	if BLU.db.profile.RenownSoundSelect == 1 then
			PlaySoundFile(4745441)
		elseif BLU.db.profile.RenownSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.RenownSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function TestQuestSound()
	if BLU.db.profile.QuestSoundSelect == 1 then
			PlaySoundFile(567439)
		elseif BLU.db.profile.QuestSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.QuestSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
function TestAchievementSound()
	if BLU.db.profile.AchievementSoundSelect == 1 then
			PlaySoundFile(569143)
		elseif BLU.db.profile.AchievementSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "SFX")
		elseif BLU.db.profile.AchievementSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "SFX")
	end
end
local Event_Frame_Mute_Level=CreateFrame("Frame");
Event_Frame_Mute_Level:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Mute_Level:SetScript("OnEvent",function()
	if BLU.db.profile.MuteLevelDefault == true then
			MuteSoundFile(569593)
	end
end);
local Event_Frame_Mute_Rep=CreateFrame("Frame");
Event_Frame_Mute_Rep:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Mute_Rep:SetScript("OnEvent",function()
	if BLU.db.profile.MuteRepDefault == true then
			MuteSoundFile(568016)
	end
end);
local Event_Frame_Mute_Renown=CreateFrame("Frame");
Event_Frame_Mute_Rep:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Mute_Rep:SetScript("OnEvent",function()
	if BLU.db.profile.MuteRenownDefault == true then
			MuteSoundFile(213204)
			MuteSoundFile(4745441)
			MuteSoundFile(4745443)
			MuteSoundFile(4745445)
	end
end);
local Event_Frame_Mute_Quest=CreateFrame("Frame");
Event_Frame_Mute_Quest:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Mute_Quest:SetScript("OnEvent",function()
	if BLU.db.profile.MuteQuestDefault == true then
			MuteSoundFile(567439)
	end
end);
local Event_Frame_Mute_Achievement=CreateFrame("Frame");
Event_Frame_Mute_Achievement:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Mute_Achievement:SetScript("OnEvent",function()
	if BLU.db.profile.MuteAchievementDefault == true then
			MuteSoundFile(569143)
	end
end);
local Event_Frame_Unmute_Level=CreateFrame("Frame");
Event_Frame_Unmute_Level:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Unmute_Level:SetScript("OnEvent",function()
	if BLU.db.profile.MuteLevelDefault == false then
			UnmuteSoundFile(569593)
	end
end);
local Event_Frame_Unmute_Rep=CreateFrame("Frame");
Event_Frame_Unmute_Rep:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Unmute_Rep:SetScript("OnEvent",function()
	if BLU.db.profile.MuteRepDefault == false then
			UnmuteSoundFile(568016)
	end
end);
local Event_Frame_Unmute_Renown=CreateFrame("Frame");
Event_Frame_Unmute_Renown:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Unmute_Renown:SetScript("OnEvent",function()
	if BLU.db.profile.MuteRenownDefault == false then
			UnmuteSoundFile(213204)
			UnmuteSoundFile(4745441)
			UnmuteSoundFile(4745443)
			UnmuteSoundFile(4745445)
	end
end);
local Event_Frame_Unmute_Quest=CreateFrame("Frame");
Event_Frame_Unmute_Quest:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Unmute_Quest:SetScript("OnEvent",function()
	if BLU.db.profile.MuteQuestDefault == false then
			UnmuteSoundFile(567439)
	end
end);
local Event_Frame_Unmute_Achievement=CreateFrame("Frame");
Event_Frame_Unmute_Achievement:RegisterEvent("PLAYER_STARTED_MOVING");
Event_Frame_Unmute_Achievement:SetScript("OnEvent",function()
	if BLU.db.profile.MuteAchievementDefault == false then
			UnmuteSoundFile(569143)
	end
end);
function BLU:SlashCommand(input, editbox)
	if input == "enable" then
			self:Enable()
			self:Print("Enabled.")
		elseif input == "disable" then
			self:Disable()
			self:Print("Disabled.")
		else
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
end
