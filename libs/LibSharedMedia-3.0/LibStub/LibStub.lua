-- LibStub.lua
local MAJOR, MINOR = "LibStub", 2
local lib, oldminor = _G[MAJOR], _G[MAJOR .. "_MINOR"]
if lib and (lib.major > MAJOR or (lib.major == MAJOR and lib.minor >= MINOR)) then return end

lib = {
    major = MAJOR,
    minor = MINOR,
    libs = {},
    callbacks = {},
}

function lib:NewLibrary(major, minor)
    if self.libs[major] then
        return self.libs[major]
    end
    self.libs[major] = minor
    return self:GetLibrary(major)
end

function lib:GetLibrary(major, silent)
    if not self.libs[major] then
        if not silent then
            error("library " .. major .. " not found", 2)
        end
        return nil
    end
    return self.libs[major]
end

function lib:Register(major, minor, callback)
    if not self.callbacks[major] then
        self.callbacks[major] = {}
    end
    self.callbacks[major][minor] = callback
end

function lib:HasLibrary(major)
    return self.libs[major] ~= nil
end

function lib:IterateLibraries()
    return pairs(self.libs)
end

_G[MAJOR] = lib
_G[MAJOR .. "_MINOR"] = MINOR
