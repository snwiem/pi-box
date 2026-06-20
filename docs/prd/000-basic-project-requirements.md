# Product Requirements Document
**Project:** pi-box
**Date:** 2026-06-20
**Status:** Draft v1

---

## 1. Executive Summary

pi-box is an opinionated container launcher for the [pi coding agent](https://pi.dev), designed to run pi inside a controlled, reproducible OCI container environment. It solves the problem of pi being a powerful but unconstrained tool by scoping each pi instance to exactly the filesystem access, skills, extensions, and context it needs — defined by a reusable, version-controllable **profile**. The first version targets a single developer wanting isolated, reproducible pi environments for different projects, with a clean path toward company-wide rollout later.

---

## 2. Problem Statement

The pi coding agent is powerful and highly customisable — but that power comes with risk: an unconstrained pi instance has access to the entire host filesystem and can load any globally installed extensions or skills. In practice, developers working on multiple projects need different pi setups per project, and there is currently no mechanism to isolate pi's environment, scope its permissions, or ensure a reproducible configuration across sessions or machines.

Additionally, pi's global customisation layer (extensions, skills, prompt templates, themes) tends to accumulate over time, making the agent less predictable and harder to reason about for any specific task.

Pi-box addresses this by packaging pi inside an OCI container, launched with a per-project **profile** that defines exactly what goes into that pi instance — and nothing more.

---

## 3. Goals & Success Criteria

### Goals
- Provide a simple, scriptable way to launch a scoped, containerised pi session
- Make pi instances reproducible via version-controllable profile directories
- Ensure pi session state survives container restarts (no lost context)
- Keep the solution clean and focused on a single-developer workflow first

### Success Criteria (v1 Definition of Done)
> A developer can clone the pi-box repository, build the base image, create a minimal profile, and run a fully scoped pi session against a project **in under 15 minutes**.

### Non-Goals for v1
- Multi-user or team-facing UX polish
- Public image distribution or CI/CD pipelines
- Any formal installation/packaging

---

## 4. Target Users

### Primary Users (v1)
- **Solo developer** — runs pi-box for personal projects; wants isolated, reproducible pi environments without manually managing global pi config; comfortable with the terminal and basic container concepts

### Secondary Users (future)
- **Team lead / DevOps engineer** — packages and distributes profiles to their development team; needs the profile directory to be clean, shareable, and VCS-managed

---

## 5. Scope

### In Scope (v1)
- OCI-compatible base container image containing the minimum runtime to run pi (Node, npm, pi itself)
- `pi-box run <profile>` launcher script (shell-based, no installation required)
- Profile loading: `container.yml` (image definition) + pi config files (skills, extensions, AGENTS.md, themes, prompts)
- Volume mounting via `-v` CLI flags (passed through to the container runtime)
- Automatic session persistence, stored project-locally at `<project>/.pi-box/<profile>/sessions/<uuid|session-name>/`
- Named sessions via `--session <name>`, falling back to auto-generated UUID
- Support for running multiple parallel pi-box instances against the same project (session-isolated by name/uuid)
- Rootless Podman as the container runtime

### Optional (v1 — implement if straightforward, not blocking)
- `mounts.yml` per profile for declarative default volume mounts
- `~/.pi-box/<profile>` as the standard profile directory convention

### Out of Scope (v1)
- Pushing/pulling pi-box base image from a public container registry (e.g. Docker Hub, ghcr.io)
- Formal install phase or system-level packaging (brew, apt, etc.)
- Container-in-container support (pi-box container accessing host container runtime)
- Multi-user / team distribution tooling

### Future Considerations (v2+)
- `mounts.yml` (if not included in v1)
- Profile repository convention (`~/.pi-box/<profile>`) with git-based profile management
- Public base image registry distribution
- Formal installer / onboarding script
- Company-wide rollout tooling and documentation

---

## 6. Functional Requirements

### FR-01: Base Container Image
- **Description:** A minimal OCI-compatible container image with everything needed to run pi (Node.js, npm, pi coding agent). No project-specific tooling — kept as lean as possible.
- **User Story:** As a developer, I want a ready-made base image so that I don't have to configure a container from scratch.
- **Acceptance Criteria:**
  - [ ] Image builds successfully with `podman build`
  - [ ] Pi agent starts inside the container
  - [ ] Image contains only the minimum runtime (no unnecessary tools)
  - [ ] Image is based on a well-known, minimal base (e.g. `node:lts-alpine`)

### FR-02: Profile Loading
- **Description:** On launch, pi-box reads the specified profile directory and mounts/applies its contents into the container as the pi configuration layer. A profile contains a `container.yml` and any pi config files (skills, extensions, AGENTS.md, themes, prompts).
- **User Story:** As a developer, I want to define a profile directory so that pi starts with exactly the skills, extensions, and context that project needs.
- **Acceptance Criteria:**
  - [ ] `container.yml` in the profile directory defines the container image (extending the base image)
  - [ ] Pi config files (skills/, extensions/, AGENTS.md, APPEND_SYSTEM.md, prompts/, themes/) from the profile are applied to the pi instance inside the container
  - [ ] Missing optional config files in the profile fall back to pi's own defaults
  - [ ] Profile directory without a `container.yml` falls back to the pi-box base image

### FR-03: Launcher Script
- **Description:** A single shell script (`pi-box run`) that builds the profile image (if needed) and starts the containerised pi session with the correct configuration.
- **User Story:** As a developer, I want a single command to launch a scoped pi session so that I don't have to manually manage container lifecycle.
- **Acceptance Criteria:**
  - [ ] `pi-box run <profile>` starts a pi session using the specified profile
  - [ ] If the profile image doesn't exist locally, it is built automatically before starting
  - [ ] If the profile image already exists and `container.yml` hasn't changed, no rebuild occurs
  - [ ] `--force-rebuild` flag forces a fresh image build
  - [ ] Script requires only tools commonly available on *nix systems (bash, podman)

### FR-04: Volume Mounting via CLI
- **Description:** Users pass `-v` flags to `pi-box run` to mount host directories into the container, identical in semantics to `podman run -v`.
- **User Story:** As a developer, I want to mount my project directory into pi-box so that pi can read and modify my code.
- **Acceptance Criteria:**
  - [ ] `-v <host-path>:<container-path>` flags are accepted and passed through to the container runtime
  - [ ] Read-only mounts (`:ro`) are supported
  - [ ] Multiple `-v` flags can be specified in a single command
  - [ ] No mounts are injected automatically beyond those required for session persistence (FR-05)

### FR-05: Automatic Session Persistence
- **Description:** Pi session data is automatically persisted to a project-local directory on the host, surviving container stop and restart without any manual user action.
- **User Story:** As a developer, I want pi's session context to survive container restarts so that I don't lose my working context between sessions.
- **Acceptance Criteria:**
  - [ ] Session data is stored at `<project-dir>/.pi-box/<profile>/sessions/<uuid|session-name>/` on the host
  - [ ] The session directory is automatically created on first launch if it doesn't exist
  - [ ] Pi is configured to use this directory as its session storage (via pi `settings.json`)
  - [ ] Stopping and restarting the container with the same session resumes correctly
  - [ ] `.pi-box/` directory should be added to `.gitignore` recommendations (session data must never be committed)

### FR-06: Named & Parallel Sessions
- **Description:** Users can name a session explicitly for easy resumption; unnamed sessions get a UUID. Multiple instances can run concurrently against the same project without session collision.
- **User Story:** As a developer, I want to run multiple pi-box instances in parallel on the same project so that I can work on independent tasks simultaneously without interference.
- **Acceptance Criteria:**
  - [ ] `--session <name>` flag assigns a human-readable name to the session
  - [ ] Without `--session`, a UUID is generated and used as the session identifier
  - [ ] Each session gets its own isolated directory under `<project-dir>/.pi-box/<profile>/sessions/`
  - [ ] Multiple parallel pi-box instances on the same project do not share or corrupt each other's session data
  - [ ] `pi-box list-sessions <profile>` (or equivalent) shows existing sessions for a profile in the current project

---

## 7. Non-Functional Requirements

| Category | Requirement |
|---|---|
| **Simplicity** | A developer with basic terminal knowledge can complete the getting-started workflow in under 15 minutes |
| **Portability** | Launcher requires only bash and podman — no additional runtime dependencies on the host |
| **Compatibility** | Works on any *nix-based system; Windows support via Git Bash, Cygwin, or msys2 is a secondary target |
| **Container runtime** | Rootless Podman (OCI-compatible); no root privileges required on the host |
| **Security** | Each pi instance is scoped to explicitly mounted directories only; no implicit host filesystem access |
| **VCS safety** | Profile directories must be clean for VCS commit (no session data, no secrets written into profiles) |
| **Performance** | Container startup overhead should be minimal; image rebuilds only occur when `container.yml` changes |

---

## 8. Technical Context

### Platform & Deployment
- Host: *nix-based systems (Linux primary, macOS secondary, Windows/Git Bash tertiary)
- Container runtime: Rootless Podman (OCI-compatible)
- Distribution: Git clone of the pi-box repository; no package manager installation required for v1

### Tech Stack
- Base image: minimal Node.js image (e.g. `node:lts-alpine`) + pi coding agent installed via npm
- Launcher: bash shell script
- Profile image definition: `container.yml` (Containerfile/Dockerfile syntax, extending pi-box base)
- Session config: pi `settings.json` inside the container, pointing session storage to the mounted host path

### Key Conventions
```
# Profile location (optional convention, not enforced in v1)
~/.pi-box/<profile-name>/
  container.yml           # OCI image definition (extends pi-box base)
  skills/                 # Pi skills
  extensions/             # Pi extensions
  AGENTS.md               # Pi context file
  APPEND_SYSTEM.md        # Pi system context override
  prompts/                # Pi prompt templates
  themes/                 # Pi themes

# Session data location (project-local, never committed)
<project-dir>/.pi-box/<profile-name>/sessions/<uuid|session-name>/
```

### External Dependencies
- [pi coding agent](https://pi.dev) — the agent being containerised
- Podman — container runtime on the host
- No other external services or APIs required for v1

---

## 9. Constraints

| Constraint | Detail |
|---|---|
| **Team** | Solo developer project |
| **Timeline** | No hard deadline; focus on fast iteration — v1 is a walking skeleton, not a throwaway PoC |
| **Scope discipline** | Keep it simple and single-developer focused; no over-engineering for the team/enterprise use case in v1 |
| **Runtime dependency** | Podman must be available on the host; no alternative container runtimes supported in v1 |

---

## 10. Open Questions

| # | Question | Impact |
|---|---|---|
| OQ-01 | Should `pi-box run` be a single monolithic script or a small collection of composable scripts (build, run, session)? | Affects extensibility and testability of the launcher |
| OQ-02 | Should `<project-dir>` be inferred automatically from `-v` mount flags or explicitly passed as a separate argument? | Affects session path resolution when multiple mounts are provided |
| OQ-03 | What is the exact pi `settings.json` configuration needed to redirect session storage to a custom path? | Needs validation against pi documentation before implementation |
| OQ-04 | Should the pi-box base image be versioned/tagged, and how does profile `container.yml` pin to a specific base image version? | Affects reproducibility of profile images over time |
| OQ-05 | Should `mounts.yml` (optional v1 feature) be pursued in v1 or deferred? | Depends on how complex the launcher script becomes with CLI-only mounts |

---

## 11. Appendix

### Refinement Session Summary
Key decisions made during the discovery interview:
- **Target users:** Solo developer (v1) → team/company rollout (future)
- **V1 scope anchor:** Base image + `pi-box run <profile>` launcher + `-v` CLI mounts + profile loading + session persistence
- **Session storage:** Project-local (`<project>/.pi-box/<profile>/sessions/`), never inside the profile directory (profile must stay VCS-clean)
- **Session naming:** Explicit `--session <name>` with UUID fallback
- **Parallelism:** Multiple concurrent instances on the same project are fully supported via isolated session directories
- **Out of scope (hard):** Public registry, formal installer, container-in-container
- **Optional v1:** `mounts.yml`, `~/.pi-box/<profile>` directory convention
- **Definition of done:** Zero-to-working pi session in under 15 minutes from a fresh clone
- **Implementation philosophy:** Walking skeleton — clean, kept, and continued; not a throwaway PoC

### References
- [pi coding agent](https://pi.dev)
- [pi session settings](https://pi.dev/docs/latest/settings#sessions)
- [pi context files](https://pi.dev/docs/latest/usage#context-files)
- [pi extensions](https://pi.dev/docs/latest/extensions)
- [pi skills](https://pi.dev/docs/latest/skills)
- [pi prompt templates](https://pi.dev/docs/latest/prompt-templates)
