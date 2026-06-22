# pi-box

> Run [pi coding agent](https://pi.dev) inside a controlled, profile-scoped rootless container — giving pi exactly the filesystem access, extensions, and skills it needs for the job, and nothing more.

## Why pi-box?

pi is powerful and highly customisable. That's also the risk: an unconstrained pi instance has access to your entire filesystem and any globally installed extensions. pi-box fixes this by wrapping pi in a rootless [Podman](https://podman.io) container, launched with a **profile** — a version-controllable directory that defines exactly what that pi instance can see and do.

## Prerequisites

- [Podman](https://podman.io) (rootless) — `podman --version`
- `bash` — available on any *nix system, Git Bash, Cygwin, msys2

## Quick Start

```bash
# 1. Clone pi-box
git clone https://github.com/your-org/pi-box.git
cd pi-box

# 2. Build the base image
./pi-box build

# 3. Run pi with a profile, mounting your project
./pi-box run my-profile -v ~/projects/my-app:/workspace
```

## Profiles

A profile is a directory that configures the pi instance. The recommended location is `~/.pi-box/<profile-name>/`:

```
~/.pi-box/my-profile/
  container.yml         # OCI image definition (extends pi-box base image)
  AGENTS.md             # pi context file (loaded globally, every working directory)
  APPEND_SYSTEM.md      # text appended to the default pi system prompt
  skills/               # pi skills
  extensions/           # pi extensions (TypeScript)
  prompts/              # pi prompt templates
  themes/               # pi TUI themes
```

On first use, pi-box builds a profile image from `container.yml`. Subsequent runs reuse the cached image — a rebuild only happens when `container.yml` changes or `--force-rebuild` is passed. Missing config files fall back to pi's own defaults.

## Sessions

Session data is persisted to a project-local directory so your context survives container restarts:

```
<project-dir>/.pi-box/<profile>/sessions/<session-name>/
```

```bash
# Start or resume a named session
./pi-box run my-profile --session my-task -v ~/projects/my-app:/workspace

# List existing sessions for a profile
./pi-box list-sessions my-profile
```

> ⚠️ Add `.pi-box/` to your project's `.gitignore` — session data must never be committed.

## Documentation

| Path | Contents |
|---|---|
| [`docs/profiles.md`](docs/profiles.md) | Profile directory layout & config file mapping |
| [`docs/sessions.md`](docs/sessions.md) | Session persistence, directory layout & gitignore guidance |
| [`docs/prd/`](docs/prd/) | Product Requirement Documents (append-only history) |
| [`docs/issues/`](docs/issues/) | Open backlog — EPICs, FEATures, TASKs |
| [`docs/adr/`](docs/adr/) | Architecture Decision Records |
| [`AGENTS.md`](AGENTS.md) | Agent context, branching & commit conventions |

## Contributing

1. Read [`AGENTS.md`](AGENTS.md) for branching and commit conventions.
2. Pick an open issue from [`docs/issues/`](docs/issues/).
3. Create a `feature/<ISSUE_ID>_<title>` branch and open a PR against `main`.

## License

TBD
