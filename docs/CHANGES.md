## Notes
- 2026-03-26: Released v6.2.3 with the finalized Sounds tab custom sound manager, instant list refreshes, custom sound shorthand/playback fixes, and slash-command cleanup.
- 2026-03-25: `/blu addcustom` now accepts short names like `myfile` or `myfile.ogg` and checks common AddOns sound locations automatically before saving the resolved path.
- 2026-03-25: Added a General tab helper button and popup so users can add custom sounds in game without typing the full file path.
- 2026-03-25: General tab now keeps only the Add Custom Sound button in Actions, places it beside Reset Profile, and restores the BLU header title colors.

## Version 6.2.3 (2026-03-26)

### Bug Fixes
- **Header row alignment fixed for real** - the right-side version, author, and RGX Mods lines now align directly to the left-side title, subtitle, and Discord rows instead of relying on independent spacing that still left the columns visually off.
- **Custom sound shorthand now resolves the real supported extension** - bare names like `water` now match the actual compatible `.ogg`, `.mp3`, or `.wav` file instead of incorrectly assuming the first extension checked.
- **Custom sound shorthand works again for forgiving AddOns-root adds** - shorthand entries now keep candidate file paths so easy inputs like `test` still add and playback can resolve the real working file instead of failing the whole add flow.
- **User Custom Sounds manager now refreshes immediately** - adding or removing a custom sound updates the Sounds tab list in place instead of waiting for another tab change or reload.
- **Custom sound rows now fit the right column correctly** - removed hidden scrollbar gutter clipping and tuned the entry widths so the custom sound list lines up cleanly inside the panel.
- **`/blu test` removed from slash command help flow** - the stale generic test command no longer points users at an invalid test-sound path from help text or README instructions.
- **Nested dropdown labels are cleaner** - sound entries now show just the sound name or filename in submenus instead of repeating pack/path context that the dropdown hierarchy already shows.

---

## Version 6.2.1 (2026-03-25)

### Bug Fixes
- **BLU default sounds now show volume slider** - selecting "None" was showing the channel dropdown instead of the volume slider; fixed so None/default always shows the Low/Med/High slider
- **All sounds now play on Master channel** - per-event channel dropdown removed; all sound types (BLU defaults, game soundpacks, user custom, SharedMedia, random) play on the Master channel
- **No external library dependencies** - removed all LibStub and LibSharedMedia-3.0 usage; BLU's own internal bridge scanner discovers external sound packs without any third-party library; no `OptionalDeps` in TOC; immune to library version conflicts from other addons
- **SharedMedia dropdown restored** - "Shared Media" section appears in sound dropdown when external sound pack addons are installed; powered by BLU's internal bridge scanner
- **Game soundpack volume variants now respect slider** - selecting Low/Medium/High on a game soundpack sound now plays the correct `_low`/`_med`/`_high` file variant instead of always playing `_med`
- **Header alignment fixed** - removed extra visual gap above "BLU" title and extra space below "RGX Mods" branding on right side of header
- **Delve icons restored again** - Delve now uses safer stock icon textures in both the tab strip and event panel header so the icon renders reliably
- **Shared media compatibility improved** - BLU now includes native compatibility bridges for installed addons like Prat and TradeSkillMaster whose sound tables are not exposed globally, allowing those packs to appear in the Sounds tab and dropdowns again without external dependencies
- **Header columns now align properly** - the three-line branding block on the right side of the options header now stacks from the same top edge and spacing pattern as the three-line block on the left
- **Manual custom sound adds no longer disappear on probe failure** - when users add a shorthand name like `test`, BLU now keeps the resolved fallback path and registers it into `User Custom Sounds` even if WoW refuses the initial root-path probe during detection

---

## Version 6.2.0 (2026-03-25)

### Bug Fixes
- **All module triggers now fire correctly** - `enabled = true` was missing from config defaults, causing every module handler to bail early on fresh installs or profiles without a saved `enabled` value; all events (Level Up, Achievement, Quest, Reputation, Honor, Renown, Trading Post, Battle Pet, Delve, Housing) now trigger as expected
- **Sound channel selection now works for game soundpack sounds** - game packs were incorrectly registered with `isInternal = true`, forcing them onto the Master channel and hiding the channel dropdown; fixed so only BLU default sounds are internal, game packs correctly use the per-event channel dropdown (Master / SFX / Music / Ambience)
- **Default WoW sounds now fully muted when BLU is active** - expanded mute list with correct retail FileDataIDs sourced from BLU Classic: Quest Accepted (567400), Quest Turned In (567439), Honor (1489546), Battle Pet Level Up (642841), Renown (4745441), Trading Post (2066672), plus all legacy IDs retained; prevents default sounds from playing over BLU sounds
- **BLU default sound fallback no longer errors** - all default sounds now registered with `_med.ogg` suffix so both the primary variant path and fallback resolve to files that exist on disk
- **User custom sounds now load on startup** - `usersounds` module was never added to the init sequence; now initializes in Phase 2 so custom OGG/MP3/WAV files placed at `Interface\AddOns\sounds\custom01.ogg` (up to `custom24`) are detected and available in dropdowns after `/reload`

### New Features
- **Per-event sound channel selection** - non-BLU (soundpack/game) sounds now have a channel dropdown per event tab (Master / SFX / Music / Ambience), defaulting to SFX; BLU internal default sounds always play on Master with volume controlled by Low/Med/High file variants
- **Volume label under slider** - replaces static Low/High tick labels with a single dynamic label below the slider that updates as you drag (Low / Medium / High)
- **User custom sounds** - drop up to 24 OGG, MP3, or WAV files named `custom01`-`custom24` in `Interface\AddOns\sounds\` and they appear under "User Custom Sounds" in every event's sound dropdown after `/reload`

### UI Changes
- Discord link restored to left side of header, anchored below subtitle/title block
- Discord invite updated to `discord.gg/N7kdKAHVVF`
- RGX Mods branding color updated to burgundy (`#8b4b5c`)
- Housing tab content inset now matches all other tabs (consistent 10px padding)
- Volume slider Low/High static labels removed; single updating label shown below slider instead

---
