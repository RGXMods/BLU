--=====================================================================================
-- BLU SharedMedia Implementation
-- A lightweight, self-contained media library for BLU
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local SharedMedia = {}
BLU.Modules["sharedmedia"] = SharedMedia

SharedMedia.media = {
    sound = {},
    texture = {},
    font = {},
    statusbar = {},
}

function SharedMedia:Register(mediaType, name, path)
    if not self.media[mediaType] then
        self.media[mediaType] = {}
    end
    self.media[mediaType][name] = path
end

function SharedMedia:Get(mediaType, name)
    if self.media[mediaType] and self.media[mediaType][name] then
        return self.media[mediaType][name]
    end
    return nil
end

function SharedMedia:List(mediaType)
    if not self.media[mediaType] then
        return {}
    end
    local list = {}
    for name, _ in pairs(self.media[mediaType]) do
        table.insert(list, name)
    end
    return list
end

function SharedMedia:GetSoundCategories()
    local categories = {}
    for name, path in pairs(self.media.sound) do
        local category = "BLU"
        local game, soundName = name:match("([^_]+)_(.+)")
        if game then
            category = game
        end
        if not categories[category] then
            categories[category] = {}
        end
        table.insert(categories[category], {id = name, name = soundName or name, path = path})
    end
    return categories
end

function SharedMedia:Init()
    BLU:PrintDebug("SharedMedia module initialized")
end
