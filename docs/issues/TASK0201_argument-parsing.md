# [TASK-02-01] Argument parsing

**Type:** Task
**ID:** TASK-02-01
**Status:** Open
**Parent Feature:** FEAT-02 — Walking-skeleton `pi-box run` launcher

---

## Summary

Implement the argument parsing block in the `pi-box run` subcommand, covering all flags that will be used across the full launcher (including those added in later features) so that the parsing layer doesn't need to be revisited piecemeal.

## Implementation Notes

Parse the following in the `run` subcommand:

| Flag | Type | Default | Notes |
|---|---|---|---|
| `<profile>` | positional, required | — | First non-flag argument |
| `--force-rebuild` | boolean | false | Bypass image staleness check |
| `--session <name>` | string, optional | UUID (generated later in FEAT-06) | Human-readable session name |
| `--project-root <path>` | string, optional | `$PWD` | Overrides the implicit project root |
| `-v <host:container>` | repeatable string | — | Collected into an array; passed through to `podman run` in FEAT-03 |

Implementation approach:
- Use a `while` loop with `case` on `$1` for portability (avoid `getopt`/`getopts` for `-v` repeatability across platforms)
- Accumulate `-v` values in a bash array: `MOUNTS+=("$2")`
- Validate that `<profile>` is non-empty after parsing; print usage and `exit 1` if missing
- Export parsed values as shell variables for use by the build and run steps

## Acceptance Criteria

- [ ] All flags listed above are parsed correctly
- [ ] Multiple `-v` flags are collected without dropping any
- [ ] `--project-root` defaults to `$PWD` when not specified
- [ ] Missing `<profile>` argument prints a usage message and exits with code 1
- [ ] Unknown/unsupported flags print an error and exit with code 1

## Dependencies

| Depends on | Reason |
|---|---|
| — | — |

## Notes

- Parsing all flags here (including `--session` and `--project-root`) even though they are wired up in later features avoids a second pass through the argument parsing code. Unused variables are simply not referenced until needed.
