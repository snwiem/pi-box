# [TASK-02-02] Profile image build step

**Type:** Task
**ID:** TASK-02-02
**Status:** Open
**Parent Feature:** FEAT-02 — Walking-skeleton `pi-box run` launcher

---

## Summary

Implement the logic that checks whether the profile's container image is up to date and builds (or skips building) it before the container is started.

## Implementation Notes

Decision tree:

1. If no `container.yml` exists in the profile directory → use `pi-box:base` directly; skip build entirely.
2. If `--force-rebuild` is set → always build.
3. If image `pi-box-<profile>:latest` does not exist locally (`podman image exists pi-box-<profile>:latest` exits non-zero) → build.
4. If `container.yml` has changed since last build → build.
5. Otherwise → skip build, use existing image.

**Staleness detection approach (recommended):**
At build time, store a SHA256 of `container.yml` as an image label:
```
podman build \
  --label "pi-box.container-yml-sha=$(sha256sum container.yml | cut -d' ' -f1)" \
  -f container.yml \
  -t pi-box-<profile>:latest \
  <profile-dir>
```
On subsequent runs, retrieve the stored label with `podman inspect` and compare to the current file's SHA. Rebuild if they differ.

**Build context:** the profile directory is the build context so that `container.yml` can `COPY` profile files if needed.

**Fallback `container.yml`:** if the profile directory has no `container.yml`, set `IMAGE=pi-box:base` and proceed directly to the run step.

## Acceptance Criteria

- [ ] Image is built when it does not exist locally
- [ ] Image is NOT rebuilt when `container.yml` is unchanged (SHA matches stored label)
- [ ] `--force-rebuild` always triggers a rebuild, ignoring the staleness check
- [ ] Profile without a `container.yml` runs `pi-box:base` without attempting a build
- [ ] Build failure exits the script with a non-zero code and a clear error message

## Dependencies

| Depends on | Reason |
|---|---|
| TASK-02-01 | `PROFILE`, `FORCE_REBUILD`, and profile directory path must be available from parsing |

## Notes

- `sha256sum` is available on Linux; `shasum -a 256` is the macOS equivalent. Abstract into a small helper function for portability.
- The build context path should be absolute to avoid issues when `pi-box` is invoked from different working directories.
