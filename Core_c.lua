--v0.0.18
------------------------------------------------------Options/Profiles/Database
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
---------------------------------------------------------Slash Commands
	self:RegisterChatCommand("lu", "SlashCommand")
	self:RegisterChatCommand("blu", "SlashCommand")
---------------------------------------------------------Slash Commands
end
------------------------------------------------------Options/Profiles/Database
----------------------------------------------------------------Register Events
function BLU:OnEnable()
	self:RegisterEvent("ACHIEVEMENT_EARNED")
	self:RegisterEvent("GLOBAL_MOUSE_DOWN")
	self:RegisterEvent("PLAYER_LEVEL_UP")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("UPDATE_FACTION")
end
----------------------------------------------------------------Register Events
------------------------------------------------------------------Login Message
function BLU:PLAYER_LOGIN(...)
	DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cff05dffaThank you for Downloading BLU!|r Enter '|cff05dffa/blu|r' to Select |cff05dffaL|revel |cff05dffaU|rp Sounds!");
	DEFAULT_CHAT_FRAME:AddMessage("|cff05dffaB|r|cffffffffetter|r |cff05dffaL|r|cffffffffevel|r |cff05dffaU|r|cffffffffp!: |cffdc143cNOTE|r: You may have to re-select a previously selected sound after |cffdc143cA|rddon |cffdc143cU|rpdates.");
end
------------------------------------------------------------------Login Message
-------------------------------------------------------------Achievement Earned
function BLU:ACHIEVEMENT_EARNED(self, event, ...)
	if BLU.db.profile.AchievementSoundSelect == 1 then
			PlaySoundFile(569143)
		elseif BLU.db.profile.AchievementSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
function TestAchievementSound()
	if BLU.db.profile.AchievementSoundSelect == 1 then
			PlaySoundFile(569143)
		elseif BLU.db.profile.AchievementSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.AchievementSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
-------------------------------------------------------------Achievement Earned
-----------------------------------------------------------------------Level Up
function BLU:PLAYER_LEVEL_UP(self, event, ...)
	if BLU.db.profile.LevelSoundSelect == 1 then
			PlaySoundFile(569593)
		elseif BLU.db.profile.LevelSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
function TestLevelSound()
	if BLU.db.profile.LevelSoundSelect == 1 then
			PlaySoundFile(569593)
		elseif BLU.db.profile.LevelSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.LevelSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
-----------------------------------------------------------------------Level Up
------------------------------------------------------------------Reputation Up
local TrackedFactions={};
function BLU:UPDATE_FACTION(self, event, ...)
	   for i=1,GetNumFactions() do
	       local _,_,newstanding,_,_,_,_,_,isheader,_,hasrep,_,_,faction=GetFactionInfo(i);
	       if faction and (not isheader or hasrep) and (newstanding or 0)>0 then
	           local oldstanding=TrackedFactions[faction];
						 		if oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 1 then
	                	PlaySoundFile(568016)
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 2 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 3 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
	           			elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 4 then
	                	PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 5 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 6 then
			             	PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 7 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 8 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 9 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 10 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 11 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 12 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 13 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 14 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 15 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 16 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 17 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 18 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 19 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 20 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
									elseif oldstanding and oldstanding<newstanding and BLU.db.profile.RepSoundSelect == 21 then
										PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	           		end
	           TrackedFactions[faction]=newstanding;
	       end
	   end
end
function TestRepSound()
	if BLU.db.profile.RepSoundSelect == 1 then
			PlaySoundFile(568016)
		elseif BLU.db.profile.RepSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.RepSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
------------------------------------------------------------------Reputation Up
-----------------------------------------------------------------Quest Accepted
function BLU:QUEST_ACCEPTED(self, event, ...)
	if BLU.db.profile.QuestAcceptSoundSelect == 1 then
			PlaySoundFile(567400)
		elseif BLU.db.profile.QuestAcceptSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
function TestQuestAcceptSound()
	if BLU.db.profile.QuestAcceptSoundSelect == 1 then
			PlaySoundFile(567400)
		elseif BLU.db.profile.QuestAcceptSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestAcceptSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
-----------------------------------------------------------------Quest Accepted
------------------------------------------------------------------Quest Turn-In
function BLU:QUEST_TURNED_IN(self, event, ...)
	if BLU.db.profile.QuestSoundSelect == 1 then
			PlaySoundFile(567439)
		elseif BLU.db.profile.QuestSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
function TestQuestSound()
	if BLU.db.profile.QuestSoundSelect == 1 then
			PlaySoundFile(567439)
		elseif BLU.db.profile.QuestSoundSelect == 2 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\DotA2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 3 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\EQLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 4 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 5 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FFFLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 6 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\FNLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 7 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\KH3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 8 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoLLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 9 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\LoZN64.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 10 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 11 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MCLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 12 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MW2LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 13 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\MWLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 14 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\OSRSLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 15 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PoELU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 16 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\PkmnLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 17 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SRLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 18 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SHHLU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 19 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\SMB3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 20 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\WC3LU.ogg", "MASTER")
		elseif BLU.db.profile.QuestSoundSelect == 21 then
			PlaySoundFile("Interface\\Addons\\BLU\\Sounds\\W3LU.ogg", "MASTER")
	end
end
------------------------------------------------------------------Quest Turn-In
------------------------------------------------------------------Mute Defaults
function BLU:GLOBAL_MOUSE_DOWN(self, event, ...)
-----------------------------------------------------Achievement Earned
	if BLU.db.profile.MuteAchievementDefault == true then
			MuteSoundFile(569143)
		elseif BLU.db.profile.MuteAchievementDefault == false then
			UnmuteSoundFile(569143)
	end
-----------------------------------------------------Achievement Earned
---------------------------------------------------------------Level Up
	if BLU.db.profile.MuteLevelDefault == true then
			MuteSoundFile(569593)
		elseif BLU.db.profile.MuteLevelDefault == false then
			UnmuteSoundFile(569593)
	end
---------------------------------------------------------------Level Up
----------------------------------------------------------Reputation Up
	if BLU.db.profile.MuteRepDefault == true then
			MuteSoundFile(568016)
		elseif BLU.db.profile.MuteRepDefault == false then
			UnmuteSoundFile(568016)
	end
----------------------------------------------------------Reputation Up
---------------------------------------------------------Quest Accepted
	if BLU.db.profile.MuteQuestAcceptDefault == true then
			MuteSoundFile(567400)
		elseif BLU.db.profile.MuteQuestAcceptDefault == false then
			UnmuteSoundFile(567400)
	end
---------------------------------------------------------Quest Accepted
----------------------------------------------------------Quest Turn-In
	if BLU.db.profile.MuteQuestDefault == true then
			MuteSoundFile(567439)
		elseif BLU.db.profile.MuteQuestDefault == false then
			UnmuteSoundFile(567439)
	end
----------------------------------------------------------Quest Turn-In
end
------------------------------------------------------------------Mute Defaults
--------------------------------------------------------Slash Command Functions
-------------------------------------------------------------Enable BLU
function BLU:SlashCommand(input, editbox)
	if input == "enable" then
			self:Enable()
			self:Print("Enabled.")
-------------------------------------------------------------Enable BLU
------------------------------------------------------------Disable BLU
		elseif input == "disable" then
			self:Disable()
			self:Print("Disabled.")
------------------------------------------------------------Disable BLU
-----------------------------------------------------------Open Options
		else
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
-----------------------------------------------------------Open Options
end
--------------------------------------------------------Slash Command Functions
