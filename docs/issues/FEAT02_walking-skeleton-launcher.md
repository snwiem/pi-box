# [FEAT-02] Walking-skeleton `pi-box run` launcher

**Type:** Feature
**ID:** FEAT-02
**Status:** Open
**Parent Epic:** EPIC-02 — Core Launcher
**PRD Reference:** FR-03

---

## Summary

Implement the minimal `pi-box run <profile>` script that parses arguments, builds the profile image when needed, and starts an interactive containerised pi session. This is the walking skeleton of the launcher — no volume mounting or session persistence yet; just: parse args → build image → run container.

## User Story

> As a **developer**, I want a single command to launch a scoped pi session so that I don't have to manually manage container lifecycle.

## Scope

### Layers touched
- [ ] Container / image definition
- [x] Launcher / scripting
- [ ] Configuration / settings
- [ ] Session / runtime behaviour
- [x] Documentation

### In Scope
- The `pi-box` script with `run` subcommand dispatch
- Argument parsing: `<profile>` (positional, required), `--force-rebuild`
- Profile image existence check and conditional build from `container.yml`
- Falling back to `pi-box:base` if no `container.yml` is present in the profile directory
- Interactive `podman run` invocation (no `-v` flags yet — added in FEAT-03)
- Minimal usage/help output

### Out of Scope
- `-v` volume pass-through (FEAT-03)
- Pi config file mounting (FEAT-04)
- Session persistence and `--session` flag (EPIC-03)
- `--project-root` flag (FEAT-05)

## Acceptance Criteria

- [x] `pi-box run <profile>` starts an interactive pi session in the profile image
- [x] If the profile image does not exist locally, it is built automatically before starting
- [x] If the profile image exists and `container.yml` is unchanged, no rebuild occurs
- [x] `--force-rebuild` forces a fresh image build regardless of cache state
- [x] Profile directory without a `container.yml` uses `pi-box:base` directly (no build step)
- [x] Script requires only `bash` and `podman` — no other host dependencies
- [x] Script is executable (`chmod +x`) and runnable as `./pi-box run <profile>` without installation
- [x] Missing or invalid `<profile>` argument prints usage and exits non-zero

## Tasks

| ID | Title | Estimate |
|---|---|---|
| TASK-02-01 | Argument parsing | S |
| TASK-02-02 | Profile image build step | S |
| TASK-02-03 | Container run invocation | S |

## Dependencies

| Depends on | Reason |
|---|---|
| FEAT-01 | Base image (`pi-box:base`) must exist before the build step can reference it |

## Notes

- OQ-01: implement as a single `pi-box` script with a `case` statement for subcommand dispatch. The `run` subcommand is the first branch; `list-sessions` (FEAT-06) is added later.
- Staleness detection for the profile image: a pragmatic approach is to store a checksum of `container.yml` in an image label (`--label pi-box.container-yml-sha=<sha>`) at build time and compare on subsequent runs. Alternatively, track a `.pi-box-build-marker` file in the profile directory.
- Image naming convention: `pi-box-<profile>:latest`
