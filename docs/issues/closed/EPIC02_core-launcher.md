# [EPIC-02] Core Launcher

**Type:** Epic
**ID:** EPIC-02
**Status:** Done
**PRD Reference:** FR-02, FR-03, FR-04

---

## Summary

Covers the `pi-box run <profile>` launcher script — from argument parsing and profile image building through container execution, `-v` volume pass-through, and pi config file injection from the profile directory. By the end of this Epic a developer can run a fully scoped pi session against any project by pointing pi-box at a profile.

## Goal

A developer can type `pi-box run <profile> -v <project>:/workspace` from any directory and get a running, correctly configured pi session in the expected container image, with no manual container management required.

## Scope

### In Scope
- The `pi-box` shell script and its `run` subcommand
- Profile image build logic (check → build from `container.yml` → fall back to base image)
- `-v` flag pass-through to `podman run`
- Mounting pi config files (skills, extensions, AGENTS.md, etc.) from the profile directory into the container

### Out of Scope
- Session persistence and naming (covered by EPIC-03)
- `list-sessions` subcommand (covered by EPIC-03)
- `mounts.yml` declarative mounts (deferred to v2 per PRD)
- Any formal installer or `PATH` setup

## Child Issues

| ID | Title | Status |
|---|---|---|
| FEAT-02 | Walking-skeleton `pi-box run` launcher | Done |
| FEAT-03 | Volume mounting via `-v` CLI flags | Open |
| FEAT-04 | Pi config file mounting from profile | Open |

## Acceptance Criteria

- [ ] All child Features are completed and accepted
- [ ] `pi-box run <profile> -v $(pwd):/workspace` starts a scoped pi session end-to-end
- [ ] Script requires only `bash` and `podman` — no additional host dependencies
- [ ] Profile directory without a `container.yml` falls back cleanly to `pi-box:base`

## Dependencies

| Depends on | Reason |
|---|---|
| EPIC-01 | Base image must exist before the launcher can build or run profile images |

## Notes

- OQ-01 (monolithic vs composable): implement as a single `pi-box` script with subcommand dispatch (`run`, `list-sessions`). This keeps the v1 footprint minimal while allowing new subcommands to be added without restructuring.
- Script should be located at `bin/pi-box` or the repo root, executable, and runnable via `./pi-box run …` without any install step.
