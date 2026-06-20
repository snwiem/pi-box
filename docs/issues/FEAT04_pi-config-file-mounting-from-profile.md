# [FEAT-04] Pi config file mounting from profile

**Type:** Feature
**ID:** FEAT-04
**Status:** Open
**Parent Epic:** EPIC-02 — Core Launcher
**PRD Reference:** FR-02

---

## Summary

Mount the pi configuration files present in the profile directory (skills/, extensions/, AGENTS.md, APPEND_SYSTEM.md, prompts/, themes/) into the correct locations inside the container so that pi picks them up automatically. Files absent from the profile are not mounted, and pi falls back to its own defaults.

## User Story

> As a **developer**, I want to define a profile directory so that pi starts with exactly the skills, extensions, and context that project needs — and nothing more.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [x] Configuration / settings
- [ ] Session / runtime behaviour
- [x] Documentation

### In Scope
- Detecting which optional config paths exist in the profile directory
- Mounting each present path into its corresponding pi config location inside the container
- Documenting the profile directory layout and the mapping to pi's internal config paths

### Out of Scope
- Generating or templating profile config files
- Validating the contents of profile files (skills syntax, extension format, etc.)
- Merging profile config with any pre-existing container config (profile takes full precedence for each mounted path)

## Acceptance Criteria

- [ ] Each of the following, if present in the profile directory, is mounted into the container at the correct pi config path: `skills/`, `extensions/`, `AGENTS.md`, `APPEND_SYSTEM.md`, `prompts/`, `themes/`
- [ ] If a config path is absent from the profile, it is not mounted and pi uses its own default behaviour for that config type
- [ ] A profile directory containing none of the optional config files results in a clean vanilla pi session (no errors)
- [ ] The mapping between profile paths and container paths is documented (README or `docs/profiles.md`)

## Tasks

| ID | Title | Estimate |
|---|---|---|
| — | No sub-tasks — consists of research (path mapping) + implementation (conditional mount loop) | — |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-02 | `podman run` invocation and `RUN_ARGS` array must exist before mounts can be injected |
| FEAT-03 | Establishes the `-v` mount pattern this feature follows |

## Notes

- **Action required before implementation:** verify the exact pi config directory paths inside the container. Pi likely stores user config under `~/.pi/` (i.e. `/root/.pi/` or `/home/<user>/.pi/` depending on the container user). Reference: https://pi.dev/docs/latest/usage#context-files and https://pi.dev/docs/latest/extensions.
- Expected mapping (to be validated):

| Profile path | Container path |
|---|---|
| `skills/` | `~/.pi/agent/skills/` |
| `extensions/` | `~/.pi/agent/extensions/` |
| `AGENTS.md` | `<workdir>/AGENTS.md` (project context — mount alongside project) |
| `APPEND_SYSTEM.md` | `~/.pi/APPEND_SYSTEM.md` or similar |
| `prompts/` | `~/.pi/agent/prompts/` |
| `themes/` | `~/.pi/themes/` |

- Use read-only mounts (`:ro`) for all profile config files — the profile is a shared, VCS-managed artifact and must not be writable from inside the container.
