# Research: Do we have pre-commit hooks in this project?

**Date:** 2026-04-17
**Question:** Does this project have pre-commit hooks configured?
**Type:** Audit / current-state research
**Scope:** Whole repo + worktree configuration

---

## Short answer

**No.** The project has **no pre-commit hooks** — none versioned, none installed locally, and no hook framework configured. The `CLAUDE.md` *Code Quality Enforcement* rules declare an intent ("Code MUST be auto-formatted before commit") but nothing in the repo or git config actually enforces it.

---

## How I verified

Checks performed, in order:

### 1. No local hooks installed in git's hooks directory

This checkout is a **git worktree**. The worktree's `.git` is a pointer file:

```
gitdir: /Users/nadzya/habit/untitled folder/Tracker/.git/worktrees/objective-solomon
```

Worktrees share hooks with the main repo. The shared hooks directory at `/Users/nadzya/habit/untitled folder/Tracker/.git/hooks/` contains only:

```
README.sample   (177 bytes, the default git sample)
```

No executable hook of any kind (`pre-commit`, `commit-msg`, `pre-push`, etc.).

### 2. No custom `core.hooksPath` set

```
git config --get core.hooksPath   →   (empty)
```

Git is using the default `.git/hooks/` path (which, per §1, is empty).

### 3. No versioned hook directories at the repo root

- `.githooks/` — missing
- `hooks/` — missing
- `.husky/` — missing

### 4. No hook-framework config files

- `.pre-commit-config.yaml` / `.pre-commit-hooks.yaml` (pre-commit.com) — missing
- `lefthook.yml` / `.lefthook.yml` (lefthook) — missing
- `package.json` — missing (rules out husky)
- `Makefile` — missing (rules out a make-wrapped hook install step)

### 5. No repo-wide references to hooks

Ripgrep across the whole checkout:

```
grep -ir "pre-commit|precommit|git hook|lefthook|husky|hooksPath"   →   0 matches
```

### 6. Only documentation mentions quality gates — no enforcement

The only two files that reference `swiftformat` / `swiftlint` are:

- [`CLAUDE.md`](../../CLAUDE.md) — *Code Quality Enforcement* section declares rules ("Code MUST be auto-formatted before commit", "Developers MUST run SwiftFormat locally") but doesn't install anything.
- [`.swiftformat`](../../.swiftformat) and [`.swiftlint.yml`](../../.swiftlint.yml) exist as **tool configs**, but nothing invokes them on commit.

The `swiftformat` and `swiftlint` binaries are **not installed** on this machine (`which swiftformat swiftlint` → "not found").

### 7. No CI enforcement either

- `.github/workflows/` — missing (no GitHub Actions)
- No other CI config (`.gitlab-ci.yml`, `.circleci/`, `bitrise.yml`, etc.) present

---

## Relevant files / modules

| Path | Role | State |
|---|---|---|
| `/Users/nadzya/…/Tracker/.git/hooks/` | Shared worktree hook dir | Only `README.sample` |
| `.git/hooks/` (in worktree) | Per-worktree pointer, resolves to above | N/A |
| [`CLAUDE.md`](../../CLAUDE.md) § *Code Quality Enforcement* | Declarative rules | Documented only, not wired |
| [`.swiftformat`](../../.swiftformat), [`.swiftlint.yml`](../../.swiftlint.yml) | Tool configs | Unreferenced by any hook |
| `.github/workflows/` | CI enforcement | Missing |

---

## Key nuances

- **Intent vs. enforcement gap.** `CLAUDE.md` says "CI MUST fail if formatting is not applied" and "Lint errors MUST block merge", but neither a client-side hook nor a CI workflow exists yet. Enforcement is currently honor-system.
- **Worktree caveat.** Hooks in worktrees live in the *shared* main-repo `.git/hooks/`, not inside `.claude/worktrees/<name>/.git/`. Dropping a hook file directly into the worktree's `.git/hooks/` (which is really just a pointer) would have no effect. Proper setup requires either configuring `core.hooksPath` to a versioned directory, or installing hooks centrally in the main `.git`.
- **Tools not installed.** Even if a hook existed, it would fail because `swiftformat` and `swiftlint` are not on this machine. Installation is needed first (`brew install swiftformat swiftlint`).
- **Earlier in the session**, PR #1 introduced the `.swiftformat` and `.swiftlint.yml` configs and CLAUDE.md rules. I offered at that time to add a pre-commit hook and an Xcode Run Script phase, but the user didn't request it, so neither was implemented.

---

## Suggestive next steps (not implemented in this report)

Two reasonable paths to close the enforcement gap:

### A. Versioned git hooks via `core.hooksPath`

1. Add `scripts/hooks/pre-commit` to the repo:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   swiftformat --lint .
   swiftlint --strict
   ```
2. One-time developer setup step in a `CONTRIBUTING.md`:
   ```bash
   git config core.hooksPath scripts/hooks
   chmod +x scripts/hooks/pre-commit
   ```

Pros: zero dependencies. Cons: each developer must opt in.

### B. A hook manager (e.g. lefthook)

`lefthook.yml` in repo root:

```yaml
pre-commit:
  parallel: true
  commands:
    swiftformat:
      run: swiftformat --lint {staged_files}
      glob: "*.swift"
    swiftlint:
      run: swiftlint lint --strict {staged_files}
      glob: "*.swift"
```

One-time install: `brew install lefthook && lefthook install`.

### C. Server-side enforcement (orthogonal but recommended)

Add `.github/workflows/lint.yml` that runs `swiftformat --lint .` and `swiftlint --strict` on every PR so the rule survives developers forgetting local setup.

---

## CLAUDE.md compliance

This is a research report, not code. No architectural rules apply. The report complies with the documented research output format (short answer → how it works → relevant files → key nuances) from the `research` skill profile.
