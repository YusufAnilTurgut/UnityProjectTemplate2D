---
name: unity-project-bootstrap
description: Personalize, document, trim, and verify a repository created from this Unity project template. Use once after GitHub Use this template, before normal feature work and preferably before the first interactive Unity import. Do not use for routine project openings, feature implementation, or engine upgrades.
---

# Unity Project Bootstrap

Turn a fresh template copy into a named, documented, validated project without disturbing
Unity asset references or adding speculative gameplay architecture.

## Gather Decisions

1. Read `AGENTS.md`, `README.md`, `ProjectSettings/ProjectVersion.txt`,
   `Packages/manifest.json`, and `git status`.
2. Refuse to bootstrap the source template repository itself. Continue only in a repository
   created from the template or when the user explicitly requests reinitialization.
3. Confirm the project name. Collect company name, root namespace, application identifier,
   target platforms, orientation, default resolution, window mode, startup scene name, and a
   one-sentence product concept when relevant.
4. Ask only for missing decisions that materially change project configuration. Record unknown
   product decisions as `TBD`; do not invent requirements.
5. Check whether Unity is open. Never start a second Editor against the same project.

## Personalize

- Update `companyName`, `productName`, display defaults, orientation, and approved platform
  identifiers in `ProjectSettings/ProjectSettings.asset`.
- Set `m_ProjectGenerationRootNamespace` in `ProjectSettings/EditorSettings.asset` to a valid
  C# namespace.
- Rename the sample scene only when requested. Move it with its `.meta` file and verify the
  build-scene reference after Unity imports the move.
- Replace generic template wording in `README.md` while retaining setup and skill usage notes.
- Rename the local folder, Git remote, or GitHub repository only with explicit permission.

Use valid C# identifier segments and reverse-DNS application identifiers. Do not perform broad
text replacement across packages, generated files, serialized assets, or `.meta` files.

## Create The Project Brief

Use `assets/PROJECT_BRIEF.template.md` to create `Docs/PROJECT_BRIEF.md`. Replace every
placeholder with an approved value or `TBD`; leave no `{{PLACEHOLDER}}` tokens. Treat the brief
as committed product context, not local user-profile data.

Include product intent, technical baseline, platforms, presentation defaults, scene plan,
package decisions, architecture constraints, first-playable scope, and open decisions. Keep it
concise enough to remain useful to future agents.

## Review Packages

List direct dependencies from `Packages/manifest.json` by capability. Ask which optional
capabilities the project needs before removing anything. Typical review candidates include
Visual Scripting, Multiplayer Center, AI Navigation, Timeline, and collaboration tooling.

- Never remove a package only because it appears unused in the empty template.
- Keep URP, Input System, and Test Framework unless the user explicitly chooses alternatives.
- Change dependencies only after approval, then allow Package Manager to resolve the lock file.
- Record retained and removed packages with reasoning in `Docs/PROJECT_BRIEF.md`.

## Preserve The Template Contract

- Keep project-owned assets under `Assets/_Project` and vendor assets under
  `Assets/ThirdParty`.
- Move Unity assets together with their `.meta` files.
- Do not add sample gameplay, global managers, base classes, or speculative dependencies.
- Do not commit, push, create repositories, or change external services without explicit
  permission.

## Verify

1. When Unity is closed on Windows, run `Tools/Validate-UnityProject.ps1`. Otherwise use the
   narrowest equivalent import and compilation check available.
2. Confirm the build scene, input asset, render-pipeline references, package resolution, and
   generated folder `.meta` files.
3. Inspect the diff for generated files, accidental GUID changes, unresolved brief
   placeholders, absolute paths, and leftover generic identity.
4. Confirm that `Library`, `Temp`, `Logs`, `UserSettings`, IDE project files, and local builds
   are not staged.
5. Report configuration choices, removed packages, validation results, and any remaining
   manual Unity Hub or platform setup.
