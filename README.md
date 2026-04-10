# BLU | Better Level-Up!

BLU is a Retail World of Warcraft addon that swaps default progression sounds with curated audio from many other games, while giving you per-event control over what plays and when.

Current release: `v6.3.0`

## What BLU Does

- Replaces milestone sounds for core WoW progression moments
- Lets you choose from BLU internal packs, discovered external packs, and user custom sounds
- Supports profiles for different characters, stream setups, or playstyles
- Includes a dedicated Debug tab for scoped troubleshooting
- Uses a modular architecture so feature areas can be enabled and managed cleanly

## Supported Event Areas

- Level Up
- Achievement
- Battle Pets
- Delve
- Honor
- Housing
- Quest
- Renown
- Reputation
- Trading Post

## Highlights In v6.3.0

- Added a dedicated Profiles tab with saved profile management, import/export flows, quick presets, and realtime list updates
- Added preset application flows for adventure, spooky, minimal, and DonnieDice-curated setups
- Expanded the options UI to a 3-row alphabetical tab layout with new placeholder modules for Combat, Collectibles, Loot, and Prey
- Split out a dedicated Debug module and tab with scoped troubleshooting controls
- Improved Delve life-credit sound reliability and finalized nested dropdown behavior
- Hardened popup and addon metadata handling for newer WoW API environments

## Profiles

The Profiles tab now supports:
- viewing saved profiles and the active profile
- creating, loading, renaming, deleting, and resetting profiles
- importing/exporting profile strings
- duplicating the active profile with sequential `Copy` naming
- applying quick presets to the selected profile

## Debug

The Debug tab is backed by `modules/Debug/Debug.lua` and is meant to be lightweight for this release.

You can:
- enable or disable debug mode
- toggle scoped debug categories like tabs, options, registry, loader, sounds, profiles, and feature modules

This is a soft implementation intended to prepare for deeper tooling later without overloading the General tab.

## Commands

- `/blu` opens the options panel
- `/blu help` shows command help
- `/blu debug` toggles debug mode
- `/blu status` shows addon status
- `/blu enable` enables BLU
- `/blu disable` disables BLU
- `/blu refresh` rebuilds external and user custom sound pack data
- `/blu rescan` rescans registered media
- `/blu addcustom myfile` tries to add a custom sound by short name or path
- `/blu removecustom path` removes a custom sound

## Installation

Install BLU into:

```text
World of Warcraft\_retail_\Interface\AddOns\BLU
```

Sources:
- CurseForge: https://www.curseforge.com/wow/addons/blu-better-level-up
- Wago: https://addons.wago.io/addons/blu
- WoWInterface: https://www.wowinterface.com/downloads/info26465-BLU-BetterLevelUp.html
- GitHub Releases: https://github.com/donniedice/BLU/releases

## Sound Packs And Custom Sounds

BLU supports:
- built-in BLU sounds
- external addon sound packs discovered at startup
- direct registration via `BLU:RegisterExternalSoundPack(...)`
- user custom `.ogg`, `.mp3`, and `.wav` files

The main user-facing custom sound flow is in the Sounds tab.

## Compatibility

- WoW Retail only
- Interface version: `120001`
- For Classic support, use `BLU Classic`

## Roadmap

See [ROADMAP.md](./ROADMAP.md).

Near-term roadmap items include:
- expanded debug tooling beyond the current scoped toggle model
- continued Profiles tab compaction and UX polish
- more preset curation and named setup flows
- ongoing event-trigger verification and sound coverage cleanup

## Release Workflow

Alpha releases should use the helper in [`scripts/release-alpha.ps1`](./scripts/release-alpha.ps1).

The default flow pushes the `alpha` branch but keeps the tag local so GitHub/Discord only emit one notification.
See [`docs/RELEASING.md`](./docs/RELEASING.md) for the exact commands.

## Support

- Discord: https://discord.gg/N7kdKAHVVF
- GitHub Issues: https://github.com/donniedice/BLU/issues
- RealmGX: https://realmgx.com

## License

MIT. See [LICENSE](./LICENSE).
