# [FEAT-03] Volume mounting via `-v` CLI flags

**Type:** Feature
**ID:** FEAT-03
**Status:** Open
**Parent Epic:** EPIC-02 — Core Launcher
**PRD Reference:** FR-04

---

## Summary

Wire up the `-v <host-path>:<container-path>` flags collected during argument parsing and pass them through to the `podman run` invocation, allowing users to mount host directories (e.g. their project) into the pi container.

## User Story

> As a **developer**, I want to mount my project directory into pi-box so that pi can read and modify my code.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [ ] Configuration / settings
- [ ] Session / runtime behaviour
- [ ] Documentation

### In Scope
- Passing all `-v` values collected in `MOUNTS[]` (TASK-02-01) into the `podman run` call
- Supporting read-only mounts (`:ro` suffix)
- Supporting multiple `-v` flags in a single invocation

### Out of Scope
- Automatic injection of any mounts beyond those explicitly provided by the user (session mount is added in FEAT-05)
- `mounts.yml` declarative default mounts (deferred to v2 per PRD)
- Validation of host-path existence (keep it simple; let podman surface errors)

## Acceptance Criteria

- [x] `-v <host-path>:<container-path>` is accepted and forwarded to `podman run -v …`
- [x] Read-only mounts (e.g. `-v /data:/data:ro`) are supported without modification
- [x] Multiple `-v` flags in a single command are all passed through correctly
- [x] No mounts are silently injected beyond those the user specified (session mount deferred to FEAT-05)
- [x] A command with no `-v` flags runs without error (zero mounts is valid)

## Tasks

| ID | Title | Estimate |
|---|---|---|
| — | No sub-tasks — this is a small, focused wiring step | — |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-02 | `MOUNTS[]` array is populated in TASK-02-01; `podman run` call structure is established in TASK-02-03 |

## Notes

- Implementation is a one-liner addition to the `RUN_ARGS` array: iterate `MOUNTS[]` and append `"-v" "$mount"` for each entry.
- No semantic validation of mount strings is needed in v1; podman will surface errors for invalid paths.
