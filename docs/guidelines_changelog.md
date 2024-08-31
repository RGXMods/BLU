
# Changelog Standards

This document outlines the standards for maintaining a consistent and clear changelog, including versioning practices. Adhering to these guidelines ensures that the changelog remains a useful and reliable resource for all maintainers.

---

## Versioning Standards

**Version Numbering:**  
Each version number should follow the format `vX.Y.Z`, where:

- **X (Major):** Incremented for significant changes or complete overhauls, typically including backward-incompatible changes.
- **Y (Minor):** Incremented for new features, updates, or changes that are backward-compatible.
- **Z (Patch):** Incremented for minor fixes, small enhancements, or bug patches.

**Pre-release and Build Metadata:**  
- **Pre-release Tags:** Denoted by a hyphen (`-`) followed by the tag (e.g., `v1.2.0-beta`).
- **Build Metadata:** Denoted by a plus sign (`+`) followed by build information (e.g., `v1.2.0+build123`).

---

## Change Categories

Use the following terms to categorize changes:

- **Added:** For introducing new features, functionality, or files. Examples include adding new sounds, modules, or configuration options.
  
- **Updated:** For enhancing or optimizing existing features, updating documentation, or making minor improvements. This also includes updates to ToC files or version numbers.
  
- **Fixed:** For correcting bugs, issues, or errors in the code. This term is used when resolving problems that previously caused incorrect behavior.
  
- **Removed:** For deleting features, files, or code that are no longer necessary. This includes the removal of deprecated features, unnecessary annotations, or obsolete files.
  
- **Renamed:** For changing the names of files, directories, variables, or functions to improve clarity or consistency. Use this term when a renaming operation is the primary change.
  
- **Moved:** Specifically for relocating files or directories within the project. This term should be used when files are moved to a new location within the directory structure.
  
- **Restructured:** For structural or organizational changes within files, such as reorganizing code for better maintainability. Use this when restructuring occurs without adding or removing significant functionality.

---

## Syntax and Notation Standards

### Brackets, Quotes, and File Names

- **Brackets `[ ]`:** Used to denote file names, paths, or specific variables within the changelog. For example, `[core.lua]` indicates that the change affected the `core.lua` file.

- **Quotes `"`:** Used around specific values, commands, or strings when they need to be referenced directly. For instance, `"/blu debug"` would refer to a command that a user can input.

- **File Names and Directories:** Always include the file extension (e.g., `.lua`, `.ogg`) and use forward slashes (`/`) for directory paths. New files or directories should be noted explicitly, and their paths should be clearly stated.

### Directory Notation for New Files

When introducing new files or directories, clearly indicate the full path relative to the root directory of the project:

- **Example:**
  - Added - New configuration file [config/settings.lua] - [/data/config/]
  - This indicates that `settings.lua` was added under the `data/config` directory.

### ToC Update Lines

ToC (Table of Contents) updates should include the following details:
- **Patch Name:** The name of the World of Warcraft patch (e.g., "Season of Discovery").
- **Build Number:** The build number associated with the patch (e.g., `1.15.3.55646`).
- **WoW Interface ToC Build Number:** The corresponding interface build number for WoW (e.g., `[ToC.11503]`).

- **Example:**
  - Updated - ToC for _classic_era_ - Season of Discovery Phase 4 (1.15.3.55646) [ToC.11503]
  - This indicates that the ToC was updated for the "Season of Discovery Phase 4" patch with build number `1.15.3.55646` and the WoW interface ToC build number `11503`.

---

## Changelog Structure

Each changelog entry should follow this structure:

```
vX.Y.Z-------------------------------------------------------------------
- [Term] - [Brief description of the change] - [Optional: specific files or areas affected]
```

### General Guidelines:

- **One Change per Line:** Document each change on its own line for clarity.
- **Consistent Terminology:** Use the defined terms consistently to ensure clear communication.
- **No Periods:** Do not use periods at the end of changelog lines.
- **Optional Details:** Include additional details (e.g., specific files, directories, or areas affected) if necessary for understanding the change.

### Specific Patterns:

- **Listing Multiple Files:** When a change affects multiple files, list them in brackets at the end of the line, separated by commas.
  
- **Detailed Descriptions:** Keep descriptions brief but informative, focusing on the impact of the change rather than the implementation details.

---

## Example Structure

```
v4.6.0-------------------------------------------------------------------
- Restructured - Shared event handlers in [core.lua] for better maintainability
- Renamed - [utils.lua] to [core.lua]
- Updated - .toc files to reflect new structure
- Added - More comprehensive debug logging
```

---

## Best Practices for Maintainers

- **Consistency:** Ensure that all terms and formatting are consistent with this guide.
- **Comprehensive Documentation:** Document all changes made in each release, maintaining a complete history.
- **Version Number Management:** Increment version numbers accurately according to the type and impact of changes.
- **Clarity and Brevity:** Descriptions should be concise but informative, avoiding unnecessary details.

---

## Notes

- **Internal Use:** This guide is intended for maintainers to ensure consistency in documenting changes.
- **Ongoing Updates:** This document should be updated as new practices or terms are adopted within the project.

---

