# Missing Sound Files

## Current Status
The BLU addon currently has NO sound files (.ogg) in the repository. The code references sounds that don't exist.

## Expected Sound Structure

Based on the code, BLU expects sounds in: `media/sounds/[gamename]/[soundfile].ogg`

### Final Fantasy Sounds (Referenced in code)
Location: `media/sounds/finalfantasy/`
- `victory.ogg` - Victory Fanfare (for level up)
- `itemget.ogg` - Item Get sound (for quests)
- `save.ogg` - Save Complete (for achievements)
- `crystal.ogg` - Crystal Theme (for reputation)

### Sound Categories Needed
Each game pack should have sounds for these events:
- **levelup** - When player gains a level
- **achievement** - When earning an achievement
- **quest** - When completing a quest
- **reputation** - When gaining reputation
- **honorrank** - PvP honor rank up
- **renownrank** - Renown rank increase
- **tradingpost** - Trading post rewards
- **battlepet** - Battle pet level up
- **delvecompanion** - Delve companion events

### Previously Included Games (from changelog)
The addon used to include sounds from:
- Elden Ring (6 variants)
- Legend of Zelda
- Final Fantasy
- Pokemon
- Super Mario
- Sonic
- Metal Gear Solid
- Mega Man
- Palworld
- And many more (50+ games mentioned)

### Old Sound Structure
Previously BLU used 3 volume variants per sound:
- `soundname_low.ogg` (50% volume)
- `soundname_med.ogg` (70% volume)  
- `soundname_high.ogg` (100% volume)

### New Sound Structure
The new system uses single files with software volume control:
- `gamename_eventtype.ogg` (e.g., `finalfantasy_levelup.ogg`)

## Required Actions

1. **Source Sound Files**
   - Obtain royalty-free or fair-use game sound effects
   - Convert to OGG format (best compression for WoW)
   - Normalize audio levels

2. **Create Directory Structure**
   ```
   media/sounds/
   ├── finalfantasy/
   ├── zelda/
   ├── pokemon/
   ├── mario/
   ├── sonic/
   └── [other games]/
   ```

3. **Name Files Correctly**
   - Use the exact names referenced in sound pack files
   - All lowercase filenames
   - .ogg extension required

4. **Test Each Sound**
   - Verify playback in WoW
   - Check volume levels
   - Ensure no clipping or distortion

## Legal Considerations
- Use only sounds you have rights to distribute
- Consider fair use for short game sound effects
- Credit original games appropriately
- Some sounds may need to be recreated/similar

## Temporary Solution
For testing, you could:
1. Use WoW's built-in sounds via sound kit IDs
2. Create simple placeholder sounds
3. Use royalty-free alternatives
4. Import from SharedMedia addons