# Building pi-box Images

## Base image

The base image bundles Node.js LTS and the pi coding agent. All profile images extend it.

### Build

```bash
podman build -t pi-box:base .
```

Run from the repo root. The build pulls `node:22-alpine`, installs the pi coding agent globally, and tags the result as `pi-box:base`.

### Verify

```bash
podman run --rm -it pi-box:base pi --version
```

A pi version string confirms the agent is installed and reachable.

## Profile images

Profile `container.yml` files extend the base image:

```dockerfile
FROM pi-box:base

# Add any profile-specific tooling below
RUN apk add --no-cache git
```

Build a profile image with:

```bash
podman build -t pi-box-<profile>:latest -f ~/.pi-box/<profile>/container.yml ~/.pi-box/<profile>/
```

In practice, `pi-box run <profile>` handles this automatically.
