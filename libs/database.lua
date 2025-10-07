-- libs/database.lua
local database = {}

function database:Create(addon, defaults)
    addon.db = {}
    if not BLUDB then
        BLUDB = {}
    end
    if not BLUDB.profile then
        BLUDB.profile = {}
    end

    for key, value in pairs(defaults.profile) do
        if BLUDB.profile[key] == nil then
            BLUDB.profile[key] = value
        end
    end

    addon.db.profile = BLUDB.profile
end

BLULib = BLULib or {}
BLULib.Database = database
