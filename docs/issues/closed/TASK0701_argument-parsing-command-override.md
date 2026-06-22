# [TASK-07-01] Extend argument parsing for `--` separator

**Type:** Task
**ID:** TASK-07-01
**Status:** Closed
**Parent Feature:** FEAT-07 — `--` command override and TTY allocation

---

## Summary

Extend the argument parsing block in the `pi-box run` subcommand to detect a `--` separator, split the argument list at that point, and capture all tokens after `--` into a `CMD` array.

## Implementation Notes

- Scan `$@` for the first `--` token **before** the main flag parsing loop so that flags intended for the inner command are never consumed by pi-box's own `case` statement
- Split strategy (bash):
  ```bash
  CMD=()
  RAW_ARGS=("$@")
  for i in "${!RAW_ARGS[@]}"; do
    if [[ "${RAW_ARGS[$i]}" == "--" ]]; then
      CMD=("${RAW_ARGS[@]:$((i+1))}")
      set -- "${RAW_ARGS[@]:0:$i}"
      break
    fi
  done
  ```
- After the split, `$@` contains only the pi-box flags; `CMD` contains the user-supplied command tokens
- If no `--` is found, `CMD` remains empty — the run invocation step (TASK-07-02) treats an empty `CMD` as `("pi")`
- If `--` is found but `CMD` is empty (nothing after the separator), print a warning to stderr and leave `CMD` empty so it falls back to `pi`:
  ```bash
  [[ ${#CMD[@]} -eq 0 ]] && echo "pi-box: warning: '--' provided with no command; defaulting to 'pi'" >&2
  ```
- Update `--help` output to document the `--` syntax, e.g.:
  ```
  Usage: pi-box run <profile> [OPTIONS] [-- COMMAND [ARGS...]]

    -- COMMAND [ARGS...]   Override the default 'pi' command. All tokens after
                           '--' are passed verbatim to the container.
  ```

## Acceptance Criteria

- [ ] `--` is detected and the argument list is correctly split before pi-box flag parsing runs
- [ ] All tokens after `--` are captured verbatim in `CMD` (including inner flags like `--version`)
- [ ] Pi-box flags before `--` are parsed normally and are unaffected by the split
- [ ] Empty `--` prints a warning to stderr and leaves `CMD` empty
- [ ] `--help` output includes documentation for the `--` syntax

## Dependencies

| Depends on | Reason |
|---|---|
| — | — |

## Notes

- Perform the `--` scan as the very first step in argument processing to avoid any interaction with the existing `case`-based flag parser.
