--=====================================================================================
-- BLU | Database
-- Thin layer on top of RGX:NewDatabase. All profile management, path accessors,
-- serialization, and export/import dialogs are handled by the framework.
-- BLU supplies its own defaults and a UI refresh callback; everything else
-- is boilerplate that any addon can replicate with two lines.
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]

local Database = {}
BLU.Modules = BLU.Modules or {}
BLU.Modules["database"] = Database

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function getProfileDefaults()
    local cfg = BLU.Modules.config
    if cfg and cfg.defaults and cfg.defaults.profile then
        return cfg.defaults.profile
    end
    return {}
end

-- ── Init ──────────────────────────────────────────────────────────────────────

function Database:Init()
    BLU:PrintDebug("Database:Init() called")

    local RGX = _G.RGXFramework
    if not RGX then
        BLU:PrintError("[Database] RGX-Framework not available — cannot initialize database")
        return
    end

    -- RGX.Addon() in core.lua already created BLU.db.  Merge BLU defaults
    -- and wire profile-switch callbacks without opening a second proxy.
    if BLU.db then
        local profile = BLU.db:GetProfile()
        if profile then
            RGX:DeepMergeDefaults(profile, getProfileDefaults())
        end
        BLU.db:OnProfileChanged(function(name, profile)
            if BLU.InvalidateAllTabs then BLU:InvalidateAllTabs() end
            if BLU.RefreshOptions     then BLU:RefreshOptions()    end
            if BLU.RefreshProfilesUI  then BLU:RefreshProfilesUI() end
        end)
    end

    BLU.InitializeDatabase = function() return BLU.db end
    BLU:PrintDebug("Database module initialized. BLU.db is " .. tostring(BLU.db))
end

-- ── Save settings ─────────────────────────────────────────────────────────────
-- Stamps version and timestamp into the active profile so it persists to disk.

function Database:SaveSettings()
    BLU:PrintDebug("[Database] SaveSettings called")
    if not BLU.db then return end
    BLU.db.lastSaved = time()
    local version = (BLU.GetMetadata and BLU:GetMetadata(addonName, "Version"))
        or (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version"))
        or BLU.version or "unknown"
    BLU.db.version = version
end

BLU.SaveSettings = function() return Database:SaveSettings() end

-- ── Profile operations ────────────────────────────────────────────────────────
-- All delegate to the BLU.db proxy (RGX:NewDatabase return value).

function Database:CreateProfile(name)
    BLU:PrintDebug("[Database] CreateProfile called for '" .. tostring(name) .. "'")
    if not BLU.db then return false end
    return BLU.db:CreateProfile(name)
end

function Database:LoadProfile(name)
    BLU:PrintDebug("[Database] LoadProfile called for '" .. tostring(name) .. "'")
    if not BLU.db then return false end
    return BLU.db:LoadProfile(name)
end

function Database:DeleteProfile(name)
    BLU:PrintDebug("[Database] DeleteProfile called for '" .. tostring(name) .. "'")
    if not BLU.db then return false end
    return BLU.db:DeleteProfile(name)
end

function Database:RenameProfile(oldName, newName)
    BLU:PrintDebug("[Database] RenameProfile called from '" .. tostring(oldName) .. "' to '" .. tostring(newName) .. "'")
    if not BLU.db then return false end
    return BLU.db:RenameProfile(oldName, newName)
end

function Database:CopyProfile(sourceName, targetName)
    BLU:PrintDebug("[Database] CopyProfile called from '" .. tostring(sourceName) .. "' to '" .. tostring(targetName) .. "'")
    if not BLU.db then return false end
    return BLU.db:CopyProfile(sourceName, targetName)
end

function Database:ListProfiles()
    if not BLU.db then return {} end
    return BLU.db:ListProfiles()
end

function Database:GetProfileName()
    if not BLU.db then return nil end
    return BLU.db:GetActiveProfile()
end

-- ── Path accessors ────────────────────────────────────────────────────────────

function Database:GetDB(path, default)
    BLU:PrintDebug("[Database] GetDB called for path '" .. tostring(path) .. "'")
    if not BLU.db then return default end
    if not path then return BLU.db end
    return BLU.db:Get(path, default)
end

function Database:SetDB(path, value)
    BLU:PrintDebug("[Database] SetDB called for path '" .. tostring(path) .. "'")
    if not BLU.db then return false end
    return BLU.db:Set(path, value)
end

BLU.GetDB = function(path, default) return Database:GetDB(path, default) end
BLU.SetDB = function(path, value)   return Database:SetDB(path, value)   end

-- ── Serialization ─────────────────────────────────────────────────────────────

function Database:SerializeProfile(name)
    BLU:PrintDebug("[Database] SerializeProfile called for '" .. tostring(name) .. "'")
    if not BLU.db then return "" end
    return BLU.db:SerializeProfile(name)
end

function Database:DeserializeProfile(str)
    BLU:PrintDebug("[Database] DeserializeProfile called")
    if not BLU.db then return nil end
    return BLU.db:DeserializeProfile(str)
end

-- ── Export / Import dialogs ───────────────────────────────────────────────────

function Database:ShowExportDialog(name)
    BLU:PrintDebug("[Database] ShowExportDialog called")
    if BLU.db then BLU.db:ShowExportDialog(name) end
end

function Database:ShowImportDialog()
    BLU:PrintDebug("[Database] ShowImportDialog called")
    if BLU.db then BLU.db:ShowImportDialog() end
end

-- ── BLU global API surface ────────────────────────────────────────────────────
-- Both BLU:Method(arg) and BLU.Method(arg) calling conventions are supported.
-- When called as BLU.Method(self, arg), `self` is the first positional arg.

local function unwrap1(a, b)
    -- BLU:Call(x)  → a=BLU, b=x  → return x
    -- BLU.Call(x)  → a=x,   b=nil → return x
    if type(a) == "string" and b == nil then return a end
    return b
end

function BLU.CreateProfile(self, name)
    return Database:CreateProfile(unwrap1(self, name))
end

function BLU.LoadProfile(self, name)
    return Database:LoadProfile(unwrap1(self, name))
end

function BLU.DeleteProfile(self, name)
    return Database:DeleteProfile(unwrap1(self, name))
end

function BLU.RenameProfile(self, oldName, newName)
    if type(self) == "string" and newName == nil then
        return Database:RenameProfile(self, oldName)
    end
    return Database:RenameProfile(oldName, newName)
end

function BLU.CopyProfile(self, sourceName, targetName)
    if type(self) == "string" and targetName == nil then
        return Database:CopyProfile(self, sourceName)
    end
    return Database:CopyProfile(sourceName, targetName)
end

function BLU.SerializeProfile(self, name)
    return Database:SerializeProfile(unwrap1(self, name))
end

function BLU.ImportProfile(self, data)
    return Database:DeserializeProfile(unwrap1(self, data))
end

function BLU.ShowExportDialog(self, name)
    return Database:ShowExportDialog(unwrap1(self, name))
end

function BLU:ShowImportDialog()
    return Database:ShowImportDialog()
end
