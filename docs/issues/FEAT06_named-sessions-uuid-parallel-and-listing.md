# [FEAT-06] Named sessions, UUID fallback, parallel sessions & listing

**Type:** Feature
**ID:** FEAT-06
**Status:** Open
**Parent Epic:** EPIC-03 — Session Management
**PRD Reference:** FR-06

---

## Summary

Replace the placeholder session ID from FEAT-05 with real session naming: `--session <name>` for human-readable names, auto-generated UUID when no name is given, and a `pi-box list-sessions [<profile>]` subcommand that shows existing sessions. Parallel pi-box instances on the same project are automatically isolated by their distinct session directories.

## User Story

> As a **developer**, I want to run multiple pi-box instances in parallel on the same project so that I can work on independent tasks simultaneously without interference.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [ ] Configuration / settings
- [x] Session / runtime behaviour
- [x] Documentation

### In Scope
- `--session <name>` producing `…/sessions/<name>/` as the session directory
- UUID auto-generation (via `uuidgen`) when `--session` is not provided, displayed to the user on start
- Verification that two simultaneous `pi-box run` instances on the same project use separate directories
- `pi-box list-sessions [<profile>]` subcommand showing existing sessions under `<project-root>/.pi-box/<profile>/sessions/`

### Out of Scope
- Session deletion (`pi-box delete-session`) — v2
- Resuming a session by partial name match — v2
- Cross-machine session portability

## Acceptance Criteria

- [ ] `--session <name>` stores session data at `<project-root>/.pi-box/<profile>/sessions/<name>/`
- [ ] Without `--session`, a UUID is generated with `uuidgen` and the session ID is printed to stdout before pi starts (e.g. `Session: a1b2c3d4-…`)
- [ ] Two parallel `pi-box run` invocations on the same project (with different or no `--session` values) use fully separate session directories and do not corrupt each other
- [ ] `pi-box list-sessions` (using `$PWD` as project root) lists all session directories for all profiles under `.pi-box/`
- [ ] `pi-box list-sessions <profile>` scopes the listing to the named profile
- [ ] Each row in `list-sessions` output includes: profile name, session name/UUID, and last-modified timestamp
- [ ] `list-sessions` exits cleanly with a "no sessions found" message when the sessions directory doesn't exist yet

## Tasks

| ID | Title | Estimate |
|---|---|---|
| — | No sub-tasks — wires `--session`/UUID into existing FEAT-05 logic + adds list-sessions dispatch branch | — |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-05 | Session directory structure and `SESSION_ID` variable must exist; this Feature replaces the placeholder value |

## Notes

- UUID generation: `uuidgen` is standard on Linux (util-linux) and macOS. Fallback: `cat /proc/sys/kernel/random/uuid` (Linux only). Add a helper function that tries `uuidgen` first.
- `list-sessions` is a new `case` branch in the `pi-box` script's subcommand dispatcher — no new file needed.
- `list-sessions` output format (suggested):
  ```
  PROFILE         SESSION                              LAST MODIFIED
  my-profile      my-feature                           2026-06-20 14:32
  my-profile      a1b2c3d4-5678-…                     2026-06-19 09:11
  ```
- `--project-root` should also be respected by `list-sessions` for consistency.
