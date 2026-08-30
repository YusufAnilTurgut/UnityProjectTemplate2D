---
name: unity-feature-scaffold
description: Create the minimal feature-owned folder structure for a new Unity gameplay, UI, or infrastructure feature. Use when starting a named feature that does not yet have an owner under Assets/_Project/Scripts/Features and optional matching tests. Do not use for small changes inside an existing feature or to pre-create speculative architecture.
---

# Unity Feature Scaffold

Create only the directories a real feature needs, then continue implementation with the
project's normal feature workflow.

## Determine The Shape

1. Read `AGENTS.md`, `Docs/PROJECT_BRIEF.md` when present, and `git status`.
2. Inspect existing feature ownership and naming before creating a parallel structure.
3. Normalize the feature name to a valid PascalCase identifier such as `Inventory` or
   `SaveSystem`. Do not silently rename an ambiguous product term.
4. Always include `Runtime`. Add `Data`, `UI`, EditMode tests, or PlayMode tests only when the
   requested feature needs them.

## Create The Scaffold

Run the bundled script from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\unity-feature-scaffold\scripts\New-UnityFeature.ps1 -Name Inventory -IncludeData -IncludeUI -IncludeEditModeTests
```

Supported switches are `-IncludeData`, `-IncludeUI`, `-IncludeEditModeTests`, and
`-IncludePlayModeTests`. Use `-WhatIf` to preview changes. The script is additive and must not
overwrite existing files.

Do not add assembly definitions, interfaces, managers, base classes, or placeholder C# files
unless the feature's actual implementation requires them. Remove `.gitkeep` markers when the
project's established convention requires it.

## Verify

1. Add the feature's real implementation files using `$unity-feature-workflow` when requested.
2. Run `Tools/Validate-UnityProject.ps1` while Unity is closed, or let the open Editor finish
   importing the new folders.
3. Confirm Unity generated `.meta` files before committing.
4. Inspect the diff for duplicate ownership and unrelated files. Do not commit or push without
   explicit permission.
