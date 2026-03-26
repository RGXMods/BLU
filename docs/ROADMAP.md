## Planned Triggers

---

### Encounter / Combat
| Trigger | WoW Event | Notes |
|---|---|---|
| Encounter Finish | `ENCOUNTER_END` | fires on both win and wipe |
| Encounter Victory | `ENCOUNTER_END` | filter `success == 1` only |

---

### PvP
| Trigger | WoW Event | Notes |
|---|---|---|
| PvP Victory | `PVP_MATCH_COMPLETE` | check winner faction/team |

---

### Collectibles — not yet covered by any module
| Trigger | WoW Event | Notes |
|---|---|---|
| New Mount learned | `NEW_MOUNT_ADDED` | mount journal unlock |
| New Battle Pet collected | `NEW_PET_ADDED` | companion pet added to journal (distinct from `PET_BATTLE_CAPTURED`) |
| New Toy added | `NEW_TOY_ADDED` | toy box unlock |
| New Transmog appearance | `TRANSMOG_COLLECTION_SOURCE_ADDED` | single appearance slot unlocked |
| New Transmog set completed | `TRANSMOG_COLLECTION_UPDATED` | full set completed |
| New Recipe / Pattern learned | `SKILL_LINE_ABILITY_UPDATE` | profession recipe unlock |
| New Heirloom collected | `HEIRLOOMS_UPDATED` | heirloom added to collection |

---

### Loot / Items
| Trigger | WoW Event | Notes |
|---|---|---|
| New item in bags | `BAG_NEW_ITEMS_UPDATED` | generic new item received |
| Rare+ quality loot | `BAG_NEW_ITEMS_UPDATED` | filter by item quality threshold |
| Currency gained | `CURRENCY_DISPLAY_UPDATE` | any tracked currency increase |
| Equipment slot changed | `PLAYER_EQUIPMENT_CHANGED` | new gear equipped |

---

### Already Covered (reference)
- Level Up, Achievement, Achievement Criteria
- Battle Pet Level / Capture
- Quest Accept, Turn-In, Watch Update, % Progress (log snapshot diff)
- Honor Level, PvP Rank
- Renown (Major Faction + Covenant), Reputation
- Trading Post Purchase, Delve
- Housing Level / Item Acquired

---

## UI Organization Challenge

### Problem
The options panel is fixed at **6 columns × 2 rows = 12 tabs**, and all 12 are currently occupied. Each new trigger type naively needs its own tab, but adding ~4 more tabs (Combat, PvP, Collectibles, Loot) overflows the layout.

### Proposed Solutions

---

#### Option A — Merge small groups into existing tabs (least disruptive)
- **PvP Victory** → fold into existing **Honor** tab (already PvP-themed)
- **Encounter** → fold into a repurposed or expanded **Combat** tab
- **Collectibles** → one new shared tab covering Mount, Pet, Toy, Transmog, Recipe, Heirloom
- **Loot** → one new shared tab covering item/currency/gear triggers
- Net result: +2 new tabs needed → bump to a **3rd row** with 2–3 items, or shift tab width

---

#### Option B — Expand to 3 rows
- Increase `columnsPerRow` rows from 2 → 3, giving **18 slots**
- Each trigger group gets its own tab with no merging needed
- Tradeoff: pushes content area down, less vertical space for sound options

---

#### Option C — Increase columns per row (6 → 7)
- Change `TAB_BUTTON_WIDTH` from 102 → ~88 and `columnsPerRow` to 7
- Fits 14 tabs across 2 rows, enough for ~2 new tabs without a 3rd row
- Tradeoff: tabs become narrower, text may be tight on longer names

---

#### Option D — Category top-level tabs with sub-tabs
- Collapse current tabs into broader categories at the top level:
  - **Progression**: Level Up, Honor, Renown, Reputation, Delve
  - **Quests & Achievements**: Quest, Achievement
  - **Combat**: Encounter, PvP Victory
  - **Collectibles**: Mount, Pet, Toy, Transmog, Recipe, Heirloom
  - **Loot**: Items, Currency, Gear
  - **Other**: Battle Pets, Trading Post, Housing, Sounds, General
- Sub-tabs render inside the content area when a category is selected
- Most scalable long-term; most implementation work

---

#### Option E — Scrollable / overflow "More" tab
- Keep 2 rows × 6 cols hard limit
- Last slot becomes a **"More ▼"** dropdown button listing overflow tabs
- Low visual disruption, moderate implementation complexity
- Tradeoff: less discoverable for users who don't notice the dropdown
