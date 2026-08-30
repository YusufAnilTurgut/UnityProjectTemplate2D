---
name: unity-build-validation
description: Validate whether a Unity project is ready for a local, portfolio, CI, desktop, mobile, or WebGL build. Use when the user asks to check build readiness, diagnose Unity build failures, audit build configuration, or verify a release candidate. Do not use for routine gameplay implementation unless build validation is requested.
---

# Unity Build Validation

Evaluate build readiness using the project's actual Unity version, target platform, repository state, and available tooling. Default to diagnosis; edit files only when the user asks for fixes.

## Discover the Build Contract

1. Read applicable `AGENTS.md` files and project documentation.
2. Read `ProjectSettings/ProjectVersion.txt`, `Packages/manifest.json`, `Packages/packages-lock.json`, build profiles or build settings, and relevant Player/Quality/Graphics settings.
3. Identify the requested target, output expectations, scenes, development/release mode, and whether the build must run on another machine.
4. Inspect `git status` and distinguish source assets from ignored or generated Unity directories.

If no target is specified, validate the currently configured target and label that assumption.

## Static Checks

Check relevant risks:

- All required scenes are enabled and ordered correctly for the target.
- Packages and editor version are compatible and reproducible from versioned manifests.
- Source assets have `.meta` files and no obvious broken GUID, missing-script, or required-reference problems.
- Platform-specific scripts and plugins use appropriate define constraints and importer settings.
- Player settings, scripting backend, API compatibility, architecture, resolution, orientation, icons, compression, color space, and graphics APIs suit the target.
- `Resources`, Addressables, StreamingAssets, shaders, stripping, and link preservation are handled where the project uses them.
- WebGL checks include template, compression/decompression fallback, memory, exceptions, threading requirements, hosting headers, and responsive canvas behavior where relevant.
- Build output, `Library`, `Temp`, `Logs`, IDE files, and local settings are not accidentally treated as portable source.
- Runtime configuration does not depend on editor-only assets, absolute local paths, or unversioned files.

Avoid inventing requirements for systems the project does not use.

## Execute Available Verification

1. Prefer the project's existing build script, CI command, or Unity test command.
2. Resolve the exact Unity executable matching `ProjectVersion.txt` before running batch mode.
3. Do not launch batch-mode Unity against a project currently locked by an open Editor. Use existing logs and static validation instead, or explain the limitation.
4. Capture the exit code and inspect the full Editor/build log for the first causal error, not only the final failure summary.
5. When feasible, inspect the produced output and launch or smoke-test it on the target environment.

Do not publish, upload, deploy, commit, or push build artifacts without explicit authorization.

## Report

Report in this order:

1. Build blockers.
2. Target-specific warnings.
3. Portability and repository risks.
4. Commands run and their outcomes.
5. Checks that still require the Unity Editor, target device, browser host, credentials, or user confirmation.

Give exact file and setting locations for fixes. Clearly separate confirmed failures from preventive recommendations.
