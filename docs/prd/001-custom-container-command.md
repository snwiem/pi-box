# Product Requirements Document
**Project:** pi-box — Custom Container Command
**Date:** 2026-06-22
**Status:** Draft

---

## 1. Executive Summary

Pi-box currently always starts the `pi` coding agent as the container entrypoint. This PRD introduces the ability to override that command at launch time, allowing users to run arbitrary container-specific commands (e.g. drop into a shell, run a diagnostic script) while preserving the full pi-box environment. The default `pi` command is unchanged; the override is opt-in and follows standard UNIX CLI conventions.

---

## 2. Problem Statement

When debugging a pi-box container, inspecting the container environment, or running a one-off command against the pi-box setup, users currently have no way to specify what command runs inside the container. They are forced to always start the full `pi` agent — even when they just want a quick shell or need to run a container-level script. This makes operational and diagnostic workflows unnecessarily cumbersome.

---

## 3. Goals & Success Criteria

### Goals
- Allow users to override the default `pi` command with any arbitrary command when launching a pi-box container
- Keep the full pi-box environment (session persistence, mounts, profile config) intact regardless of the command used
- Follow UNIX CLI conventions so the feature feels natural to terminal-native users

### Success Criteria (v1 Definition of Done)
> A developer can run `pi-box run <profile> -- bash` and land in a fully configured pi-box shell session in a single command.

---

## 4. Target Users

### Primary Users
- **Solo developer** — the same primary user as defined in PRD-000; needs shell access or one-off command execution for debugging and inspection of the containerised pi environment

### Secondary Users / Stakeholders
- Future team users who may run diagnostic or provisioning commands against a shared profile image

---

## 5. Scope

### In Scope (v1)
- `--` separator syntax to pass a custom command (+ arguments) to `pi-box run`
- Verbatim passthrough of all tokens after `--` to the container runtime
- TTY always allocated for custom commands
- Full pi-box environment (session persistence, profile mounts, pi config) always applied regardless of the command used
- Default command remains `pi` when no `--` override is present

### Out of Scope (v1)
- `--no-tty` flag to suppress TTY allocation (deferred to v2)
- Validation of the supplied command beyond what the container runtime itself provides
- Dedicated subcommands or aliases (e.g. `pi-box shell`) as syntactic sugar

### Future Considerations (v2+)
- `--no-tty` flag: opt-out of TTY allocation for non-interactive / scripted use-cases. This is the inverse of a `--interactive` flag — TTY is on by default and `--no-tty` explicitly disables it. Recommended flag name: `--no-tty` (maps directly to `podman run --tty` semantics and is familiar to container CLI users)

---

## 6. Functional Requirements

### FR-01: Command Override via `--` Separator
- **Description:** When the user appends `--` followed by a command (and optional arguments) to `pi-box run`, that command replaces the default `pi` entrypoint inside the container. Without `--`, behaviour is unchanged.
- **User Story:** As a developer, I want to run `pi-box run <profile> -- bash` so that I can inspect the container environment interactively without changing the default `pi` launch behaviour.
- **Acceptance Criteria:**
  - [ ] `pi-box run <profile>` (no `--`) starts `pi` as normal — no change to existing behaviour
  - [ ] `pi-box run <profile> -- <cmd>` starts `<cmd>` inside the container instead of `pi`
  - [ ] `pi-box run <profile> -- <cmd> [args...]` passes all tokens after `--` verbatim to the container runtime with no parsing or transformation by pi-box
  - [ ] An empty `--` (no tokens following it) is treated as if `--` was not provided (fall back to `pi`)

### FR-02: TTY Allocation for Custom Commands
- **Description:** When a custom command is provided via `--`, the container is always started with a TTY and interactive stdin allocated (equivalent to `podman run -it`).
- **User Story:** As a developer, I want shell commands like `bash` to work interactively out of the box so that I don't have to know or remember container TTY flags.
- **Acceptance Criteria:**
  - [ ] Custom command containers are started with both `-t` (TTY) and `-i` (interactive stdin)
  - [ ] The session does not hang or exit immediately for interactive commands such as `bash` or `sh`

### FR-03: Full Pi-box Environment Always Applied
- **Description:** Session persistence, profile mounts, and pi configuration are applied to the container regardless of whether the default `pi` command or a custom command is used.
- **User Story:** As a developer, I want the pi-box environment to be fully set up even when I drop into a shell, so that I can inspect and interact with session data and profile config as they would appear during a real pi session.
- **Acceptance Criteria:**
  - [ ] Session directory is mounted and created at `<project-dir>/.pi-box/<profile>/sessions/<session-id>/` for custom command containers
  - [ ] All profile mounts (skills, extensions, AGENTS.md, etc.) are applied exactly as they are for normal `pi` launches
  - [ ] Pi's `settings.json` is injected into the container environment for custom command containers
  - [ ] `-v` CLI mount flags are honoured in the same way as for normal launches

---

## 7. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Usability** | The `--` syntax must be documented in `--help` output |
| **Compatibility** | Verbatim passthrough must not break for commands with their own flags (e.g. `-- sh -c "echo hello"`) |
| **Consistency** | Custom command launch must be indistinguishable from a normal launch in terms of environment setup — only the process started differs |
| **Safety** | Pi-box must not attempt to interpret or sanitise the command tokens after `--`; responsibility is delegated to the container runtime and the user |

---

## 8. Technical Context

### Platform & Deployment
- Same as PRD-000: *nix-based hosts, rootless Podman, bash launcher script

### Implementation Notes
- The `--` handling should be implemented in the launcher script by scanning `$@` for the first `--` token and splitting the argument list at that point
- Tokens before `--` are pi-box launcher flags; tokens after `--` form the container command array
- The container runtime call changes from `podman run ... pi` to `podman run -it ... "${CMD[@]}"` where `CMD` is the parsed token array
- When no `--` is present, `CMD` defaults to `("pi")`
- TTY/interactive flags (`-it`) should only be applied to the container invocation when a custom command is provided; normal `pi` launches retain their existing TTY behaviour

### External Dependencies
- No new external dependencies; this is a launcher script change only

---

## 9. Constraints

| Constraint | Detail |
|---|---|
| **Team** | Solo developer |
| **Timeline** | No hard deadline; implement as part of the normal feature backlog |
| **Scope discipline** | No dedicated subcommands or aliases in v1 — the `--` separator is the only surface |

---

## 10. Open Questions

| # | Question | Impact |
|---|---|---|
| OQ-01 | Should `--no-tty` (v2) apply to the default `pi` command as well, or only to custom commands? | Affects whether TTY behaviour becomes globally configurable or command-override-specific |
| OQ-02 | Should an empty `--` (nothing after the separator) produce a warning, or silently fall back to `pi`? | Minor UX decision; lean toward a warning to surface likely user mistakes |

---

## 11. Appendix

### Refinement Session Summary
Key decisions made during the discovery interview:

- **CLI syntax:** `--` separator (UNIX-idiomatic, no clash with future pi-box flags)
- **Passthrough:** Full verbatim passthrough of all tokens after `--` — no pi-box interpretation
- **TTY (v1):** Always allocate TTY for custom commands; simple and predictable
- **TTY (v2+):** Add `--no-tty` flag as an explicit opt-out for non-interactive/scripted use; this is the *inverse* of `--interactive` — TTY is the default, not the exception
- **Environment:** Full pi-box environment always applied — pi-box is a pi hosting tool first; custom commands are a secondary access mode, not a generic container runner
- **Default unchanged:** `pi-box run <profile>` with no `--` continues to work exactly as specified in PRD-000

### References
- [PRD-000: pi-box basic project requirements](./000-basic-project-requirements.md)
- [Podman run reference — `-it` flags](https://docs.podman.io/en/latest/markdown/podman-run.1.html)
