# Comprehensive Guide: Adding Custom Sounds to the BLU (Better Level Up!) Addon

This guide provides a detailed process for adding and integrating custom sounds into the BLU addon. The steps are organized to ensure consistency, clarity, and completeness in the addition of new sound assets.

---

## Overview

Adding custom sounds to the BLU addon involves several key steps:
1. **Sound Preparation:** Processing and exporting sound files using audio editing tools.
2. **File Organization:** Structuring sound files within the addon directory.
3. **Code Integration:** Updating the `sounds.lua` file to reference new sounds.
4. **Testing and Validation:** Ensuring the sounds function correctly within the addon.

Following this guide ensures all aspects of sound integration adhere to BLU's standards.

---

## Step 1: Sound Preparation

### 1.1 Importing and Editing Audio Files

1. **Launch Audacity:**
   - Open the audio file you want to use in Audacity.
   - **Example:** `victory_fanfare.mp3`

2. **Trim Silence:**
   - Highlight the portions of the audio containing silence at the beginning and end.
   - Use `Edit > Remove Special > Trim Audio` to remove these sections.

3. **Normalize Loudness:**
   - Select the entire audio track (Ctrl + A).
   - Navigate to `Effect > Volume and Compression > Loudness Normalization`.
   - Set the following parameters:
     - **Perceived Loudness:** `-23.0 LUFS`
     - **Treat Mono as Dual-Mono:** Enabled
   - Click `OK` to apply.

4. **Export Audio:**
   - Go to `File > Export > Export as OGG`.
   - **Format:** OGG Vorbis
   - **Channel:** Mono
   - **Sample Rate:** 48000 Hz
   - **Quality:** 10
   - Save the file as `sound_name_low.ogg` (e.g., `victory_fanfare_low.ogg`).

### 1.2 Adjusting Volume Levels in Adobe Audition

1. **Open the Exported OGG File:**
   - Load the `sound_name_low.ogg` file into Adobe Audition.

2. **Create Low Volume Track:**
   - Select all audio (Ctrl + A).
   - Adjust the volume to `-10 dB`.
   - Export the audio with default settings:
     - **Untick** `Include Markers and Other Metadata`.
     - Save as `sound_name_low.ogg`.

3. **Create High Volume Track:**
   - Undo the volume adjustment (Ctrl + Z).
   - Set the volume to `+10 dB`.
   - Export the audio as `sound_name_high.ogg`.

Repeat this process for each sound you intend to add.

---

## Step 2: File Organization

### 2.1 Structuring Sound Files

1. **Directory Structure:**
   - Place all `*.ogg` files in the `BLU/sounds/` directory.
   - Ensure that each sound file is named following the pattern `sound_name_low.ogg`, `sound_name_med.ogg`, and `sound_name_high.ogg`.

   **Example:**

    ```
    BLU/
    ├── sounds/
    │   ├── victory_fanfare_low.ogg
    │   ├── victory_fanfare_med.ogg
    │   └── victory_fanfare_high.ogg
---

## Step 3: Code Integration

### 3.1 Updating the `sounds.lua` File

1. **Open the `sounds.lua` File:**
   - Located at `Interface\Addons\BLU\sounds.lua`.

2. **Add New Sound Options:**
   - Update the `soundOptions` table to include your new sound.

   **Example**
   ```
    soundOptions = {
        "Victory Fanfare",
        "Achievement Unlocked",
        ...
    }
3. **Define Sound Paths:**
   - Add your sound file paths to the `sounds` table.

    **Example**
    ```
    sounds = {
        [3] = {
            [1] = "Interface\\Addons\\BLU\\sounds\\victory_fanfare_low.ogg",
            [2] = "Interface\\Addons\\BLU\\sounds\\victory_fanfare_med.ogg",
            [3] = "Interface\\Addons\\BLU\\sounds\\victory_fanfare_high.ogg"
        },
        ...
    }
---

## Step 4: Testing and Validation

### 4.1 In-Game Testing

1. **Launch World of Warcraft:**
   - Load the game and ensure the BLU addon is enabled.

2. **Trigger Events:**
   - Perform in-game actions that trigger sounds (e.g., level up, achievement).
   - Confirm that the new sounds play correctly.

3. **Debugging:**
   - If the sounds do not play, double-check the file paths and volume levels in the `sounds.lua` file.
   - Ensure that the `sounds.lua` file has been saved and reloaded in the game.

---

## Conclusion

By following this guide, you will successfully add and integrate custom sounds into the BLU addon, enhancing the user experience with personalized audio cues.
