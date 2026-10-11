# BLU Agent Directives

This document records the framework-first build discipline enforced by
`AGENTS.md` and the shared RGX-Framework CI include
(`/.gitlab/ci/addon.yml`). Follow it before writing or changing any code,
UI, timer, event, aura, or slash-command surface.

## The MCP tool loop

Before writing addon code, run the RGX-Framework MCP tools in order. Each
step has a single, ordered purpose; do not reorder or skip:

1. `rgx_get_contract` — read the current declarative contract surface
   (the live `RGXAddon(name, opts)` keys the framework ships today).
2. `rgx_generate_addon` — scaffold the addon file from the contract so
   the generated Lua matches what the framework would produce for these
   opts.
3. `rgx_validate_addon` — validate the actual opts table against the
   contract; fail on unknown, removed, or tier-4 keys.
4. `rgx_audit_lua` — audit every changed Lua file for forbidden raw-WoW
   patterns (see below) and confirm generated Lua matches integration.

Compare the generated Lua with the existing integration, then validate the
actual opts table and audit every changed Lua file. Never hand-roll what
the framework ships.

## The declarative contract

Build addon behavior from the declarative `RGXAddon(name, opts)` table
using **only** keys the framework ships today. Read
`docs/DECLARATIVE-API.md` in `rgxmods/warcraft/RGX-Framework` before
writing code.

- `name` — the addon name (matches the `## Title` TOC field).
- `opts` — the declarative options table. Only shipped keys are valid;
  tier 4 keys are future targets, not runtime features.

Use `onInit` and addon-scoped methods only where the shipped declarative
surface genuinely cannot express the behavior.

## Forbidden raw-WoW patterns

The following patterns fail `rgx_audit_lua` and must not appear in shipped
Lua. Replace them with their framework-managed equivalents; migrate
existing compatibility paths deliberately instead of silently breaking
them.

| Forbidden pattern | Framework equivalent |
|---|---|
| raw `C_Timer` (e.g. `C_Timer.After`, `C_Timer.NewTicker`) | RGX timers / repeating schedules |
| manual event frames (`CreateFrame("FRAME")`, manual `SetScript`) | `RGX:RegisterEvent` / `RGX:RegisterUnitEvent` |
| `SLASH_` globals | framework slash command registration |
| unguarded `SetAttribute` | framework UI controls / dropdowns |
| raw aura plumbing (`UnitAura`, custom aura watching) | `RGXAuras` module |
| raw hook reassignment (`hooksecurefunc`, `HookScript`) | framework lifecycle hooks |

## Release discipline

Release through the GitLab MR pipeline and green shared validation, then
patch-bump through the same discipline and create a protected GitLab
release tag matching the TOC version. The release flow is:

1. Validate — `addon:validate` (MR + default branch) must pass for every
   diff via the shared `.gitlab/ci/addon.yml` include.
2. Contract bundle — `contract:bundle` (guarded to `main` / tags / MR
   when `tools/ci/package.json` is present); not re-triggered by a
   docs-only diff.
3. Mirror — `mirror:github` (guarded to `main` and `v*` tags);
   publish the identical protected GitLab tag to the downstream
   `RGXMods/BLU` mirror.

After merge to `main`, bump the patch version in `BLU.toc` (`## Version:`
`vX.Y.Z-beta.W` line), create a protected GitLab release tag matching the
TOC version, and verify the identical tag on the `RGXMods/BLU` mirror
before reporting distribution pickup.

## Related references

- Framework canonical docs: `rgxmods/warcraft/RGX-Framework`
  `docs/DECLARATIVE-API.md` and `docs/RGX-MCP.md`
- This addon's contract surface and validation rules: `AGENTS.md`
- Release and CI configuration: `.gitlab-ci.yml`,
  `rgxmods/warcraft/RGX-Framework /.gitlab/ci/addon.yml`
