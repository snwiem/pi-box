# AGENTS.md — pi-box

> Agent context for pi coding agent. Read this file at the start of every session before doing any work.

## Project Overview

**pi-box** is an opinionated container harness for [pi coding agent](https://pi.dev). It lets users run pi inside a controlled, profile-scoped container (rootless Podman), mounting only the directories the agent needs and loading only the extensions, skills, and configuration relevant to the current task. See `README.md` for the full motivation and feature description.

---

## Repository Layout

```
pi-box/
├── README.md               # High-level project description & motivation
├── AGENTS.md               # ← you are here
├── docs/
│   ├── prd/                # Product Requirement Documents (append-only, never delete)
│   │   └── 000-*.md        # PRDs are numbered; they document requirements at a point in time
│   ├── issues/             # Open backlog: EPICs, FEATures, TASKs
│   │   └── closed/         # Closed/done issues moved here (not deleted)
│   └── adr/                # Architecture Decision Records
│       └── NNN_<topic>.md  # 3-digit zero-padded number + topic slug (e.g. 001_container-runtime.md)
```

### Key doc conventions

| Directory | Purpose | Lifecycle |
|---|---|---|
| `docs/prd/` | Requirements at a point in time | **Never deleted** — append-only history |
| `docs/issues/` | Open backlog items | Moved to `docs/issues/closed/` when done |
| `docs/adr/` | Architecture Decision Records | Numbered `NNN_<topic>.md`; never deleted |

---

## Skills Available

Two skills are wired into this project. Load the relevant skill file before performing the matching task.

| Skill | Trigger | Path |
|---|---|---|
| `/refine` | Refining a vague PRD or issue into a well-defined requirement | `/var/home/snwiem/.pi/agent/skills/refine/SKILL.md` |
| `/slice` | Slicing a PRD or issue into smaller, workable pieces (EPICs → FEATures → TASKs) | `/var/home/snwiem/.pi/agent/skills/slice/SKILL.md` |

---

## Version Control & Branching

This project is managed with **git**. Follow these rules strictly:

- **`main` is the integration branch — never commit directly to it.**
- All work happens in dedicated branches:
  - Bug fixes → `bugfix/<ISSUE_ID>_<short-title>` (e.g. `bugfix/TASK0201_fix-arg-parsing`)
  - Features → `feature/<ISSUE_ID>_<short-title>` (e.g. `feature/FEAT03_volume-v-flags`)
  - If no issue exists, omit the ID prefix but keep the descriptive slug.
- Use **[Conventional Commits](https://www.conventionalcommits.org/)** for all commit messages:
  - `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:` …
  - Add a scope when it adds clarity: `feat(launcher): add --profile flag`
- **Commit early and often** — don't batch unrelated changes into a single commit.
- When merging a branch into `main`, always use a **squash merge** to keep history clean.

### Typical workflow

```bash
git checkout main && git pull
git checkout -b feature/FEATXX_my-feature
# ... make changes, commit frequently ...
git commit -m "feat(scope): short description"
# ... when ready to integrate ...
git checkout main
git merge --squash feature/FEATXX_my-feature
git commit -m "feat(scope): squash-merge FEATXX — short description"
```

---

## Issue Naming Conventions

| Prefix | Meaning | Example filename |
|---|---|---|
| `EPIC` | Large theme of work | `EPIC01_base-container-image.md` |
| `FEAT` | User-facing feature | `FEAT01_minimal-pi-base-image.md` |
| `TASK` | Concrete implementation task (child of EPIC/FEAT) | `TASK0201_argument-parsing.md` |
| `BUG` | Defect report | `BUG001_profile-not-found-crash.md` |
