# [TASK-05-01] Session directory resolution & creation

**Type:** Task
**ID:** TASK-05-01
**Status:** Open
**Parent Feature:** FEAT-05 — Automatic session persistence

---

## Summary

Implement the logic that resolves the session directory path on the host from `$PWD` (or `--project-root`) and creates it before the container starts.

## Implementation Notes

```bash
# project_root: from --project-root flag, defaulting to $PWD
PROJECT_ROOT="${ARG_PROJECT_ROOT:-$PWD}"

# session_id: placeholder until FEAT-06 wires up --session / UUID
# For FEAT-05, use a fixed default so the feature is testable end-to-end
SESSION_ID="${ARG_SESSION:-default}"

# Full host path
SESSION_DIR="${PROJECT_ROOT}/.pi-box/${PROFILE}/sessions/${SESSION_ID}"

# Create on first launch
mkdir -p "${SESSION_DIR}"
```

Then append to `RUN_ARGS`:
```bash
RUN_ARGS+=("-v" "${SESSION_DIR}:/pi-session")
```

`/pi-session` is the container-internal mount point pi's `settings.json` will reference (resolved in TASK-05-02).

Use an absolute path for `PROJECT_ROOT` to avoid issues with relative paths inside the container mount spec:
```bash
PROJECT_ROOT="$(cd "${PROJECT_ROOT}" && pwd)"
```

## Acceptance Criteria

- [ ] `PROJECT_ROOT` defaults to `$PWD` when `--project-root` is not provided
- [ ] `--project-root <path>` sets `PROJECT_ROOT` to the given (resolved absolute) path
- [ ] `mkdir -p "${SESSION_DIR}"` is called before `podman run`; no error if directory already exists
- [ ] The session directory is mounted into the container at `/pi-session` via a `-v` flag

## Dependencies

| Depends on | Reason |
|---|---|
| TASK-02-01 | `ARG_PROJECT_ROOT`, `ARG_SESSION`, and `PROFILE` variables must be available |

## Notes

- Use `$(cd … && pwd)` rather than `realpath` for portability across macOS and Linux.
- The `/pi-session` container mount point is a convention — it must match what is written into `settings.json` in TASK-05-02.
