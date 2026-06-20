# [EPIC-03] Session Management

**Type:** Epic
**ID:** EPIC-03
**Status:** Open
**PRD Reference:** FR-05, FR-06

---

## Summary

Covers automatic persistence of pi session data to a project-local directory on the host, named session support, UUID-based fallback naming, and a `list-sessions` subcommand. By the end of this Epic, pi context survives container restarts and multiple parallel pi-box instances on the same project operate without interference.

## Goal

A developer can stop and restart a pi-box session and resume exactly where they left off, and can run multiple independent pi-box instances against the same project simultaneously without session collisions.

## Scope

### In Scope
- Session directory layout: `<project-root>/.pi-box/<profile>/sessions/<name-or-uuid>/`
- `<project-root>` defaulting to `$PWD` with `--project-root` override
- Automatic session directory creation on first launch
- Pi `settings.json` injection to redirect session storage to the host-mounted path
- `--session <name>` flag and UUID auto-generation fallback
- `pi-box list-sessions [<profile>]` subcommand
- `.gitignore` guidance for `.pi-box/`

### Out of Scope
- Session deletion or archiving (v2)
- Session migration between machines
- `mounts.yml` (deferred to v2)

## Child Issues

| ID | Title | Status |
|---|---|---|
| FEAT-05 | Automatic session persistence | Open |
| FEAT-06 | Named sessions, UUID fallback, parallel sessions & listing | Open |

## Acceptance Criteria

- [ ] All child Features are completed and accepted
- [ ] Stopping and restarting a named session resumes pi context correctly
- [ ] Two parallel `pi-box run` invocations against the same project use separate session directories and do not interfere

## Dependencies

| Depends on | Reason |
|---|---|
| EPIC-02 | Launcher script and `podman run` invocation must exist before session mounts can be injected |

## Notes

- Session data must never end up inside the profile directory (profile must stay VCS-clean).
- `.pi-box/` should be listed in the repo's `.gitignore` and documented as something developers should add to their project `.gitignore`.
