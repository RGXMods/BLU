# BLU Roadmap

BLU is currently in a stabilization and expansion phase for Retail Midnight, with a focus on reliable trigger handling and clean module growth.

## Active Focus

1. Startup stability
- Keep initialization fast and predictable on large addon stacks.
- Reduce lockups and rescan-heavy code paths during login and reloads.

2. Trigger reliability
- Harden event detection for Honor, Renown, Delve, and other progression systems.
- Prefer state comparison and delayed verification where Blizzard events are inconsistent.

3. Housing support
- Add dedicated Housing triggers once Blizzard's housing APIs and events are stable.
- Map housing milestones into BLU's per-event sound system instead of a single generic trigger.
- Cover likely first-wave triggers such as plot unlocks, room upgrades, trophy placement, visitor progression, and housing-related achievements.

4. Sound pack ecosystem
- Keep LibSharedMedia, DBM, Kitty, and direct BLU sound-pack registration working without startup freezes.
- Preserve external pack discovery while avoiding broad global scans that threaten client responsiveness.

5. UI and community
- Keep the options panel aligned with active feature work, including Housing planning and Discord support visibility.
- Continue using the RGX Discord community to prioritize new trigger categories and polish work.
