## Notes
- 2026-04-10: Active alpha build is v6.3.0-alpha.1. Profiles, presets, debug separation, module placeholders, and dropdown/popup hardening are now included in release notes.

## Version 6.3.0-alpha.1 (2026-04-10)

### Updates
- Added a dedicated Profiles tab with saved profile management, import/export actions, rename/delete/reset flows, and copy-from-character support.
- Added preset application flows so Adventure, Spooky, Minimal, and DonnieDice-curated setups can be applied without rebuilding a profile by hand.
- Expanded the options panel into a 3-row alphabetical tab layout and reserved future-facing placeholder modules for Combat, Collectibles, Loot, and Prey.
- Moved scoped troubleshooting into a dedicated Debug module and tab while keeping the release focused on lightweight diagnostics.
- Improved Delve life-credit sound handling and tightened nested dropdown behavior for inline arrows, preview buttons, and delete actions.
- Hardened StaticPopup editbox handling and addon metadata fallbacks to avoid nil-index and metadata lookup errors on newer WoW clients.

## Version 6.3.0 (2026-04-09)

### Updates
- All 18 option tabs are now in full alphabetical order across three rows of six.
- Combat, Collectibles, Loot, and Prey now share one consistent styled placeholder panel with a title bar, icon, and coming-soon section — no more grayed-out non-clickable slots for these.
- Prey tab and module stub added to reserve the category for a future hunt/target-tracking sound system.
- Collectibles, Loot, and Prey each have dedicated module stub files under `modules/` matching the Combat module pattern.
- Profiles tab layout rebuilt: saved profiles, current selection, and actions now share a single combined section, with the delete action moved into the profile dropdown instead of a separate inline quick-delete button.
- Fixed profile popup handling so `hasEditBox` dialogs safely guard `self.editBox` access and avoid nil-index crashes.
- Added robust addon metadata lookup fallback for `C_AddOns.GetAddOnMetadata` and `GetAddOnMetadata`, preventing broken saves in newer WoW environments.
- Fixed tab button sizing on stacked rows by removing a redundant `SetSize` call and ensuring second and later column tabs use the correct wide width.
- StaticPopup success messages (create/rename/delete) now route through `PrintDebug` instead of `BLU:Print`, so they are silent when debug mode is off.
- Removed the redundant `|cff00ccffBLU:|r` prefix from all popup error messages — `BLU:Print` already adds the addon prefix.
- General tab: wider gap between Core and Behavior column sections; Debug section now sits lower with more breathing room above it.
- Debug tab added to the tab grid (alphabetical slot col 5 row 1); debug controls remain in General for quick-access toggle as well.


---
