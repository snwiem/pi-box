# [FEAT-05] Automatic session persistence

**Type:** Feature
**ID:** FEAT-05
**Status:** Done
**Parent Epic:** EPIC-03 — Session Management
**PRD Reference:** FR-05

---

## Summary

Automatically persist pi session data to `<project-root>/.pi-box/<profile>/sessions/<session-id>/` on the host by creating the directory before container start and injecting a pi `settings.json` that redirects session storage to the mounted host path. Session data survives container stop and restart with no manual user action.

## User Story

> As a **developer**, I want pi's session context to survive container restarts so that I don't lose my working context between sessions.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [x] Configuration / settings
- [x] Session / runtime behaviour
- [x] Documentation

### In Scope
- Resolving `<project-root>` from `$PWD` (default) or `--project-root <path>`
- Constructing the session directory path and creating it with `mkdir -p` on first launch
- Generating a `settings.json` that points pi's session storage to the container-internal mount point
- Mounting the session directory into the container and the generated `settings.json` at pi's config location
- `.gitignore` documentation guidance for `.pi-box/`

### Out of Scope
- `--session <name>` and UUID-based session naming (FEAT-06 — this Feature uses a placeholder/default session for now)
- Session listing (FEAT-06)
- `mounts.yml` (deferred to v2)

## Acceptance Criteria

- [x] Session data is stored at `<project-root>/.pi-box/<profile>/sessions/<session-id>/` on the host
- [x] `<project-root>` defaults to `$PWD` when `--project-root` is not specified
- [x] `--project-root <path>` correctly overrides the session root
- [x] The session directory is created automatically on first launch (`mkdir -p`)
- [x] Pi is configured via `PI_CODING_AGENT_SESSION_DIR` env var (not settings.json) to write session data to `/pi-session` inside the container
- [x] Stopping the container and restarting with the same session directory resumes the pi session correctly
- [x] `.pi-box/` is documented in README and `docs/sessions.md` and excluded via `.gitignore`

## Tasks

| ID | Title | Estimate |
|---|---|---|
| TASK-05-01 | Session directory resolution & creation | S |
| TASK-05-02 | Pi `settings.json` injection for session storage path | S |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-02 | Launcher script and `RUN_ARGS` array must exist |
| FEAT-03 | `-v` mount pattern established |

## Notes

- OQ-03: the exact `settings.json` key for custom session storage must be validated against pi documentation before implementing TASK-05-02. Reference: https://pi.dev/docs/latest/settings#sessions
- The session directory is mounted into the container at a fixed, well-known path (e.g. `/pi-session`). Pi `settings.json` is configured to point to that path. This decouples the host directory layout from what pi sees inside the container.
