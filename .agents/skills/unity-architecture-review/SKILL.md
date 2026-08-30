---
name: unity-architecture-review
description: Review an existing Unity project for architectural defects, runtime risks, lifecycle problems, and maintainability issues. Use when the user requests a Unity architecture review, whole-project code review, SOLID assessment, dependency analysis, or prioritized technical-case feedback. Do not use for ordinary feature implementation unless a review is also requested.
---

# Unity Architecture Review

Review behavior and risk before style. Ground every finding in the repository as it exists.

## Establish Context

1. Read the applicable `AGENTS.md` files and repository documentation before judging the design.
2. Inspect `ProjectSettings/ProjectVersion.txt`, `Packages/manifest.json`, the relevant scripts, and affected scenes, prefabs, and ScriptableObject assets.
3. Read `git status` and preserve all user changes. Never treat a dirty worktree as permission to revert files.
4. Identify the requested product requirements or technical-case document. Treat it as the behavioral source of truth when the user says so.

## Review Priorities

Check the areas that are relevant to the project rather than forcing every category into the report:

- Runtime correctness, missing states, invalid transitions, stale paths, race-like update behavior, and pooling reuse defects.
- Ownership and dependency direction between composition roots, services, domain models, MonoBehaviours, views, and input adapters.
- MonoBehaviour usage: keep engine lifecycle, serialization, scene references, transforms, coroutines, and rendering at Unity boundaries; flag domain logic coupled to MonoBehaviour only when that coupling creates a concrete cost.
- Interfaces and SOLID: require a real substitution, boundary, or testing benefit. Flag both tight coupling and ceremonial one-implementation abstractions.
- Lifecycle symmetry for event subscriptions, game-loop registration, pooled objects, cancellation, `IDisposable`, `OnEnable`/`OnDisable`, and destruction.
- ScriptableObjects: distinguish immutable configuration from mutable runtime state; validate required references and numeric invariants.
- Serialization and assets: account for prefab/scene references, `[SerializeField]`, Unity null behavior, `.meta` GUIDs, sorting layers, build scenes, and platform settings.
- Update strategy and execution order: look for duplicate ticking, order dependencies, mutation during iteration, unnecessary per-frame work, and hidden singleton initialization requirements.
- Tests and diagnostics proportional to the risk and blast radius.

Do not recommend patterns such as event buses, service locators, custom game loops, factories, repositories, or assembly definitions without identifying the concrete problem they solve in this codebase.

## Verify

Use non-mutating checks where feasible. Prefer existing test and build commands. Do not launch a second Unity Editor against an already-open project. State clearly when generated solution files, unavailable Unity binaries, or an open Editor prevent reliable compilation.

## Report

Present findings first, ordered by severity:

- `P0`: data loss, security, or project-wide failure.
- `P1`: major required behavior is broken or likely to regress.
- `P2`: meaningful defect, lifecycle risk, or incomplete contract.
- `P3`: low-impact maintainability, UX, or polish issue.

For each finding, give a concise title, behavioral impact, evidence with clickable file and line references, and the smallest defensible correction. Separate confirmed defects from assumptions. End with open questions and remaining test gaps. If no defects are found, say so directly.

Remain in review mode unless the user explicitly asks for implementation.
