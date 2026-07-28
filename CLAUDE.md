# CLAUDE.md

Claude Code instructions for **tfbox**. Read [AGENTS.md](./AGENTS.md) first — source of truth for repo layout, commands, CI, conventions, per-stack rules. This file adds Claude-specific behavior on top.

@AGENTS.md

## Validation depth — pick by blast radius

- **Single `.tf` edit in one module** → `terraform fmt -check -recursive`, `init -backend=false`, `validate` for that module; then `cd scripts && npm run build && npm test`.
- **New/renamed module** → full cross-stack run (AGENTS.md §5 full gate + §11). Update hardcoded `modules` array in `pr-checks.yml` **and** `pr-gate.yml`.
- **Scripts-only** → `npm run typecheck && npm test && npm run build` in `scripts/`.
- **Web UI change** → `npm run typecheck && npm run build` in `web/`. Regenerate catalog only if consumption changed. (`npm run lint` is broken on `main`; see AGENTS.md §5.)
- **Workflow change** → syntax-only check (no local runner); read related reusable workflow and call sites.

Never skip `npm run build` in `web/` after non-trivial changes — static export fails loudly on RSC/serialization issues that `typecheck` alone misses.

## Commit subjects — required contract

Releaser keywords (AGENTS.md §6) drive semver bumps. Use one:

- `feat(<module>): …` or `feature(<module>): …` → minor
- `fix(<module>): …`, `hotfix(…)`, `chore(…)`, `docs(…)`, `config(…)`, `ci(…)` → patch
- `breaking change: …` or subject containing `major change` → major

Don't invent prefixes; releaser ignores unknown ones.

## Behaviors to follow

- **Don't hand-edit generated output.** `catalog.json` (root, gitignored), `web/public/catalog.json`, `web/out/`, `web/.next/`. Regenerate via `scripts/`.
- **Don't introduce backends or `terraform apply` steps.** Modules consumed externally; CI uses `init -backend=false`.
- **Don't bump `required_version` / provider pins casually.** Current: Terraform `>= 1.9`, `aws ~> 5.50`, CI pins `1.10.5`.
- **Sub-READMEs say `pnpm`; CI uses `npm ci`.** Use `npm` — treat `pnpm` mentions as stale docs.
- **Windows shell is bash** (environment). Forward slashes, Unix redirection (`/dev/null`), not PowerShell syntax.
- **Every `aws/<module>/*.tf` starts with `/* ----- FILE/MODULE/DESCRIPTION ----- */` block-comment.** Parser extracts `DESCRIPTION:` as module summary. Preserve header on new files (AGENTS.md §8).

## Before finishing a task, verify

1. Touched stack's validation commands pass (see table above).
2. If `.tf` changed: catalog rebuilds clean, parser tests pass.
3. If new module added: `pr-checks.yml` + `pr-gate.yml` `modules` arrays updated; `scripts/category-map.ts` has entry for primary resource type.
4. No generated artifacts staged (`catalog.json`, `web/out/`, `web/public/catalog.json`, `.next/`).
5. Commit subject uses releaser keyword.

## Uncertainties

- Root `catalog.json` gitignored yet historically tracked; treat as artifact — don't stage new changes.
- Root `package-lock.json` is an **empty fossil** (`"packages": {}`) with no root `package.json` beside it. The real lockfiles are `scripts/package-lock.json` and `web/package-lock.json`. Don't add deps at the root.

## Agent equipment lives globally, not here

Skills, subagents, commands, hook logic, the permission list and the statusline are installed **globally on the machine** and are not versioned in this repo. `.claude/skills/`, `.claude/settings.local.json`, `.agents/`, `skills-lock.json` and `.serena/` are all gitignored: a tool may recreate them locally, and they must not come back into git.

The one exception is a **marker file** declaring opt-in to a global mechanism: `.claude/context-economy-protocol.md` is versioned on purpose, because a marker is a declaration and the logic it activates stays outside.
