# [TASK-02-03] Container run invocation

**Type:** Task
**ID:** TASK-02-03
**Status:** Open
**Parent Feature:** FEAT-02 — Walking-skeleton `pi-box run` launcher

---

## Summary

Implement the `podman run` call that starts the pi session interactively inside the profile image. This is the final step of the walking skeleton — at this point the image is already built or verified up to date.

## Implementation Notes

Minimal invocation for the walking skeleton (no mounts yet):

```bash
podman run \
  --rm \
  -it \
  "${IMAGE}" \
  pi
```

- `--rm`: clean up the container on exit (no dangling containers)
- `-it`: interactive + allocate a pseudo-TTY so pi's TUI works
- `"${IMAGE}"`: resolved in TASK-02-02 (either `pi-box-<profile>:latest` or `pi-box:base`)
- `pi`: the entrypoint command; passes any remaining args through if needed

**Extensibility note:** subsequent features will inject additional flags into this call:
- FEAT-03 adds `-v` mount flags
- FEAT-04 adds profile config file mounts
- FEAT-05 adds the session directory mount and `settings.json`

Structure the run invocation so these can be appended cleanly (e.g. build the flags into a bash array: `RUN_ARGS=(--rm -it)` then `podman run "${RUN_ARGS[@]}" "${IMAGE}" pi`).

## Acceptance Criteria

- [ ] `podman run` is invoked with `--rm` and `-it`
- [ ] Pi starts interactively inside the container and the terminal is usable
- [ ] Container is automatically removed after the session exits
- [ ] Script exits with the same exit code as the `podman run` command (preserve `$?`)

## Dependencies

| Depends on | Reason |
|---|---|
| TASK-02-01 | `IMAGE` variable must be resolved |
| TASK-02-02 | Image must be built/verified before run |

## Notes

- Use `exec podman run …` as the final call so the shell process is replaced by podman, giving correct signal propagation (Ctrl+C, SIGTERM).
- Avoid hardcoding `pi` as the entrypoint in the Containerfile CMD; passing it explicitly here keeps the container more general-purpose.
