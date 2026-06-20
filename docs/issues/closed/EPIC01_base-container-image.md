# [EPIC-01] Base Container Image

**Type:** Epic
**ID:** EPIC-01
**Status:** Open
**PRD Reference:** FR-01

---

## Summary

Covers building a minimal OCI-compatible container image with Node.js LTS and the pi coding agent pre-installed. This image is the single foundation that every profile image extends — it must be kept as lean as possible and never carry project-specific tooling.

## Goal

Produce a stable, reproducible `pi-box:base` image that any profile `container.yml` can reference, so developers never have to configure a container from scratch.

## Scope

### In Scope
- Containerfile authoring for the base image
- Base image tagging convention (`pi-box:base`)
- Verification that pi starts inside the container

### Out of Scope
- Pushing the image to a public registry (out of scope for v1 per PRD)
- Any project-specific tooling or profile content
- Formal versioning / multi-tag strategy (can be addressed in v2)

## Child Issues

| ID | Title | Status |
|---|---|---|
| FEAT-01 | Minimal pi base image | Open |

## Acceptance Criteria

- [ ] All child Features are completed and accepted
- [ ] `podman build` succeeds from a clean clone with no pre-existing images
- [ ] Pi agent starts and is interactive inside the built container

## Dependencies

| Depends on | Reason |
|---|---|
| — | — |

## Notes

- OQ-04 (image versioning): for v1 a single `pi-box:base` tag is sufficient. A `pi-box:base-<semver>` convention can be introduced in v2 alongside public registry distribution.
- Base image choice: `node:lts-alpine` is recommended for minimal footprint.
