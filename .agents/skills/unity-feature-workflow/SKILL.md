---
name: unity-feature-workflow
description: Implement or refactor a Unity gameplay, UI, tooling, or infrastructure feature from repository analysis through verification. Use when the user asks Codex to build, change, fix, or refactor Unity project behavior and expects code or asset edits. Do not use for explanation-only questions or review-only requests.
---

# Unity Feature Workflow

Carry Unity changes through context gathering, implementation, asset integration, and verification without expanding the requested scope.

## Understand the Change

1. Read applicable `AGENTS.md` files and project documentation.
2. Inspect `git status`; preserve all existing user changes and unrelated generated files.
3. Trace the current behavior from entry point to domain logic, Unity adapter, scene/prefab configuration, and visible result.
4. Inspect relevant `.meta` files, prefabs, scenes, ScriptableObjects, input actions, settings, and package versions before assuming the change is code-only.
5. State a short implementation plan when the work spans multiple systems or assets.

## Pass the Responsibility Gate

Before designing or editing a non-trivial feature:

1. List the current responsibilities of every type being changed.
2. Identify the single owner and source of truth for the requested behavior.
3. If the behavior creates a second independent reason for a type to change, extract a focused collaborator instead of growing that type.
4. Keep entity MonoBehaviours focused on Unity identity, serialized references, lifecycle, and composition. Extract independently changing movement, combat, targeting, health, production, selection, and persistence logic when Unity APIs are not required.
5. Separate input commands, gameplay validation, mutable runtime state, presentation, construction, and pool ownership.
6. Define who creates, initializes, updates, subscribes, cancels, disposes, and returns each affected object to a pool.
7. Before introducing an interface, base class, event bus, generic factory, custom update loop, or global manager, name the concrete duplication, substitution, ownership, or measured performance problem it solves. Keep the design concrete if no such problem exists.
8. Prefer commands for requested actions and events for completed state changes.

Treat a type that coordinates input, rules, and presentation; owns unrelated timers or state machines; accumulates unrelated serialized fields; or needs unrelated dependencies in tests as a boundary-review signal. Do not split cohesive behavior merely to reduce line count.

## Design in Sympathy With the Project

- Reuse existing boundaries, naming, factories, pools, interfaces, and update strategy when they remain suitable.
- Keep engine-bound concerns in MonoBehaviours and prefer plain C# for reusable domain logic when this reduces coupling or improves deterministic testing.
- Add an interface only for a meaningful boundary, substitution, or test seam.
- Keep ScriptableObjects as authored configuration unless mutable shared runtime state is explicitly intended.
- Use dependency injection from the project's composition root where practical. Avoid introducing global state merely to simplify one call site.
- Preserve serialization compatibility. Rename serialized fields with `FormerlySerializedAs` when appropriate, and never regenerate or hand-invent existing `.meta` GUIDs.
- Account for pooled-object reuse: initialization must reset mutable state, and release must undo registrations, subscriptions, targets, coroutines, and transient visuals.
- Pair every subscription or registration with an owner-appropriate unsubscribe or unregister path.

Choose the smallest design that fully handles the requested behavior. Avoid unrelated cleanup unless it is required for correctness.

## Implement

1. Make focused edits using the repository's formatting and conventions.
2. Update all affected runtime assets and configuration, not only C# call sites.
3. Add validation at authored-data boundaries and guards at public runtime boundaries where invalid state is possible.
4. Add or update focused tests when domain logic, lifecycle behavior, shared contracts, or a prior regression justifies them.
5. Do not commit, push, rewrite history, install packages, or change external services unless the user explicitly requests it.

## Verify

1. Re-read the changed call flow and inspect the final diff for accidental scope expansion.
2. Run the narrowest useful tests or compilation check available, then broaden verification when the blast radius requires it.
3. Check Unity-specific integration: serialized references, scene/build inclusion, prefab overrides, ScriptableObject values, layers, sorting layers, input bindings, pooled reactivation, and object lifecycle.
4. Confirm that each changed type has one primary reason to change and can be described in one clear sentence.
5. Do not open a second Unity Editor against an already-open project. If full verification is unavailable, report exactly what was and was not tested.

## Finish

Summarize the behavior changed, name the important files or assets, report verification results, and mention any required Inspector assignment or Unity reimport. Do not claim success based only on code compilation when the feature also depends on scene or prefab wiring.
