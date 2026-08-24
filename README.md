<div align="center">

<img src="media/Textures/logo.png" alt="BLU logo" width="144">

# <span style="color:#05dffa">B</span>etter <span style="color:#05dffa">L</span>evel-<span style="color:#05dffa">U</span>p<span style="color:#05dffa">!</span>

### <span style="color:#e67e23">Iconic game sounds for every milestone in World of Warcraft Retail</span>

[![Release](https://img.shields.io/github/v/release/donniedice/BLU?style=for-the-badge&logo=github&color=05dffa)](https://github.com/RGXMods/BLU/releases)
[![WoW Retail](https://img.shields.io/badge/WoW-Retail-148eff?style=for-the-badge&logo=worldofwarcraft&logoColor=white)](https://worldofwarcraft.blizzard.com/)
[![License](https://img.shields.io/github/license/donniedice/BLU?style=for-the-badge&color=2dc26b)](https://github.com/RGXMods/BLU/blob/main/LICENSE)

[![CurseForge](https://img.shields.io/badge/CurseForge-Download-f16436?style=flat-square&logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/blu-better-level-up)
[![Wago](https://img.shields.io/badge/Wago-Download-b96ad9?style=flat-square)](https://addons.wago.io/addons/blu)
[![WoWInterface](https://img.shields.io/badge/WoWInterface-Download-3598db?style=flat-square)](https://www.wowinterface.com/downloads/info26465-BLU-BetterLevelUp.html)
[![Discord](https://img.shields.io/badge/Discord-RealmGX-5865f2?style=flat-square&logo=discord&logoColor=white)](https://discord.gg/N7kdKAHVVF)

**[Features](#features) | [Quick Start](#quick-start) | [Commands](#commands) | [Custom Sounds](#custom-sounds) | [Support](#support)**

</div>

---

## <span style="color:#05dffa">What Is BLU?</span>

**BLU** replaces repetitive World of Warcraft sounds with memorable audio from more than 50 games. Choose unique cues for levels, achievements, quests, reputation, battle pets, delves, housing, the Trading Post, and other milestones.

BLU is the **Retail** edition. Classic players should install [<span style="color:#FFD700">BLU Classic</span>](https://github.com/RGXMods/BLU_Classic).

## <span style="color:#05dffa">Features</span>

| | Feature | What it provides |
|---|---|---|
| 🎵 | **50+ game sound libraries** | Favorites from Final Fantasy, Zelda, Mario, Skyrim, Pokemon, Warcraft, and many more |
| 🏆 | **Extensive event coverage** | Levels, achievements, quests, reputation, renown, battle pets, delves, honor, housing, and Trading Post activity |
| 🔊 | **Granular audio control** | Per-event choices, volume variants, previews, and selective muting of matching WoW sounds |
| 📦 | **Sound packs** | Automatic discovery plus APIs for simple and full three-volume third-party packs |
| 🗂️ | **Custom sounds** | Register your own `.ogg`, `.mp3`, or `.wav` files in game |
| ⚙️ | **Modern configuration** | Tabbed options, profiles, modular features, and built-in diagnostics |

> Each bundled selection includes Low, Medium, and High variants. Special collections may include several alternate cues.

## <span style="color:#05dffa">Quick Start</span>

1. Install BLU from [CurseForge](https://www.curseforge.com/wow/addons/blu-better-level-up), [Wago](https://addons.wago.io/addons/blu), [WoWInterface](https://www.wowinterface.com/downloads/info26465-BLU-BetterLevelUp.html), or [GitHub Releases](https://github.com/RGXMods/BLU/releases).
2. Install the required [RGX-Framework](https://github.com/RGXMods/RGX-Framework) dependency if your addon manager does not resolve it automatically.
3. Launch Retail WoW and type `/blu`.
4. Choose a sound for each event and preview it directly from the options panel.

Manual installs belong in:

```text
World of Warcraft/_retail_/Interface/AddOns/BLU
```

## <span style="color:#05dffa">Commands</span>

| Command | Description |
|---|---|
| `/blu` | Open options |
| `/blu help` | Show command help |
| `/blu status` | Show addon status |
| `/blu enable` / `/blu disable` | Enable or disable BLU |
| `/blu debug` | Toggle diagnostics |
| `/blu refresh` | Rebuild external and custom sound registries |
| `/blu rescan` | Discover newly registered media |
| `/blu addcustom myfile` | Add a compatible custom sound |
| `/blu removecustom path` | Remove a registered custom sound |

## <span style="color:#05dffa">Custom Sounds</span>

Open `/blu`, select the **Sounds** tab, and use **User Custom Sounds** to add a short filename such as `myfile.ogg`. BLU checks common AddOns locations and registers the first compatible match.

```text
/blu addcustom myfile
/blu addcustom myfile.ogg
/blu addcustom Interface\AddOns\myfile.ogg | My Custom Sound
```

Sound-pack authors can use `BLU:RegisterExternalSoundPack()` for simple files or `BLU:RegisterSoundPack()` for complete Low/Medium/High packs. See the [Sounds Guidelines](https://github.com/RGXMods/BLU/wiki/Sounds-Guidelines) for current layouts and examples.

## <span style="color:#05dffa">Troubleshooting</span>

- Confirm WoW's Master volume is enabled.
- Use `/blu rescan` after another addon registers new media.
- Use `/blu refresh` after adding or removing external/custom packs.
- Some audio may pause briefly the first time WoW caches it.

## <span style="color:#05dffa">Support</span>

- [GitHub Issues](https://github.com/RGXMods/BLU/issues) for reproducible bugs
- [RealmGX Discord](https://discord.gg/N7kdKAHVVF) for help, feedback, and sound suggestions
- [GitHub Sponsors](https://github.com/sponsors/donniedice) or [Buy Me a Coffee](https://buymeacoffee.com/donniedice) to support development

## <span style="color:#05dffa">Contributing</span>

Bug reports, translations, feature ideas, and sound suggestions are welcome. Keep reports focused and include reproduction steps when possible.

## <span style="color:#05dffa">License</span>

BLU is available under the [MIT License](https://github.com/RGXMods/BLU/blob/main/LICENSE).

---

<div align="center">

### <span style="color:#8B1538">R</span><span style="color:#7598b6">ealm</span><span style="color:#8B1538">G</span><span style="color:#8B1538">X</span> <span style="color:#4ecdc4">Mods</span>

**Made by [DonnieDice](https://github.com/donniedice) for the [RealmGX](https://realmgx.com) community.**

[<span style="color:#FFD700">BLU Classic</span>](https://github.com/RGXMods/BLU_Classic) | [<span style="color:#58be81">Simple Quest Plates</span>](https://github.com/RGXMods/SimpleQuestPlates) | [<span style="color:#e74c3c">Remove Nameplate Debuffs</span>](https://github.com/RGXMods/RemoveNameplateDebuffs)

_<span style="color:#e67e23">Make every level count with sounds that matter.</span>_

</div>
