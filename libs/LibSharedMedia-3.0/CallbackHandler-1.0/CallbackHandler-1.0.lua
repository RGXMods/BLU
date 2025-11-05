-- CallbackHandler-1.0
local MAJOR, MINOR = "CallbackHandler-1.0", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.embeds = lib.embeds or {}

function lib:Embed(target)
    for k, v in pairs(self) do
        target[k] = v
    end
    self.embeds[target] = true
    return target
end

function lib:RegisterCallback(target, event, method, func)
    if not target.callbacks then
        target.callbacks = {}
    end
    if not target.callbacks[event] then
        target.callbacks[event] = {}
    end
    target.callbacks[event][method] = func
end

function lib:UnregisterCallback(target, event, method)
    if target.callbacks and target.callbacks[event] then
        target.callbacks[event][method] = nil
    end
end

function lib:Fire(target, event, ...)
    if not target.callbacks or not target.callbacks[event] then
        return
    end
    for method, func in pairs(target.callbacks[event]) do
        func(...)
    end
end
