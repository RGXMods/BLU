-- modules/sounds.lua
local sounds = {}

sounds.soundOptions = {
    [2] = "Random",
    [1] = "Default",
    [3] = "Diablo 2",
    [4] = "Diablo 3",
    [5] = "Diablo 4",
    [6] = "Doom",
    [7] = "Duke Nukem",
    [8] = "Half-Life",
    [9] = "Hearthstone",
    [10] = "Heroes of the Storm",
    [11] = "Left 4 Dead",
    [12] = "Left 4 Dead 2",
    [13] = "Overwatch",
    [14] = "Payday 2",
    [15] = "Pepe",
    [16] = "Portal",
    [17] = "Portal 2",
    [18] = "Quake",
    [19] = "StarCraft",
    [20] = "StarCraft 2",
    [21] = "Unreal Tournament",
    [22] = "Venture Bros.",
    [23] = "Warcraft 2",
    [24] = "Warcraft 3",
    [25] = "Warcraft 3: Reforged",
}

sounds.defaultSounds = {
    [1] = { [1] = 880, [2] = 880, [3] = 880 }, -- Achievement
    [2] = { [1] = 880, [2] = 880, [3] = 880 }, -- Battle Pet Level Up
    [4] = { [1] = 880, [2] = 880, [3] = 880 }, -- Honor Level Up
    [5] = { [1] = 880, [2] = 880, [3] = 880 }, -- Level Up
    [6] = { [1] = 880, [2] = 880, [3] = 880 }, -- Renown Level Up
    [7] = { [1] = 880, [2] = 880, [3] = 880 }, -- Quest Accepted
    [8] = { [1] = 880, [2] = 880, [3] = 880 }, -- Quest Complete
    [9] = { [1] = 880, [2] = 880, [3] = 880 }, -- Trading Post Complete
}

local muteSoundIDs = {
    880, -- Level Up
    873, -- Quest Complete
    861, -- Achievement
    1335, -- Renown
    119, -- Honor
    870, -- Trading Post
}

function sounds:OnEnable()
    self.addon:Print("Sounds module enabled!")
    self:MuteSounds()
end

function sounds:MuteSounds()
    for _, soundID in ipairs(muteSoundIDs) do
        MuteSoundFile(soundID)
    end
end

BLULib = BLULib or {}
BLULib.SoundsModule = sounds
