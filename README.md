# Unity 2D Project Template

A reusable Unity 6 URP 2D starting point with a project-owned asset structure, repository-wide
agent guidance, and repo-local Codex skills for implementation, review, and build validation.

## Baseline

- Unity `6000.5.10f1`
- Universal Render Pipeline `17.5.0`
- 2D Sprite and Tilemap tooling `1.0.0`
- Input System `1.20.0`
- Unity Test Framework `1.7.0`
- Shared C# formatting through `.editorconfig`

## Create A Project

1. Select **Use this template** on GitHub and create a new repository.
2. Clone the new repository. Do not develop directly in the template repository.
3. From the repository root, start Codex and run the repo-local bootstrap skill shown below.
4. After bootstrap validation succeeds, select **Add project from disk** in Unity Hub and choose
   the cloned repository root.
5. Open it with the Unity version recorded in `ProjectSettings/ProjectVersion.txt` and allow the
   first interactive import to finish.

```text
$unity-project-bootstrap Initialize this as My Game for Windows desktop with root namespace MyStudio.MyGame, create the project brief, and review optional packages.
```

## Project Structure

```text
Assets/
|-- _Project/
|   |-- Art/
|   |-- Audio/
|   |-- Data/
|   |-- Materials/
|   |-- Prefabs/
|   |-- Scenes/
|   |-- Settings/
|   |-- Scripts/
|   |   |-- Core/
|   |   |-- Features/
|   |   |-- Infrastructure/
|   |   `-- UI/
|   `-- Tests/
|       |-- EditMode/
|       `-- PlayMode/
`-- ThirdParty/
```

Project-owned assets belong under `Assets/_Project`. Imported vendor assets belong under
`Assets/ThirdParty` unless a package requires a different location.

Add `Sprites`, `Tilemaps`, `Animations`, or other art subfolders under `Art` only when the
project actually needs them.

## Startup Tools

Bootstrap creates `Docs/PROJECT_BRIEF.md` from approved product, platform, scene, package, and
architecture decisions. Use `TBD` for decisions that are not ready; do not invent requirements.

Run an exact-version Unity import and compilation check while the Editor is closed:

```powershell
powershell -ExecutionPolicy Bypass -File .\Tools\Validate-UnityProject.ps1
```

Create only the folders needed for a new feature:

```text
$unity-feature-scaffold Create Inventory with runtime, data, UI, and EditMode test folders.
```

The deterministic script used by that skill can also be run directly:

```powershell
powershell -ExecutionPolicy Bypass -File .\.agents\skills\unity-feature-scaffold\scripts\New-UnityFeature.ps1 -Name Inventory -IncludeData -IncludeUI -IncludeEditModeTests
```

## Codex Workflows

- `$unity-project-bootstrap`: personalize a repository created from this template.
- `$unity-feature-scaffold`: create minimal feature-owned folders on demand.
- `$unity-feature-workflow`: implement or refactor a Unity feature end to end.
- `$unity-architecture-review`: review architecture and runtime risks without editing.
- `$unity-build-validation`: validate a named build target and report blockers.

The full engineering rules are in [AGENTS.md](AGENTS.md). The skills are versioned under
`.agents/skills`, so repositories created from this template receive the same workflows.

## Version Control

Commit `Assets`, `Packages`, `ProjectSettings`, `.agents`, and project documentation. Unity's
generated `Library`, `Temp`, `Logs`, `UserSettings`, IDE project files, and local builds are
ignored.
