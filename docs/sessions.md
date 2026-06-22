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
| `<session-id>` | `default` (placeholder until FEAT-06 wires up `--session` / UUID naming) |

The directory is created automatically on first launch (`mkdir -p`). Subsequent launches with the same profile and session ID resume the existing session.

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

## CLI Reference

| Flag / Env | Description |
|---|---|
| `--project-root <path>` | Override the project root directory (default: `$PWD`) |
| `--session <name>` | Name the session (not yet implemented — FEAT-06) |

See `pi-box run --help` for the full option list.
