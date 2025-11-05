--=====================================================================================
-- BLU Trading Post Module
-- Handles Trading Post activity sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local tradingpost = {}

-- Module initialization
function tradingpost:Init()
    -- Trading Post events
    BLU:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS", function(...) self:OnPurchaseSuccess(...) end)
    BLU:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", function(...) self:OnCurrencyRefresh(...) end)
    
    -- Track currency for changes
    self.lastCurrencyAmount = self:GetTradingPostCurrency()
    
    BLU:PrintDebug("TradingPost module initialized")
end

-- Cleanup function
function tradingpost:Cleanup()
    BLU:UnregisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS")
    BLU:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH")
    
    BLU:PrintDebug("TradingPost module cleaned up")
end

-- Get current Trading Post currency
function tradingpost:GetTradingPostCurrency()
    if C_PerksProgram then
        return C_PerksProgram.GetCurrencyAmount() or 0
    end
    return 0
end

-- Purchase success handler
function tradingpost:OnPurchaseSuccess(event, vendorItemID)
    if not BLU.db.profile.enableTradingPost then return end
    
    self:PlayTradingPostSound()
    
    if BLU.debugMode then
        BLU:Print("Trading Post purchase successful!")
    end
end

-- Currency refresh handler
function tradingpost:OnCurrencyRefresh(event)
    if not BLU.db or not BLU.db.profile then return end
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
function tradingpost:PlayTradingPostSound()
    BLU:PlayCategorySound("tradingpost")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["tradingpost"] = tradingpost
