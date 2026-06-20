# [FEAT-01] Minimal pi base image

**Type:** Feature
**ID:** FEAT-01
**Status:** Open
**Parent Epic:** EPIC-01 — Base Container Image
**PRD Reference:** FR-01

---

## Summary

Author a `Containerfile` that produces a minimal OCI image containing Node.js LTS and the pi coding agent installed via npm. This image is tagged `pi-box:base` and is the single foundation all profile images extend. No project-specific tooling is included.

## User Story

> As a **developer**, I want a ready-made base image so that I don't have to configure a container from scratch.

## Scope

### Layers touched
- [x] Container / image definition
- [ ] Launcher / scripting
- [ ] Configuration / settings
- [ ] Session / runtime behaviour
- [x] Documentation

### In Scope
- `Containerfile` at the repo root (or `build/Containerfile`)
- Installing pi via `npm install -g @earendil-works/pi-coding-agent` (or the correct package name)
- Tagging the image as `pi-box:base`
- A brief `README` section or `docs/building.md` entry explaining how to build the base image

### Out of Scope
- Profile-specific tooling or config
- Pushing to any public or private registry
- Multi-architecture builds

## Acceptance Criteria

- [x] `podman build -t pi-box:base .` (or documented equivalent) completes without error
- [x] `podman run --rm -it pi-box:base pi --version` prints a pi version string
- [x] Image is based on `node:lts-alpine` (or equivalent minimal, well-known base)
- [x] Image contains only the minimum runtime — no editors, compilers, or project-specific tools
- [x] Build instructions are documented (README or dedicated doc)

## Tasks

| ID | Title | Estimate |
|---|---|---|
| — | No sub-tasks — this Feature is a single focused authoring step | — |

## Dependencies

| Depends on | Reason |
|---|---|
| — | — |

## Notes

- Confirm the exact npm package name for the pi coding agent before writing the Containerfile.
- OQ-04: tag as `pi-box:base` for v1. Profile `container.yml` files should reference `FROM pi-box:base` — pinning to a digest can be added in v2.
- Keep the image layer count low; combine `RUN` steps where sensible.
