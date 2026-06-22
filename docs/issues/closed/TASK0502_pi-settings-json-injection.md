# [TASK-05-02] Pi `settings.json` injection for session storage path

**Type:** Task
**ID:** TASK-05-02
**Status:** Done
**Parent Feature:** FEAT-05 — Automatic session persistence

---

## Summary

Research the exact pi `settings.json` key(s) needed to redirect session storage to a custom path, then implement generation and injection of that settings file into the container so pi writes session data to `/pi-session` (the host-mounted directory).

## Implementation Notes

**Step 1 — Research (OQ-03):**
Before writing any code, check https://pi.dev/docs/latest/settings#sessions for the correct `settings.json` schema. The expected shape is something like:

```json
{
  "sessions": {
    "directory": "/pi-session"
  }
}
```

Validate this against the actual pi documentation and adjust accordingly.

**Step 2 — Generate `settings.json` at launch time:**

```bash
SETTINGS_FILE="${SESSION_DIR}/pi-settings.json"

cat > "${SETTINGS_FILE}" <<EOF
{
  "sessions": {
    "directory": "/pi-session"
  }
}
EOF
```

Writing the settings file into the session directory reuses the already-mounted volume, avoiding an extra mount.

**Step 3 — Mount `settings.json` into the container at pi's config location:**

Pi likely reads `settings.json` from `~/.pi/settings.json` (verify during research step). Add to `RUN_ARGS`:

```bash
RUN_ARGS+=("-v" "${SETTINGS_FILE}:/root/.pi/settings.json:ro")
```

Mount as read-only (`:ro`) — the settings file is generated fresh on every launch and must not be modified from inside the container.

**Fallback:** if pi does not support a `settings.json` override for session path, investigate environment variable or CLI flag alternatives.

## Acceptance Criteria

- [x] The correct mechanism for session storage path override is identified: `PI_CODING_AGENT_SESSION_DIR` env var (higher precedence than `sessionDir` in settings.json; no extra file needed)
- [x] Env var injected via `-e PI_CODING_AGENT_SESSION_DIR=/pi-session` on every `podman run`
- [x] No settings.json generated or mounted — env var approach is cleaner and avoids conflicts with profile-level settings.json
- [x] Pi writes session data to `/pi-session` inside the container (i.e. the host-mounted session directory)
- [x] Stopping and restarting with the same session directory correctly resumes the session

## Dependencies

| Depends on | Reason |
|---|---|
| TASK-05-01 | `SESSION_DIR` and the `/pi-session` mount must exist before this task can write or mount the settings file |

## Notes

- If the pi config directory inside the container is not `/root/.pi/`, adjust the mount target accordingly. This should be confirmed during Step 1.
- Do not bake `settings.json` into the base image — it must be generated dynamically per session so each session points to its own directory.
