# Session Persistence

pi-box automatically persists pi session data to the host filesystem so that context survives container restarts.

---

## Session Directory Layout

Session data is stored at:

```
<project-root>/.pi-box/<profile>/sessions/<session-id>/
```

| Path component | Source |
|---|---|
| `<project-root>` | `$PWD` by default; override with `--project-root <path>` |
| `<profile>` | The profile name passed to `pi-box run` |
| `<session-id>` | Value of `--session <name>`, or an auto-generated UUID when `--session` is omitted |

The directory is created automatically on first launch (`mkdir -p`). Subsequent launches with the same `--session` name resume the existing session. When `--session` is omitted a fresh UUID is generated every time, creating a new session.

---

## How It Works

pi-box mounts the session directory into the container at `/pi-session` and sets the `PI_CODING_AGENT_SESSION_DIR` environment variable to `/pi-session`. Pi reads this variable at startup and writes all session files to that path, which maps back to the host directory.

```
Host: <project-root>/.pi-box/<profile>/sessions/<session-id>/
  ↕  mounted as
Container: /pi-session/
  ↕  pointed to by
PI_CODING_AGENT_SESSION_DIR=/pi-session
```

Using the environment variable (rather than injecting a `settings.json`) means:
- The base image stays clean — no pre-baked settings to conflict with.
- Profile-level `settings.json` customisations are not overwritten.
- `PI_CODING_AGENT_SESSION_DIR` has higher precedence than `sessionDir` in `settings.json`, so it always wins.

---

## `.gitignore` Guidance

Session data must **never** be committed to version control. Add `.pi-box/` to your project's `.gitignore`:

```gitignore
# .gitignore
.pi-box/
```

The pi-box repository itself ships with a `.gitignore` that already excludes `.pi-box/`.

---

## Listing Sessions

Use `pi-box list-sessions` to see all existing sessions for the current project:

```
$ pi-box list-sessions
PROFILE               SESSION                               LAST MODIFIED
-------               -------                               -------------
my-profile            my-feature                            2026-06-20 14:32
my-profile            a1b2c3d4-5678-90ab-cdef-000000000000  2026-06-19 09:11
```

Scope to a specific profile:

```bash
pi-box list-sessions my-profile
pi-box list-sessions my-profile --project-root ~/projects/other-app
```

Exits with a "no sessions found" message (exit 0) when no sessions exist yet.

---

## CLI Reference

| Flag / Env | Description |
|---|---|
| `--project-root <path>` | Override the project root directory (default: `$PWD`) |
| `--session <name>` | Name the session for resumability (omit to auto-generate a UUID) |

See `pi-box run --help` for the full option list.
