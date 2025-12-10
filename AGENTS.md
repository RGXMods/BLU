# BLU – Complete Agent Context File  
**Version**: 6.0.0-alpha  
**Last Updated**: November 29, 2025  
**Phase**: UI Finalization + Error-Free Release Candidate  
**Project Health**: 8.8 / 10  

---
## WHAT THIS DOCUMENT IS
This is the single source of truth for any AI agent working on BLU.  
It explains WHY every decision was made, WHAT the full architecture is, HOW everything must be implemented, and lists ALL remaining tasks to 100 % completion.  
This is NOT the README, NOT the user guide, NOT the wiki — this is the living brain for the AI agent only.

---
## PROJECT OVERVIEW

### What We’re Building
BLU (Better Level Up!) is a lightweight, pure-Lua, zero-dependency World of Warcraft Retail addon that replaces every milestone audio cue with nostalgic sounds from over 50 classic games, while also offering perfectly remade WoW default sounds at three volume tiers.  
It is fully modular, toggleable per event, and supports unlimited external sound packs via SharedMedia.

### Critical Design Goals (non-negotiable)
1. Zero external libraries (no Ace3, no LibStub unless optional SharedMedia)  
2. Runs on any retail client with < 1.2 MB memory footprint  
3. Every single event can be independently enabled/disabled  
4. Options panel must load instantly and never error, even with 200+ sounds  
5. Dropdown menus must be organized, searchable, and previewable  
6. Selecting “Default” automatically mutes the original WoW sound and plays our tiered remake  
7. External packs play at full volume, no muting needed  
8. Addon must be 100 % error-free on /reload and on first install  

### Why Pure Lua & No Ace3
- Ace3 alone is ~300 KB and pulls in many globals — unacceptable for a pure-audio addon  
- We want the smallest possible memory/CPU impact  
- Full control over initialization order and unload behavior  
- Easier for new contributors (no framework learning curve)  

---
## CURRENT PRIORITY (November 29, 2025)
**Phase**: Options Panel Completion + Global Error Elimination  
Everything else is secondary until:
- `/blu` opens instantly with zero Lua errors = 0  
- All dropdowns populate correctly and are logically organized  
- Sound preview works on hover/click  
- Module toggles instantly enable/disable without leaks  
- Addon survives /reload in every possible state  

---
## FULL DIRECTORY TREE (dev branch – exact paths)

```
BLU/
├── BLU.toc                              # SavedVariables: BLU_DB, OptionalDeps: LibSharedMedia-3.0
├── BLU.lua                              # Core engine, frame, slash commands, PlaySound resolver
├── README.md
├── CHANGELOG.md
└── .gitignore
├── Modules/                             # 38 self-contained modules (all follow identical pattern)
│   ├── LevelUp.lua
│   ├── Achievement.lua
│   ├── QuestTurnIn.lua
│   ├── QuestAccept.lua
│   ├── Reputation.lua
│   ├── PetLevelUp.lua
│   ├── TradingPost.lua
│   ├── Honor.lua
│   ├── Renown.lua
│   ├── DelveCompanion.lua
│   ├── Guild.lua
│   ├── RaidClear.lua
│   ├── DungeonComplete.lua
│   ├── DefaultSounds.lua                 # Helper mappings for remade defaults
│   ├── PackHandler.lua                  # SharedMedia detection & fallback logic
│   └── (24 more – every module registers itself with BLU.RegisterModule)
├── Sounds/
│   ├── Default/
│   │   ├── Low/      (20 events)
│   │   ├── Med/      (20 events)
│   │   └── High/     (20 events)
│   ├── OtherGames/                     # 138 files, 46 games
│   │   ├── Skyrim/
│   │   ├── EldenRing/
│   │   ├── FinalFantasy/
│   │   ├── Zelda/
│   │   └── … (42 more game folders)
│   └── Packs/                            # User-added at runtime, scanned on load
├── Interface/
│   ├── BLU_Options.xml                   # Frame templates, tabs, scrollframes
│   └── BLU_Options.lua                   # All UI logic – current hotspot
├── Config/
│   ├── Profiles.lua                      # DB schema, defaults, migration
│   └── Localization.lua                  # enUS + partial deDE/frFR
└── Media/
    └── SharedMedia.lua                   # Optional lazy-load if LibSharedMedia-3.0 exists
```

---
## ARCHITECTURE DECISIONS (must be respected)

| Decision                              | Reason                                                                                 | Implementation Rule for AI Agent                                   |
|---------------------------------------|-----------------------------------------------------------------------------------------|----------------------------------------------------------|
| No Ace3 / LibStub in core             | Memory & load order control                                                            | Never require them; optional only for SharedMedia        |
| One global: `BLU`                     | Easy access, no locals leaking                                                         | All code uses `BLU.` or `local BLU = _G["BLU"]`            |
| Central frame in BLU.lua              | Single event bus                                                                       | All modules use `BLU.frame:RegisterEvent/UnregisterEvent` |
| Modules self-register                 | Plug-and-play, no TOC changes needed                                                   | Every module must call `BLU.RegisterModule(self)`        |
| PlaySound resolver in BLU.lua         | Single source of truth for muting + tiering                                            | Never play sounds directly from modules                 |
| Options panel built with native XML   | Zero dependencies                                                                      | No external UI libraries                                 |
| SavedVariables: `BLU_DB` only        | Simple, predictable                                                                   | Never use per-character unless explicitly requested     |

### Sound Resolution Flow (must be identical everywhere)
```lua
-- Called from every module
BLU:PlaySound(eventName, selectionTable)

-- Inside BLU.lua
function BLU:PlaySound = function(event, sel)
    local cfg = BLU_DB.profile.events[event] or {}
    if cfg.type == "Default" then
        BLU:MuteNative(event)                                    -- SetCVar per category
        PlaySoundFile("Interface\\AddOns\\BLU\\Sounds\\Default\\"..cfg.tier.."\\"..event..".ogg", cfg.channel or "Master")
    elseif cfg.type == "Other" then
        PlaySoundFile("Interface\\AddOns\\BLU\\Sounds\\OtherGames\\"..cfg.game.."\\"..cfg.tier.."\\"..event..".ogg", cfg.channel)
    elseif cfg.type == "Pack" and BLU:IsPackLoaded(cfg.pack) then
        PlaySoundFile("Interface\\AddOns\\BLU\\Sounds\\Packs\\"..cfg.pack.."\\"..event..".ogg", cfg.channel)
    else
        BLU:RestoreNative(event) -- safety
    end
end
```

---
## COMPLETE TASK LIST TO 100 % COMPLETION

### Phase: Options Panel & Zero-Error Release (CURRENT – P0)
All other work is blocked until this phase is green.

#### P0 – Options Panel Must Load & Work Perfectly
- [ ] `/blu` opens instantly with zero Lua errors (even first install)
- [ ] All four tabs (Events / Sounds / Modules / Profiles) display correctly
- [ ] Events tab: scrollable list of every module with checkbox + dropdown per event
- [ ] Dropdown organization:
   - Section “Default (Low / Med / High)”
   - Section “Other Games” → alphabetical game folders → tier sub-menu
   - Section “Packs” → only loaded packs appear
- [ ] Search EditBox at top of Sounds tab that filters dropdown contents live
- [ ] Sound preview on dropdown hover or dedicated Preview button (0.5 sec clip, 50 % volume)
- [ ] Module toggle checkboxes instantly enable/disable (no reload needed)
- [ ] Save button + “Reset to Defaults” working
- [ ] Profiles tab: Create / Rename / Delete / Copy To… functional
- [ ] All dropdowns use `UIDropDownMenu_SetWidth(260)` minimum for readability

#### P1 – Global Error Elimination
- [ ] Run in debug mode (`/run BLU_DB = nil; ReloadUI()`) → no errors
- [ ] First-install scenario (no BLU_DB) → graceful defaults
- [ ] Missing .ogg files → silent fallback to WoW native, never error
- [ ] SharedMedia missing → Packs section simply empty, no taint
- [ ] Nil checks on every `cfg.xxx` access
- [ ] Wrap every `PlaySoundFile` in `pcall` with debug message if fails

#### P2 – UI Polish & Performance
- [ ] FauxScrollFrame virtualization for Events & Modules tabs (50+ items)
- [ ] Tooltip on every dropdown item showing game name + tier
- [ ] “Random Sound” per-event option
- [ ] Volume fine-tune slider per event (0.1–2.0 multiplier)
- [ ] Channel selector dropdown (Master / SFX / Music / Ambience)

#### P3 – Final Validation Before Beta
- [ ] CurseForge packaging test (ZIP contains exact tree above)
- [ ] WeakAuras / Details! / Plater compatibility test (no taint)
- [ ] Memory usage < 1.2 MB with all modules enabled
- [ ] CPU usage < 0.05 ms per event trigger
- [ ] 100 % event coverage for The War Within launch events

### Future Phases (post-UI)
- Selective module categories in UI  
- Pack auto-downloader / workshop  
- Sound queue system (no overlap)  
- Classic version parity  

---
## DEVELOPMENT RULES (AI Agent Must Follow)

1. Never add Ace3 or any library to core  
2. All new modules go in `/Modules/` and call `BLU.RegisterModule(self)`  
3. All UI code lives exclusively in `/Interface/BLU_Options.lua` and `.xml`  
4. Sound paths are always full WoW format: `"Interface\\AddOns\\BLU\\Sounds\\..."`  
5. Every public function must have a comment block explaining parameters  
6. Use `pcall` around anything that touches the filesystem or CVars  
7. Commit messages: `feat(ui): add search to sounds dropdown` (conventional commits)  

### Example Module Template (copy-paste for new events)
```lua
-- Modules/MyNewEvent.lua
local module = {}
module.events = { "PLAYER_REGEN_DISABLED" }  -- example

function module:Enable()
    BLU.frame:RegisterEvent(unpack(self.events))
end

function module:Disable()
    BLU.frame:UnregisterEvent(unpack(self.events))
end

BLU.frame:SetScript("OnEvent", function(self, event)
    if not BLU_DB.profile.events.MyNewEvent.enabled then return end
    BLU:PlaySound("MyNewEvent", BLU_DB.profile.events.MyNewEvent)
end)

BLU.RegisterModule(module)
```

---
## SUCCESS METRICS
- Options panel opens in < 150 ms  
- Zero Lua errors in any scenario  
- Dropdown with 200+ sounds still responsive  
- Module toggle latency < 50 ms  
- Pack detection works with/without SharedMedia  
- CurseForge reviews ≥ 4.8 stars on launch  

---
**This document is the complete living context for the AI agent. All code generated must respect the tree, the rules, and the current task list.**  
**Last Updated**: November 29, 2025  
**Version**: 6.0.0-alpha  
**Status**: ACTIVE – UI Finalization Phase in Progress