# AGENTS.md

Shared agent guidance for **tfbox**. Portable across AI coding tools. `CLAUDE.md` imports this file.

## 1. What this repo is

Three co-located stacks in one git repo:

| Path       | Stack                         | Purpose                                                                     |
|------------|-------------------------------|-----------------------------------------------------------------------------|
| `aws/`     | Terraform (HCL)               | Reusable AWS modules — the product. Each `aws/<name>/` is a standalone module. |
| `scripts/` | TypeScript + tsx + vitest     | Parses `aws/**/*.tf` → `catalog.json` consumed by the web app.              |
| `web/`     | Next.js 16 App Router (static export), React 19, Tailwind 4, Radix, Shiki, Fuse.js | Public catalog site. Pages published to GitHub Pages at `/tfbox`. |

Terraform modules are the product; `scripts/` + `web/` render documentation from them. Never edit catalog output to describe a module — edit `.tf` files and regenerate.

## 2. Top-level layout

```
aws/<module>/          # product — HCL modules (dynamodb-table, iam-role, lambda-function, lambda-layer, sns-topic, sqs-queue)
scripts/               # catalog builder (TS) + parser tests
web/                   # Next.js static site
docs/agents/           # how an agent works in this repo (tracker, labels, workflow, domain, design)
.github/workflows/     # pr-checks.yml, pr-gate.yml, deploy.yml, reusable-*.yml
.node-version          # the single declaration of the Node runtime version
lefthook.yml           # gate 1: local, pre-commit
commitlint.config.mjs  # commit message standard, read by the commit-msg hook
catalog.json           # build artifact (generated, gitignored)
catalog.schema.json    # schema for catalog.json
DESIGN.md              # web app design spec
LICENSE                # MIT
README.md              # public-facing README
```

This repo follows the **panlabs anatomy**, defined in [`panlabs-tech/.github`](https://github.com/panlabs-tech/.github). A compliance checker measures it against that definition; the files it requires and the reason for each are in [`docs/agents/`](docs/agents/).

## 3. Package manager & Node

- **CI uses `npm ci`** (`scripts/` + `web/` ship `package-lock.json`). Use `npm` locally. Sub-READMEs mention `pnpm` — stale; prefer `npm` to match CI.
- **Node version is declared once**, in the root `.node-version`. CI reads it (`node-version-file:`), and so does the machine's runtime manager. Never hardcode a version in a workflow; change the file.
- TypeScript `^6`.
- No root npm scripts. Always `cd scripts` or `cd web` first.

## 4. Setup

```bash
terraform -version         # >= 1.9, CI pins 1.10.5
cd scripts && npm ci
cd ../web && npm ci
```

## 5. Validation — run before declaring work done

Mirror CI. Run only what change touches, plus final targeted build.

### Changed `aws/<module>/`
```bash
terraform -chdir=aws/<module> fmt -check -recursive
terraform -chdir=aws/<module> init -backend=false
terraform -chdir=aws/<module> validate
cd scripts && npm run build && npm test
```
New `aws/<name>/` dir → update `modules` JSON array in **both** `.github/workflows/pr-checks.yml` and `.github/workflows/pr-gate.yml` (hardcoded, no auto-discovery).

### Changed `scripts/`
```bash
cd scripts
npm run typecheck
npm test
npm run build      # regenerates catalog.json
```

### Changed `web/`
```bash
cd web
npm run typecheck
npm run build      # next build; catches static-export errors
# optional: npm run test:e2e (playwright)
```

**`npm run lint` is broken on `main`** — ESLint 10 (bumped by Dependabot) is incompatible with the `eslint-plugin-react` bundled inside `eslint-config-next`, and it dies with `TypeError: ... getFilename is not a function` before evaluating a single rule. It is therefore out of both gates. Fixing the dependency and turning the step back on is separate work.

`npm test` in `web/` is also unusable as-is: there are no unit tests, and `vitest run` collects `e2e/smoke.spec.ts`, which is a Playwright spec. Use `npm run test:e2e` for that file.

### Full local PR gate
```bash
for m in dynamodb-table iam-role lambda-layer sqs-queue sns-topic lambda-function; do
  terraform -chdir=aws/$m fmt -check -recursive && \
  terraform -chdir=aws/$m init -backend=false && \
  terraform -chdir=aws/$m validate || break
done
(cd scripts && npm ci && npm run build && npm test)
cp catalog.json web/public/catalog.json
(cd web && npm ci && npm run typecheck && NEXT_PUBLIC_BASE_PATH=/tfbox npm run build)
```

## 6. CI / release model

Full detail, with the reason behind each choice: [`docs/agents/workflow.md`](docs/agents/workflow.md).

- `.github/workflows/pr-checks.yml` — **gate 2**. Runs on push to the work branches. Two surface legs (`checks-terraform`, `checks-node`), a fixed-id `checks` rollup job that aggregates them, `security` (secret scan, from the org's shared CI, pinned by exact tag), and the automatic PR. `checks` and `security` are the two required status checks of the whole org; their names are fixed by contract and must not be renamed.
- `.github/workflows/pr-gate.yml` — runs on PRs to `main`, including `closed`. Re-validates and **cuts the release**. Uses `techpivot/terraform-module-releaser@v2` which **parses commit subjects** for semver keywords:
  - **major**: `major change`, `breaking change`
  - **minor**: `feat`, `feature`
  - **patch**: `fix`, `hotfix`, `chore`, `docs`, `config`, `ci`

  Use these exact prefixes — `commitlint.config.mjs` enforces exactly this list at commit time, because a type outside it ships a change with **no version bump at all**. Module version tags: `aws/<name>/vX.Y.Z`.
- `.github/workflows/deploy.yml` — runs on `main` push → builds + deploys `web/out/` to GitHub Pages.
- Reusable: `reusable-modules-validation.yml` (per-module matrix: `fmt -check -recursive`, `init -backend=false`, `validate`), `reusable-catalog-validation.yml` (builds catalog, runs parser tests, builds web).

## 7. Repository-wide conventions

- **Gate 1 is local, before the commit:** [`lefthook.yml`](lefthook.yml) runs `terraform fmt -check` on staged `.tf`, `gitleaks` on the staged diff, and `commitlint` on the message. Every one of those depends only on **machine equipment** installed globally (`lefthook`, `gitleaks`, `terraform`, the Node runtime behind `npx`); this repo versions only the declaration that it opts in. Node checks that need per-project `node_modules` deliberately live in gate 2, where the install is part of the job.
- **Agent equipment is not versioned here.** Skills, subagents, commands and hook logic live in one place only, the global install. What *is* versioned is a marker file declaring opt-in to a global mechanism (`.claude/context-economy-protocol.md`).
- **Generated files — never hand-edit:** `catalog.json` (root, gitignored), `web/public/catalog.json`, `web/out/`, `web/.next/`.
- **Commit subject prefix** must match a releaser keyword (§6), enforced by `commitlint.config.mjs`. Format: `feat(<module>): add event source mapping`.
- **Branch naming**: `feature/<slug>`, `docs/<slug>`, `v<major>.<minor>.x`, `v<major>.<minor>.<patch>`, or a conventional prefix (`feat/`, `fix/`, `chore/`, `config/`, `ci/`, `refactor/`, `test/`). **CI only triggers on the patterns listed in `pr-checks.yml`** — a branch outside them publishes no status check, and under the org ruleset its PR hangs waiting for a check nobody will publish.
- **PR title**: the automatic PR uses the **first commit subject** of the branch, so it must already obey the releaser contract — under squash merge that title becomes the commit message landing on `main`. Manual PRs follow `.github/pull_request_template.md`. (Older PRs in the history use `pr(main): <branch> -> main`, from the workflow `pr-checks.yml` replaced.)
- **Secrets**: never commit `*.tfvars`, `*.tfstate*`, `.env*`. Enforced by `.gitignore`.

## 8. Terraform module conventions (`aws/<name>/`)

Each subdirectory is a **standalone, publishable module**. Consumers reference `git::https://github.com/ThiagoPanini/tfbox.git//aws/<name>?ref=<tag>`.

### File layout per module

| File             | Required | Purpose                                                                       |
|------------------|----------|-------------------------------------------------------------------------------|
| `versions.tf`    | yes      | `required_version = ">= 1.9"` + AWS provider pin (`~> 5.50`).                 |
| `variables.tf`   | yes      | All `variable` blocks with `description`, `type`, `default` (if optional), `validation` where values are constrained. |
| `main.tf`        | usually  | Primary resources. Split into named files (`policies.tf`, `roles.tf`, `lambda_function.tf`) when single `main.tf` would be long. |
| `outputs.tf`     | yes      | All `output` blocks with `description`.                                       |
| `locals.tf`      | optional | Derived values / complex expressions.                                         |
| `data.tf`        | optional | `data` blocks.                                                                |

### File header contract (parser-critical)

Every `.tf` file starts with block-comment header. Parser extracts `DESCRIPTION:` from module-level `.tf` files as the catalog summary. Preserve format:

```hcl
/* -----------------------------------------------------------------------------
  FILE: main.tf
  MODULE: aws/<name>

  DESCRIPTION:
    One-paragraph module purpose. First sentence is the card summary.

  RESOURCES:
    - aws_<type>.<name>: what it creates.
----------------------------------------------------------------------------- */
```

### HCL conventions

- **Resource name `this`** for primary resource of single-resource modules (e.g. `aws_dynamodb_table.this`). Descriptive names when multiple resources of same type.
- **Every variable** has `description`. Non-obvious constraints → `validation` block (`condition` + `error_message`). See `aws/dynamodb-table/variables.tf` for patterns (allow-list via `contains`, null-tolerant validations).
- **Defaults**: optional vars → `default = null` or sensible default; required vars omit `default`.
- **Outputs**: expose created resources + derived attributes consumers need; every `output` has `description`.
- **Tags**: expose `variable "tags"` (map(string), default `{}`) and thread to resources that support tagging.
- **Formatting**: `terraform fmt -recursive` before commit. CI fails on `fmt -check`.
- **Provider block**: do **not** declare `provider "aws" {}` inside module. Only `required_providers` in `versions.tf`. Consumers configure providers.
- **No backend blocks.** Modules backend-agnostic; CI uses `init -backend=false`.
- **No `.terraform.lock.hcl`** shipped — consumers own lockfiles.

### Adding a new module

1. Create `aws/<name>/` with files above.
2. Add name to `modules` JSON array in **both** `pr-checks.yml` and `pr-gate.yml`.
3. If primary resource type isn't in `scripts/category-map.ts`, add entry for category + icon.
4. Run full validation (§5).
5. First commit: `feat(<name>): initial module` → minor bump + `v0.0.1` tag.

## 9. Catalog builder conventions (`scripts/`)

TypeScript CLI. Entry: `build-catalog.ts` (run via `tsx`). Idempotent.

- `category-map.ts` maps primary `aws_*` resource type → category + icon for web UI.
- `__tests__/parser.test.ts` — vitest unit tests.

### Commands

```bash
npm run build        # writes ../catalog.json
npm run build:web    # writes ../web/public/catalog.json
npm run typecheck    # tsc --noEmit
npm test             # vitest run
```

CLI flags: `--out <path>`, `--repo <owner/name>`.

### Parsing pipeline (keep in sync if changed)

1. Enumerate `../aws/<module>/`.
2. Per module, read every `*.tf`, run through `@cdktf/hcl2json`, merge blocks.
3. Line-scan raw HCL to recover `type` expressions (hcl2json drops them) + source line numbers for every `variable`, `output`, `resource`, `data`.
4. Extract module `DESCRIPTION:` block-comment as summary.
5. Infer category + icon via `category-map.ts` from primary `aws_*` resource.
6. Render minimal / advanced / with-remote-state example snippets.
7. Emit diagram nodes/edges + flat `search.documents` for Fuse.js.

Emitted JSON must match `catalog.schema.json`. Change both together.

### Conventions

- ESM only (`"type": "module"`). Use `.js` suffixes in relative imports even from `.ts` (e.g. `import … from "./category-map.js"`).
- No runtime deps beyond `@cdktf/hcl2json`. Keep catalog build fast.
- Tests in `__tests__/*.test.ts`. Add fixture-backed test per parsing branch.
- Don't change CLI flags without updating `web/package.json`'s `catalog` script and `reusable-catalog-validation.yml`.

## 10. Web app conventions (`web/`)

Next.js 16 App Router, **static export** (`output: "export"` in `next.config.mjs`). Published to GitHub Pages under `/tfbox`.

### Stack

Next 16, React 19, TS 6. Tailwind v4 (`@tailwindcss/postcss`), custom token layer in `app/globals.css`. Radix (`dialog`, `tabs`, `tooltip`), `cmdk`, `lucide-react`. Shiki for HCL highlighting at build time in RSCs. Fuse.js for client search, `react-flow` + `dagre` for diagram, `next-themes` (dark default). ESLint 9 flat config, vitest, Playwright.

### Layout

```
app/
  layout.tsx, page.tsx, not-found.tsx, globals.css
  modules/[id]/page.tsx    # per-module detail, generateStaticParams
components/                # topbar, home-grid, module-card, module-detail, inputs/outputs/resources-table, command-palette, diagram-client, code-block, theme-*
lib/
  catalog.ts, types.ts, shiki.ts, cn.ts
public/catalog.json        # BUILD ARTIFACT — copied from ../catalog.json, do not hand-edit
e2e/smoke.spec.ts          # Playwright
```

### Commands

```bash
npm run dev        # next dev
npm run build      # next build → ./out (static export)
npm run lint       # eslint .
npm run typecheck  # tsc --noEmit
npm run test       # vitest
npm run test:e2e   # playwright
npm run catalog    # alias → (cd ../scripts && npm run build:web)
```

Before build, ensure `public/catalog.json` exists (`npm run catalog` or copy `../catalog.json`).

### Conventions

- **Static export constraints**: no server handlers, no `headers()`/`cookies()`, no dynamic route params without `generateStaticParams`, no middleware runtime, no `next/image` remote loaders (`images.unoptimized: true`).
- **basePath**: `NEXT_PUBLIC_BASE_PATH` defaults to `/tfbox` in production. Use relative paths for internal links; absolute URLs prepend `process.env.NEXT_PUBLIC_BASE_PATH`.
- **RSC by default**. Add `"use client"` only when component needs state, effects, refs, browser APIs (search, palette, diagram, theme toggle).
- **Types**: `lib/types.ts` mirrors `catalog.schema.json`. Change both together.
- **Design tokens**: colors/spacing/typography in `app/globals.css` + `tailwind.config.ts`. Read `DESIGN.md` before adding UI.
- **Accessibility**: keep focus-visible rings, keyboard nav on Radix primitives, responsive at 375 / 768 / 1440 (asserted in `e2e/smoke.spec.ts`).

### Don't

- Don't hand-edit `public/catalog.json`, `out/`, `.next/`.
- Don't add server runtime (API routes, middleware) — export breaks.
- Don't import from `../scripts` — `web/` builds standalone with `npm ci`. Regenerate `public/catalog.json` instead.
- Don't introduce `next/image` with remote loaders; keep `unoptimized: true`.

## 11. Cross-stack invariants

- Add/remove/rename Terraform module:
  1. Create/rename `aws/<name>/`.
  2. Update `modules` array in `pr-checks.yml` **and** `pr-gate.yml`.
  3. Regenerate: `cd scripts && npm run build`.
  4. Parser fixtures in `scripts/__tests__/parser.test.ts` may need updates.
- New AWS resource category → add entry to `scripts/category-map.ts`.
- Any `.tf` change flows through catalog: verify `npm run build` in `scripts/` succeeds and module renders — `web` reads `public/catalog.json` at build time.

## 12. Safety

- Never run `terraform apply` / `terraform plan` against real accounts. Don't add backends. Modules-only; `init -backend=false` intentional.
- Don't commit generated `catalog.json` (root) — artifact.
- Don't bump Terraform `required_version` or AWS provider pin without validating every module. Floor: `>= 1.9`, AWS `~> 5.50`.
- Dependency upgrades: Dependabot handles GH Actions + `scripts/` + `web/` weekly. Manual bumps: change `package.json` + regen lockfile via `npm install`, never hand-edit lockfile.

## 13. Pointers

- Web design spec + component inventory: [DESIGN.md](./DESIGN.md).
- Catalog schema: [catalog.schema.json](./catalog.schema.json).
- Module docs (published): repo Wiki (auto-updated by releaser).
- Agent configuration, one fixed-name doc per subject: [issue tracker](docs/agents/issue-tracker.md), [triage labels](docs/agents/triage-labels.md), [workflow](docs/agents/workflow.md), [domain](docs/agents/domain.md), [design](docs/agents/design.md).
- The standard this repo obeys, and the checker that measures it: [`panlabs-tech/.github`](https://github.com/panlabs-tech/.github).
