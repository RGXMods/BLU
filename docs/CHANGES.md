## Version 6.2.0 (2026-03-25)

### Bug Fixes
- **All module triggers now fire correctly** — `enabled = true` was missing from config defaults, causing every module handler to bail early on fresh installs or profiles without a saved `enabled` value; all events (Level Up, Achievement, Quest, Reputation, Honor, Renown, Trading Post, Battle Pet, Delve, Housing) now trigger as expected
- **Sound channel selection now works for game soundpack sounds** — game packs were incorrectly registered with `isInternal = true`, forcing them onto the Master channel and hiding the channel dropdown; fixed so only BLU default sounds are internal, game packs correctly use the per-event channel dropdown (Master / SFX / Music / Ambience)
- **Default WoW sounds now fully muted when BLU is active** — expanded mute list with correct retail FileDataIDs sourced from BLU Classic: Quest Accepted (567400), Quest Turned In (567439), Honor (1489546), Battle Pet Level Up (642841), Renown (4745441), Trading Post (2066672), plus all legacy IDs retained; prevents default sounds from playing over BLU sounds
- **BLU default sound fallback no longer errors** — all default sounds now registered with `_med.ogg` suffix so both the primary variant path and fallback resolve to files that exist on disk
- **User custom sounds now load on startup** — `usersounds` module was never added to the init sequence; now initializes in Phase 2 so custom OGG/MP3/WAV files placed at `Interface\AddOns\sounds\custom01.ogg` (up to `custom24`) are detected and available in dropdowns after `/reload`

### New Features
- **Per-event sound channel selection** — non-BLU (soundpack/game) sounds now have a channel dropdown per event tab (Master / SFX / Music / Ambience), defaulting to SFX; BLU internal default sounds always play on Master with volume controlled by Low/Med/High file variants
- **Volume label under slider** — replaces static Low/High tick labels with a single dynamic label below the slider that updates as you drag (Low / Medium / High)
- **User custom sounds** — drop up to 24 OGG, MP3, or WAV files named `custom01`–`custom24` in `Interface\AddOns\sounds\` and they appear under "User Custom Sounds" in every event's sound dropdown after `/reload`

### UI Changes
- Discord link restored to left side of header, anchored below subtitle/title block
- Discord invite updated to `discord.gg/N7kdKAHVVF`
- RGX Mods branding color updated to burgundy (`#8b4b5c`)
- Housing tab content inset now matches all other tabs (consistent 10px padding)
- Volume slider Low/High static labels removed; single updating label shown below slider instead

---