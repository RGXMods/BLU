--=====================================================================================
-- BLU Trading Post Module
-- Handles Trading Post activity sounds
--=====================================================================================

local addonName = ...
local BLU = _G["BLU"]
local TradingPost = {}

local TRADING_EVENT_ID_PURCHASE = "tradingpost_purchase_success"
local TRADING_EVENT_ID_REFRESH = "tradingpost_currency_refresh"

-- Module initialization
function TradingPost:Init()
    -- Trading Post events
    BLU:RegisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS", function(...) self:OnPurchaseSuccess(...) end, TRADING_EVENT_ID_PURCHASE)
    BLU:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", function(...) self:OnCurrencyRefresh(...) end, TRADING_EVENT_ID_REFRESH)
    
    -- Track currency for changes
    self.lastCurrencyAmount = self:GetTradingPostCurrency()
    
    BLU:PrintDebug(BLU:Loc("MODULE_LOADED", "TradingPost"))
end

-- Cleanup function
function TradingPost:Cleanup()
    BLU:UnregisterEvent("PERKS_PROGRAM_PURCHASE_SUCCESS", TRADING_EVENT_ID_PURCHASE)
    BLU:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH", TRADING_EVENT_ID_REFRESH)
    
    BLU:PrintDebug(BLU:Loc("MODULE_CLEANED_UP", "TradingPost"))
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
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if not BLU.db.enableTradingPost then return end
    if BLU.db.modules and BLU.db.modules.tradingpost == false then return end
    
    self:PlayTradingPostSound()
    
    if BLU.db.debugMode then
        BLU:Print(BLU:Loc("DEBUG_TRADING_POST_PURCHASE"))
    end
end

-- Currency refresh handler
function TradingPost:OnCurrencyRefresh(event)
    if not BLU.db then return end
    if not BLU.db.enabled then return end
    if not BLU.db.enableTradingPost then return end
    if BLU.db.modules and BLU.db.modules.tradingpost == false then return end
    
    local currentAmount = self:GetTradingPostCurrency()
    
    -- Check if we gained currency (monthly refresh or activity completion)
    if self.lastCurrencyAmount and currentAmount > self.lastCurrencyAmount then
        self:PlayTradingPostSound()
        
        if BLU.db.debugMode then
            local gained = currentAmount - self.lastCurrencyAmount
            BLU:Print(BLU:Loc("DEBUG_TRADING_POST_CURRENCY_GAINED", gained))
        end
    end
    
    self.lastCurrencyAmount = currentAmount
end

-- Play Trading Post sound
function TradingPost:PlayTradingPostSound()
    BLU:PlayCategorySound("tradingpost")
end

-- Register module
BLU.Modules = BLU.Modules or {}
BLU.Modules["tradingpost"] = TradingPost

-- Export module
return TradingPost
