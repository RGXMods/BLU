## v5.3.9 - 2026-03-02

- Fixed a Retail taint error in Delve companion detection by avoiding direct access/comparison of `CHAT_MSG_SYSTEM` payload strings.
- Reworked `HandleChatSystemMessage` to use throttled companion-level API checks instead of parsing system chat text.
- Updated addon version metadata to `v5.3.9` across `.toc` files and options fallback version label.

## v5.3.8 - 2026-03-01

- Fixed trigger burst freezes by hardening the shared event queue with O(1) dequeue logic.
- Added short duplicate-event suppression to prevent rapid identical trigger spam from flooding the queue.
- Added queue size cap with oldest-event drop behavior under heavy trigger storms.
- Removed per-event default sound muting from `HandleEvent` to avoid repeated expensive mute loops during bursts.
- Updated addon version metadata to `v5.3.8` across `.toc` files and options fallback version label.

## v5.3.7 - 2026-03-01

- Fixed `/blu` on Retail not navigating to BLU settings by resolving and caching a numeric Settings category ID.
- Added compatibility repair for top-level addon categories that expose string IDs by recovering the engine numeric ID from category order.
- Updated options panel open flow to prefer the cached numeric category ID before fallback behavior.
- Updated addon version metadata to `v5.3.7` across `.toc` files and options fallback version label.

## v5.3.6 - 2026-03-01

- Fixed Retail `/blu` options panel opening error by resolving and using a numeric Settings category ID before calling `Settings.OpenToCategory`.
- Added compatibility guards around Settings/Interface options panel opening calls to avoid hard Lua errors from API mismatches.
- Re-added Delve companion level-up detection in Retail via `CHAT_MSG_SYSTEM` parsing for companion level-up messages.
- Added `FACTION_STANDING_CHANGED` Delve fallback using friendship rank checks via `C_GossipInfo.GetFriendshipReputationRanks` and `C_DelvesUI` faction resolution.
- Initialized Delve companion level cache on enable to prevent false positives on first update.
- Updated addon version metadata to `v5.3.6` across `.toc` files and options fallback version label.
