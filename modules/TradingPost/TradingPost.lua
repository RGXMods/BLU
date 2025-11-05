--=====================================================================================
-- BLU Trading Post Module
-- Handles Trading Post activity sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local TradingPost = {}

-- Module initialization
function TradingPost:Init()
    -- Trading Post events
    BLU:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS", function(...) self:OnPurchaseSuccess(...) end)
    BLU:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", function(...) self:OnCurrencyRefresh(...) end)
    
    -- Track currency for changes
    self.lastCurrencyAmount = self:GetTradingPostCurrency()
    
    BLU:PrintDebug("TradingPost module initialized")
end

-- Cleanup function
function TradingPost:Cleanup()
    BLU:UnregisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS")
    BLU:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH")
    
    BLU:PrintDebug("TradingPost module cleaned up")
end

-- Get current Trading Post currency
function TradingPost:GetTradingPostCurrency()
    if C_PerksProgram then
        return C_PerksProgram.GetCurrencyAmount() or 0
    end
    return 0
end

-- Purchase success handler
function TradingPost:OnPurchaseSuccess(event, vendorItemID)
    if not BLU.db.profile.enableTradingPost then return end
    
    self:PlayTradingPostSound()
    
    if BLU.debugMode then
        BLU:Print("Trading Post purchase successful!")
    end
end

-- Currency refresh handler
function TradingPost:OnCurrencyRefresh(event)
    if not BLU.db.profile.enableTradingPost then return end
    
    local currentAmount = self:GetTradingPostCurrency()
    
    -- Check if we gained currency (monthly refresh or activity completion)
    if self.lastCurrencyAmount and currentAmount > self.lastCurrencyAmount then
        self:PlayTradingPostSound()
        
        if BLU.debugMode then
            local gained = currentAmount - self.lastCurrencyAmount
            BLU:Print(string.format("Gained %d Trading Post currency!", gained))
        end
    end
    
    self.lastCurrencyAmount = currentAmount
end

-- Play Trading Post sound
function TradingPost:PlayTradingPostSound()
    local soundName = BLU.db.profile.tradingPostSound
    local volume = BLU.db.profile.tradingPostVolume * BLU.db.profile.masterVolume
    
    BLU:PlaySound(soundName, volume)
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["tradingpost"] = TradingPost

-- Export module
return TradingPost
