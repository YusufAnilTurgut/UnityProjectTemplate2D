# Unity Project Agent Guide

## Purpose

This file defines the default engineering rules for AI agents working in this Unity project.
Apply it to the whole repository unless a nested `AGENTS.md` provides a more specific rule.

The goal is maintainable 2D gameplay code with clear ownership, testable logic, safe Unity
lifecycle handling, and changes that fit the existing project instead of forcing a template.

## Template Initialization

For a new game repository created with GitHub's **Use this template** action, the first Codex
task must explicitly invoke `$unity-project-bootstrap` before normal feature work and preferably
before the first interactive Unity Editor import. Provide the project name and, when known, the
company name, root namespace, application identifier, and intended build targets.

The bootstrap skill personalizes the generic project identity, creates
`Docs/PROJECT_BRIEF.md`, reviews optional packages, confirms the required Editor version,
preserves Unity asset references, and validates the initial import. After it completes, add the
repository root to Unity Hub and open it with the version recorded in
`ProjectSettings/ProjectVersion.txt`.

This is a one-time workflow for repositories created from the template. Do not rerun it for
ordinary development sessions, and do not run it while maintaining the source template
repository itself.

## Start Here

Before proposing or editing code:

1. Determine whether this is the source template or a project created from it. If a derived
   project still has the generic template identity, complete **Template Initialization** first.
2. Read `ProjectSettings/ProjectVersion.txt`, `Packages/manifest.json`, the root README,
   `Docs/PROJECT_BRIEF.md` when present, and any existing architecture documentation.
3. If `LocalContext/USER_PROFILE.md` exists, read it as local communication and learning
   context. It is not a source of project requirements and may be excluded from version control.
4. Run `git status` and preserve all existing user changes. Never revert unrelated work.
5. Inspect the relevant scripts, prefabs, scenes, ScriptableObjects, assembly definitions,
   and tests before choosing an implementation.
6. Identify the active render pipeline, input system, target platforms, scene entry point,
   and established namespace/folder conventions. Do not assume them.
7. State any important assumption that cannot be verified from the repository.

Existing project conventions take precedence over this guide when they are coherent and
intentional. Improve architecture incrementally; do not reorganize the whole project to add
one feature.

## Sources Of Truth

- Runtime behavior comes from code, scenes, prefabs, and ScriptableObject assets together.
- `Docs/PROJECT_BRIEF.md` records approved product scope and initial technical decisions. Keep
  it current, but trust verified runtime configuration when documentation becomes stale.
- `ProjectSettings` and build profiles define platform behavior.
- Unity `.meta` GUIDs define asset references. Preserve them when moving or renaming assets.
- The Inspector is configuration, not hidden runtime state.
- Documentation must describe the implementation that actually exists.

## Architecture Principles

### Dependency Direction

Keep dependencies pointing toward stable gameplay rules:

- Pure gameplay models and rules must not depend on UI.
- UI may depend on application-facing contracts, not concrete scene internals.
- Infrastructure such as input, persistence, audio, and pooling adapts Unity APIs to gameplay.
- Composition roots create concrete objects and connect dependencies.

Avoid circular dependencies between features. Shared code belongs in `Core` only when at
least two features genuinely use it.

### Responsibility And Growth Guardrails

Before adding non-trivial behavior to an existing type:

- List the type's current responsibilities and identify the single owner and source of truth
  for the requested behavior.
- Do not add behavior that gives the type a second independent reason to change. Extract a
  focused collaborator when movement, combat, targeting, health, production, selection,
  presentation, or persistence can evolve independently.
- Keep entity `MonoBehaviour` types focused on Unity identity, serialized references,
  lifecycle, and composition. Move reusable rules and mutable feature state into focused
  collaborators when Unity APIs are not required.
- Separate input translation, gameplay validation, runtime state, presentation, construction,
  and pool ownership. Do not let an input callback or UI view become the rule owner.
- Define who creates, initializes, updates, subscribes, cancels, disposes, and returns each
  object to a pool before implementation.
- Before adding an interface, base class, event bus, generic factory, custom update loop, or
  global manager, name the concrete duplication, substitution, ownership, or measured
  performance problem it solves. Keep the design concrete when no such problem exists.
- Use commands to request actions and events to report completed state changes. Do not use an
  event as an indirect command when the caller needs an immediate result.

Review a type's boundaries when it coordinates input, gameplay rules, and presentation; owns
multiple unrelated timers or state machines; has serialized fields from unrelated systems;
requires pool reset logic across unrelated concerns; repeatedly gains feature-specific
condition branches; or cannot be tested without constructing unrelated dependencies. These
are design signals, not line-count rules. Do not split cohesive behavior merely to shorten a
file.

### MonoBehaviour Or Plain C#

Use `MonoBehaviour` when a type needs at least one of these:

- A `Transform`, `GameObject`, component, prefab, or Inspector reference.
- Unity lifecycle callbacks.
- 2D physics, sprite or tilemap rendering, animation, coroutine hosting, or scene ownership.

Prefer a plain C# class when the type contains rules, state transitions, calculations,
selection logic, health, pathfinding, inventory, cooldowns, or other logic that does not need
a scene object.

Do not make every class a `MonoBehaviour`. Do not remove `MonoBehaviour` from presentation
or scene adapters merely to satisfy an abstract architecture rule.

### Interfaces

Create an interface when it represents a real boundary:

- Multiple implementations exist or are expected.
- A consumer must not know the concrete implementation.
- A subsystem boundary benefits from substitution or focused testing.
- Different entities share a capability such as damage, movement, selection, or production.

Keep interfaces small and behavior-focused. Name capabilities clearly, such as
`IDamageable`, `IMovable`, or `ISelectionService`.

Do not create an interface for every class. A single concrete implementation with no useful
boundary should remain concrete until variation or decoupling is real.

### Composition Root And Dependency Injection

- Create shared services and factories in an explicit scene bootstrap or composition root.
- Inject dependencies through constructors for plain C# classes.
- Use explicit `Initialize` methods for scene components when constructor injection is not
  available, and validate every required dependency.
- Keep service lookup and static access at the composition boundary.
- Avoid scattered `FindAnyObjectByType`, `GameObject.Find`, and global static dependencies.

Singletons are acceptable only for true scene-wide coordination points. Keep their number
small, include a duplicate-instance guard, and do not use them as a substitute for dependency
injection.

### ScriptableObject Configuration

Use ScriptableObjects for authored, reusable, mostly static configuration:

- Unit, item, ability, building, level, audio, or visual definitions.
- Prefab, icon, tuning, and other designer-controlled references.

Use private serialized fields and read-only public accessors. Validate ranges and required
references with attributes and `OnValidate`.

Do not store mutable per-session state in shared ScriptableObject assets unless shared mutable
state is the explicit design. Runtime health, cooldowns, ownership, progress, and temporary
collections belong in runtime state objects.

### UI Separation

Use an MVC/MVP-style boundary without forcing framework ceremony:

- View: a `MonoBehaviour` that owns Unity UI references, renders supplied state, and raises
  user-intent events.
- Controller or presenter: subscribes to view and service events, coordinates the use case,
  and decides what the view displays.
- Model or service: owns gameplay rules and must not depend on Unity UI types.

Views must not locate gameplay objects or implement gameplay rules. Services must not update
text, images, buttons, or panels directly. Always pair event subscriptions with unsubscription.

### Input

Input components translate device input into game intents. They may raycast or convert screen
coordinates, but they should delegate selection, movement, combat, and placement rules to the
owning gameplay service.

Use the input solution already installed in the project. Do not mix the legacy and new Input
Systems without a documented compatibility reason.

### Factories And Pooling

Use a factory when object creation also requires dependency injection, team assignment,
runtime initialization, registration, or consistent parenting.

Use pooling for objects created and released frequently enough to justify lifecycle
complexity. A pooled object must reset all mutable state, event subscriptions, timers,
selection state, visuals, and registrations before reuse.

For multiple prefab types, keep pools keyed by stable configuration or prefab identity. Do not
make one pool return unrelated objects without a clear ownership model.

Do not add pooling to rare, long-lived objects without profiling evidence or a requirement.

### Update Strategy

Choose the simplest correct mechanism:

- Events for work triggered by state changes.
- Coroutines for Unity-owned sequences and presentation timing.
- A normal `Update` for a small number of scene components.
- A centralized update loop for many similar runtime entities when it improves control or
  measured performance.

Centralized loops must support safe registration and unregistration during iteration. Avoid
per-frame allocations, LINQ, repeated component lookup, and work that can run only when state
changes.

### Lifecycle And Cleanup

Use Unity callbacks consistently:

- `Awake`: local component setup and invariant checks.
- `OnEnable`: subscribe and activate reusable behavior.
- `Start`: coordination that depends on other objects completing `Awake`.
- `OnDisable`: unsubscribe and stop reusable behavior.
- `OnDestroy`: release owned resources and dispose constructed services.

Plain C# objects that own subscriptions, registrations, pooled resources, or native resources
should implement `IDisposable`. `Dispose` must release owned resources exactly once. Do not add
`IDisposable` to passive data classes.

Prefer explicit initialization over Script Execution Order. Change execution order only when
the dependency cannot be expressed safely in code and document why.

## Project Structure

The template starts with this intentionally minimal layout:

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

Repository-level automation and context live outside `Assets`:

- `.agents/skills`: repo-local Codex workflows inherited by repositories made from this
  template.
- `Docs`: committed project intent and architecture decisions, created as they become real.
- `Tools`: deterministic local validation and maintenance scripts.
- `LocalContext`: ignored personal communication context; never a product requirement.

Do not pre-create speculative empty folders. Expand the layout only when real assets or code
need an owner:

- `Art`: project-owned sprites, sprite sheets, tile assets, animations, VFX, and related source
  assets.
- `Data`: project-owned ScriptableObject definitions and authored configuration.
- `Core`: small, stable contracts and rules genuinely shared by multiple features.
- `Features/<Feature>`: feature-owned runtime code, data, and UI. Add `Runtime`, `Data`, or `UI`
  subfolders only when that feature needs them.
- `Infrastructure`: Unity and external-system adapters such as input, persistence, audio,
  pooling, and platform services.
- `UI`: application-wide UI composition and shared presentation code. Keep feature-specific UI
  with its owning feature.
- `ThirdParty`: imported vendor assets. Do not place project-owned wrappers or overrides here.

Small projects may use technical folders such as `Buildings`, `Combat`, `Units`, and `UI`
directly under `Scripts`. Larger projects should prefer feature ownership with a small shared
`Core`. Choose one organization style based on actual project size, do not mix styles
arbitrarily, and do not create a generic `Managers` dumping ground.

Namespaces should mirror ownership and remain stable. Prefer one public type per file and make
the file name match the type name. Add assembly definitions only when they provide useful
compile boundaries, test access, or package isolation; avoid circular assembly references.

## Coding Standards

- Treat the root `.editorconfig` as the baseline IDE formatting policy. Follow a coherent
  existing style when a legacy file intentionally differs; do not reformat unrelated files.
- Use clear C# names and established project formatting.
- Prefer `sealed` for concrete classes not designed for inheritance.
- Keep serialized fields private and expose the smallest necessary API.
- Validate constructor and initialization arguments early with specific exceptions.
- Use `nameof` in exceptions and diagnostics.
- Represent discrete grid coordinates with `Vector2Int`; use `Vector2` or `Vector3` for world
  positions as appropriate.
- Avoid boolean parameters when an enum or separate command makes intent materially clearer.
- Comments explain non-obvious reasons and constraints, not line-by-line mechanics.
- Do not introduce abstractions, generic frameworks, or event buses without demonstrated
  ownership or coupling benefits.

## Validation And Error Handling

Validate at both authoring and runtime boundaries:

- Inspector ranges: `[Min]`, `[Range]`, and custom validation where useful.
- Asset references and combinations: `OnValidate` with actionable diagnostics.
- Runtime construction: argument guards and invariant checks.
- User actions: return a clear result for expected failures instead of throwing.

Expected gameplay failures such as blocked placement or unreachable paths are normal results.
Broken configuration and impossible internal states should fail early with enough context to
locate the owning object or asset.

## Performance Rules

Profile before broad optimization. Still avoid known hot-path mistakes:

- No repeated `GetComponent`, object search, or avoidable allocation in per-frame loops.
- Cache stable references.
- Reuse collections when ownership is clear.
- Pool high-churn objects and reset them completely.
- Keep sprite atlases, materials, sorting layers, and render pipeline batching coherent.
- Measure draw calls, `SetPass` calls, CPU time, garbage collection, and memory on the target
  platform rather than relying on assumptions.

Do not trade correctness and ownership clarity for speculative micro-optimization.

## Testing Strategy

Scale tests with risk:

- EditMode tests for pure logic, state transitions, validation, pathfinding, health, selection,
  cooldowns, and deterministic calculations.
- PlayMode tests for scene wiring, prefab initialization, input-to-command integration, pooling,
  lifecycle cleanup, and UI behavior.
- Build validation for every supported target before release.

Every bug fix should include a focused regression test when the affected logic can be tested
reliably. Avoid tests that only repeat implementation details.

## Asset And Scene Safety

- Move assets with their `.meta` files or through the Unity Editor.
- Never regenerate a GUID for an asset that is already referenced.
- Do not hand-edit scene, prefab, or ScriptableObject YAML unless the serialized structure and
  reference impact are understood.
- Keep third-party assets under `Assets/ThirdParty` and avoid editing vendor files directly.
- Put project-owned wrappers, materials, prefabs, and overrides under `Assets/_Project`.
- Generated folders such as `Library`, `Temp`, `Logs`, `Obj`, and builds must not be committed.

## Git Workflow

### Branch Strategy

Use a lightweight main-first workflow suitable for a solo Unity project:

- Small, focused documentation, configuration, and maintenance changes may be made directly on
  `main` when the working tree is understood and the user requests the Git operation.
- Use a separate branch for substantial features, risky fixes, experiments, package or engine
  upgrades, long-running work, and changes that should be reviewed independently.
- Name branches `<type>/<short-kebab-description>`, for example `feat/inventory-system`,
  `fix/player-spawn`, `refactor/combat-ownership`, or `chore/upgrade-packages`.
- Keep branch names lowercase, concise, and free of personal names, dates, or vague terms such
  as `work`, `changes`, and `test-branch`.
- Do not mix unrelated changes on one branch. Do not create or switch branches when existing
  user changes could be hidden or confused without first explaining the impact.

### Commit Messages

Use Conventional Commits in the form `type: imperative description`. An optional scope is
allowed when it adds useful ownership context: `type(scope): imperative description`.

- `feat`: add user-visible behavior or a new capability.
- `fix`: correct broken or unintended behavior.
- `refactor`: restructure code without intentionally changing behavior.
- `perf`: improve measured or requirement-driven performance.
- `test`: add or correct automated tests.
- `docs`: change documentation only.
- `build`: change packages, build profiles, or build tooling.
- `ci`: change continuous-integration automation.
- `chore`: perform repository maintenance that fits no more specific type.

Use a lowercase type, no space before the colon, and a concise imperative description. Keep
each commit focused on one logical change. Examples:

```text
feat: add inventory item stacking
fix(combat): enforce attack cooldown
refactor(input): extract selection handling
perf(rendering): reduce material instances
test(pathfinding): cover blocked destinations
docs: explain project bootstrap
build: configure WebGL profile
chore: update repository metadata
```

Do not use bare messages such as `fix`, `update`, `changes`, `wip`, or `final`. Do not combine
multiple commit types in one message; split unrelated work into separate commits.

### Commit And Push Safety

- Commit only when the user explicitly requests a commit. Permission to edit files does not
  imply permission to commit.
- Push only when the user explicitly requests a push. Permission to commit does not imply
  permission to push.
- Before committing, inspect `git status`, the staged diff, `git diff --check`, and relevant
  validation results. Stage only the intended files.
- Before pushing, confirm the current branch, upstream, remote URL, and local/remote commit
  relationship. Push only the intended branch.
- Never force-push, amend published commits, rebase shared work, delete branches, or rewrite
  history without explicit permission and a clear explanation of the impact.

## Agent Working Protocol

1. Explain what context is being inspected and what will change.
2. Keep edits focused on the requested behavior and existing ownership boundaries.
3. Preserve unrelated working-tree changes, including changes in files being edited.
4. Prefer structured APIs and Unity-supported workflows over text replacement in serialized
   assets.
5. Do not commit, push, rewrite history, install packages, or alter build/deployment settings
   unless the user explicitly requests it.
6. After edits, inspect the diff and run the narrowest meaningful validation. On Windows, use
   `Tools/Validate-UnityProject.ps1` for a closed-project import and compilation check.
7. Report what changed, what was verified, and any remaining manual Unity setup.

When reviewing code, report findings first, ordered by severity and supported by file and line
references. Prioritize runtime bugs, lifecycle leaks, broken serialized references, invalid
state, platform failures, and missing regression coverage over style preferences.

## Codex Skills

The following repo-local Codex skills are versioned under `.agents/skills`. `AGENTS.md` remains
the repository-wide source of engineering rules; skills provide task-specific workflows and do
not expand edit, commit, push, package-install, or deployment permissions.

### Unity Project Bootstrap

Use `$unity-project-bootstrap` once after creating a repository from this template, before
normal feature work and preferably before the first interactive Unity Editor import. It updates
the generic project identity, preserves Unity asset references, and verifies the initial import.
Do not invoke it for routine project openings or while maintaining the source template.

Example:

```text
$unity-project-bootstrap Initialize this template as My Game with root namespace MyStudio.MyGame.
```

### Unity Architecture Review

Use `$unity-architecture-review` for whole-project reviews, SOLID and dependency analysis,
lifecycle audits, or prioritized technical-case feedback. It reports findings before summaries
and ranks them from `P0` to `P3`. It must remain read-only unless implementation is explicitly
requested.

Example:

```text
$unity-architecture-review Review this Unity project and rank confirmed findings by severity. Do not edit files.
```

### Unity Feature Workflow

Use `$unity-feature-workflow` when implementing, fixing, or refactoring gameplay, UI, tooling,
or infrastructure. It covers repository analysis, focused implementation, Unity asset and
serialization integration, lifecycle checks, and verification.

Example:

```text
$unity-feature-workflow Add group movement for selected units, verify the integration, and do not commit or push.
```

### Unity Feature Scaffold

Use `$unity-feature-scaffold` when a real feature needs a new owner under
`Assets/_Project/Scripts/Features`. It creates `Runtime` plus only the requested `Data`, `UI`,
and test folders. It must not create speculative interfaces, managers, base classes, or assembly
definitions.

Example:

```text
$unity-feature-scaffold Create Inventory with runtime, data, UI, and EditMode test folders.
```

### Unity Build Validation

Use `$unity-build-validation` for build-readiness checks, build failure diagnosis, platform
configuration audits, and release-candidate verification. Always name the target platform when
it matters. Build, upload, deployment, commit, and push remain separate permissions.

Example:

```text
$unity-build-validation Validate this project for a WebGL portfolio build and report blockers without changing files.
```

Codex may select an installed skill automatically when the request clearly matches its
description. Prefer explicit `$skill-name` invocation when a specific workflow is required or
when combining review, implementation, and validation in one request.

## Verification Checklist

Before considering work complete:

- The Unity console has no new compiler errors.
- When Unity is closed on Windows, `Tools/Validate-UnityProject.ps1` succeeds.
- Required references are assigned and no scripts are missing.
- Event subscriptions, game-loop registrations, coroutines, and pooled state are cleaned up.
- Runtime ScriptableObject assets are not mutated unintentionally.
- Pure logic tests and relevant PlayMode tests pass.
- The target build succeeds when the change affects platform behavior.
- `git diff --check` passes.
- The final diff contains no unrelated asset, scene, package, or metadata churn.

## Common Anti-Patterns

Avoid these unless the project documents a specific reason:

- A god `GameManager` that owns feature logic instead of composition.
- A `Managers` folder containing unrelated global systems.
- An interface for every concrete class.
- Mutable shared ScriptableObject runtime state.
- Gameplay rules implemented inside UI views or input callbacks.
- Event subscriptions without deterministic cleanup.
- `GetComponent` or object searches every frame.
- Pooling without a complete reset contract.
- Script Execution Order used to hide missing initialization ownership.
- Large refactors bundled with a small feature or bug fix.

## Decision Reference

| Need | Default choice |
|---|---|
| Designer-authored static definition | ScriptableObject |
| Mutable runtime state or deterministic rule | Plain C# class |
| Scene, physics, rendering, or UI adapter | MonoBehaviour |
| Shared capability across entity types | Small interface |
| Cross-feature service boundary | Interface plus injected implementation |
| Scene-wide object construction | Composition root |
| Frequent spawn and release | Factory plus pool |
| Sparse state-driven work | Event |
| Many homogeneous per-frame updates | Central update loop after validation |
| UI presentation | View plus controller/presenter |
| Pure gameplay verification | EditMode test |
| Scene and lifecycle verification | PlayMode test |
