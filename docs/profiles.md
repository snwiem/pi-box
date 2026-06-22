# Profile Directory Layout

A **profile** is a directory that configures a pi-box container session. The recommended location is `~/.pi-box/<profile-name>/`, but any directory path is accepted as long as it contains the right structure.

---

## Directory Structure

```
~/.pi-box/my-profile/
├── container.yml         # (optional) OCI image definition extending pi-box:base
├── AGENTS.md             # (optional) Global pi context file (loaded for every working directory)
├── APPEND_SYSTEM.md      # (optional) Text appended to the default pi system prompt
├── skills/               # (optional) pi skills directory
├── extensions/           # (optional) pi extensions (TypeScript)
├── prompts/              # (optional) pi prompt templates
└── themes/               # (optional) pi TUI themes
```

All config entries are **optional**. A profile directory that contains nothing but a `container.yml` (or even nothing at all) is valid — pi uses its own built-in defaults for any missing config.

---

## Config File Mapping

At container start, pi-box detects which optional config paths exist in the profile directory and mounts each one **read-only** (`:ro`) into the container at the corresponding pi config location.

| Profile path | Container path | Notes |
|---|---|---|
| `skills/` | `/root/.pi/agent/skills/` | Loaded via `/skill:name` or auto-discovery |
| `extensions/` | `/root/.pi/agent/extensions/` | TypeScript extensions |
| `prompts/` | `/root/.pi/agent/prompts/` | Accessed via `/prompt-name` |
| `themes/` | `/root/.pi/agent/themes/` | TUI colour themes |
| `AGENTS.md` | `/root/.pi/agent/AGENTS.md` | Global context file — loaded for every working directory |
| `APPEND_SYSTEM.md` | `/root/.pi/agent/APPEND_SYSTEM.md` | Appended to the default system prompt without replacing it |

> **Why read-only?** The profile is a shared, version-controlled artifact. Mounting it read-only ensures that nothing running inside the container can modify the profile.

> **Why `/root/.pi/agent/`?** The base image (`pi-box:base`) is built on `node:22-alpine` with no custom `USER`. The default container user is therefore `root`, and pi resolves its config directory as `~/.pi/agent/` → `/root/.pi/agent/`.

---

## Absent Configs

If a config path is **not present** in the profile directory, pi-box does not mount it, and pi falls back to its own built-in defaults for that config type. There are no errors or warnings for missing optional paths.

---

## `container.yml`

If the profile directory contains a `container.yml`, pi-box builds a profile-specific image from it before launching the container. This file is a standard `Containerfile`/`Dockerfile` that must `FROM pi-box:base` (or a derived image).

```dockerfile
# ~/.pi-box/my-profile/container.yml
FROM pi-box:base

# install extra tools your project needs
RUN apk add --no-cache git curl jq
```

If `container.yml` is absent, pi-box uses `pi-box:base` directly.

---

## Project `.gitignore` Guidance

Session data (written by FEAT-05) lands in `<project-root>/.pi-box/`. This must **never** be committed:

```gitignore
# .gitignore
.pi-box/
```
