# [FEAT-07] `--` command override and TTY allocation

**Type:** Feature
**ID:** FEAT-07
**Status:** Closed
**Parent Epic:** EPIC-04 — Custom Container Command
**PRD Reference:** PRD-001 FR-01, FR-02, FR-03

---

## Summary

Extends `pi-box run` to accept an optional command override after a `--` separator. All tokens after `--` are passed verbatim to the container runtime, replacing the default `pi` entrypoint. A TTY is always allocated for custom command containers. The full pi-box environment (session persistence, profile mounts, `settings.json`) is applied unchanged.

## User Story

> As a **developer**, I want to run `pi-box run <profile> -- bash` so that I can inspect the container environment interactively without changing the default `pi` launch behaviour.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [ ] Configuration / settings
- [x] Session / runtime behaviour
- [x] Documentation

### In Scope
- Argument parsing extension: scan `$@` for the first `--` token and split the argument list at that point
- Verbatim passthrough of all tokens after `--` as the container command array
- TTY + interactive stdin (`-it`) always set when a custom command is provided
- Session directory mounted and created as normal for custom command containers
- All profile mounts and `settings.json` injection applied as normal
- `--help` output updated to document the `--` syntax
- Empty `--` (no tokens following) falls back to `pi` (with a warning printed to stderr)

### Out of Scope
- `--no-tty` flag (v2)
- Dedicated `pi-box shell` subcommand
- Any interpretation or sanitisation of tokens after `--`

## Acceptance Criteria

- [ ] `pi-box run <profile>` with no `--` starts `pi` exactly as before — no behaviour change
- [ ] `pi-box run <profile> -- bash` starts an interactive bash shell inside the container
- [ ] `pi-box run <profile> -- sh -c "echo hello"` passes all three tokens verbatim and executes correctly
- [ ] Custom command containers have session directory mounted at `<project-dir>/.pi-box/<profile>/sessions/<session-id>/`
- [ ] All `-v` mount flags and profile mounts are applied to custom command containers
- [ ] `pi-box run <profile> --` (empty separator) prints a warning to stderr and starts `pi` as normal
- [ ] `--help` output documents the `--` syntax

## Tasks

| ID | Title | Estimate |
|---|---|---|
| TASK-07-01 | Extend argument parsing for `--` separator | S |
| TASK-07-02 | Update container run invocation for custom command and TTY | S |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-02 | Walking-skeleton launcher must exist before it can be extended |

## Notes

- The split on `--` should happen before all other flag parsing so that flags intended for the inner command (e.g. `-- node --version`) are not accidentally consumed by pi-box's own parser.
- PRD-001 OQ-02: an empty `--` should warn rather than silently fall back, to surface likely user mistakes.
