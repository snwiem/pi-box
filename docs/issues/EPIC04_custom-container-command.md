# [EPIC-04] Custom Container Command

**Type:** Epic
**ID:** EPIC-04
**Status:** Open
**PRD Reference:** PRD-001 — Custom Container Command

---

## Summary

Extends the `pi-box run` launcher to accept an optional command override via the `--` separator. When provided, all tokens after `--` replace the default `pi` entrypoint and are passed verbatim to the container runtime. The full pi-box environment (session persistence, profile mounts, pi config) is always applied regardless of the command used.

## Goal

Allow developers to drop into a shell or run arbitrary container-level commands against the fully configured pi-box environment without leaving the `pi-box run` workflow.

## Scope

### In Scope
- `--` separator parsing in the launcher script
- Verbatim passthrough of all tokens after `--` to the container runtime
- Always allocate a TTY for custom command containers
- Full pi-box environment applied regardless of the command used

### Out of Scope
- `--no-tty` flag (deferred to v2 per PRD-001)
- Dedicated subcommands / aliases (e.g. `pi-box shell`)
- Validation or sanitisation of the supplied command tokens

## Child Issues

| ID | Title | Status |
|---|---|---|
| FEAT-07 | `--` command override and TTY allocation | Open |

## Acceptance Criteria

- [ ] All child Features are completed and accepted
- [ ] `pi-box run <profile>` (no `--`) continues to start `pi` unchanged
- [ ] `pi-box run <profile> -- bash` drops the user into an interactive bash shell with the full pi-box environment intact

## Dependencies

| Depends on | Reason |
|---|---|
| EPIC-02 | Core launcher must exist before it can be extended |

## Notes

- TTY behaviour: v1 always allocates a TTY for custom commands. V2 will add `--no-tty` as an explicit opt-out (inverse of `--interactive` — TTY is on by default).
- Environment consistency: session persistence, profile mounts, and `settings.json` injection must be applied identically to custom command containers and normal `pi` launches.
- See PRD-001 OQ-01 and OQ-02 for open questions around `--no-tty` scope and empty `--` handling.
