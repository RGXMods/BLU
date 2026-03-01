## v5.3.6 - 2026-03-01

- Fixed Retail `/blu` options panel opening error by resolving and using a numeric Settings category ID before calling `Settings.OpenToCategory`.
- Added compatibility guards around Settings/Interface options panel opening calls to avoid hard Lua errors from API mismatches.
- Re-added Delve companion level-up detection in Retail via `CHAT_MSG_SYSTEM` parsing for companion level-up messages.
- Added `FACTION_STANDING_CHANGED` Delve fallback using friendship rank checks via `C_GossipInfo.GetFriendshipReputationRanks` and `C_DelvesUI` faction resolution.
- Initialized Delve companion level cache on enable to prevent false positives on first update.
- Updated addon version metadata to `v5.3.6` across `.toc` files and options fallback version label.
