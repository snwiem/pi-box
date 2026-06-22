# [TASK-07-02] Update container run invocation for custom command and TTY

**Type:** Task
**ID:** TASK-07-02
**Status:** Open
**Parent Feature:** FEAT-07 — `--` command override and TTY allocation

---

## Summary

Update the `podman run` call in the launcher script to use the `CMD` array produced by TASK-07-01 as the container command, and to allocate a TTY + interactive stdin when a custom command is provided.

## Implementation Notes

- After argument parsing, resolve the effective command:
  ```bash
  if [[ ${#CMD[@]} -eq 0 ]]; then
    EFFECTIVE_CMD=("pi")
    TTY_FLAGS=()          # retain existing TTY behaviour for normal pi launches
  else
    EFFECTIVE_CMD=("${CMD[@]}")
    TTY_FLAGS=("-it")     # always allocate TTY for custom commands (v1)
  fi
  ```
- Update the `podman run` invocation to splice in `TTY_FLAGS` and end with `"${EFFECTIVE_CMD[@]}"`:
  ```bash
  podman run --rm \
    "${TTY_FLAGS[@]}" \
    "${MOUNT_FLAGS[@]}" \
    "${SESSION_MOUNT_FLAGS[@]}" \
    "${ENV_FLAGS[@]}" \
    "$IMAGE" \
    "${EFFECTIVE_CMD[@]}"
  ```
- All existing flags (volume mounts, session mounts, env vars for `settings.json`) must remain in place — the only change is the command at the end and the optional `-it` prefix
- No changes to session directory creation, profile mount assembly, or `settings.json` injection logic — those code paths run unconditionally before the `podman run` call

## Acceptance Criteria

- [ ] `pi-box run <profile>` (no `--`) invokes `podman run` with `pi` as the command and no change to TTY flags from the current behaviour
- [ ] `pi-box run <profile> -- bash` invokes `podman run -it … bash`
- [ ] `pi-box run <profile> -- sh -c "echo hello"` invokes `podman run -it … sh -c "echo hello"` with all three tokens present
- [ ] Session mount, profile mounts, and env flags are present in the `podman run` call for both normal and custom command invocations
- [ ] No session directory logic or `settings.json` injection is skipped for custom command containers

## Dependencies

| Depends on | Reason |
|---|---|
| TASK-07-01 | `CMD` array must be populated before the run invocation can reference it |

## Notes

- V2 will introduce `--no-tty` to suppress `-it`; the `TTY_FLAGS` variable is intentionally separated from the rest of the flags to make that future change a single-line diff.
- PRD-001 OQ-01: whether `--no-tty` should also apply to the default `pi` command remains an open question for v2 design.
