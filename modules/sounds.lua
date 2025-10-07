-- modules/sounds.lua
soundOptions = {
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

defaultSounds = {
    [1] = { -- Achievement
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [2] = { -- Battle Pet Level Up
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [3] = { -- Delve Companion Level Up
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [4] = { -- Honor Level Up
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [5] = { -- Level Up
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [6] = { -- Renown Level Up
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [7] = { -- Quest Accepted
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [8] = { -- Quest Complete
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
    [9] = { -- Trading Post Complete
        [1] = 880,
        [2] = 880,
        [3] = 880,
    },
}

muteSoundIDs = {
    ["retail"] = {
        880, -- Level Up
        873, -- Quest Complete
        861, -- Achievement
        1335, -- Renown
        119, -- Honor
        870, -- Trading Post
    },
    ["cata"] = {
        880, -- Level Up
        873, -- Quest Complete
        861, -- Achievement
    },
    ["vanilla"] = {
        880, -- Level Up
        873, -- Quest Complete
    },
}
