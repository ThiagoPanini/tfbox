# DESIGN.md — tfbox web catalog

## 1. Design Brief

**Visual north star:** _Terraform Registry precision, Linear polish, AWS console authority — a product catalog where infrastructure feels tangible._

### Layout patterns adopted
1. **3-column doc shell** (shadcn/ui, Stripe): left nav, center tabs, right sticky metadata. Used on `/modules/[id]`.
2. **Card grid + search + filter chips** (Vercel Templates, constructs.dev): 1 / 2 / 3 columns responsive, URL-synced `?cat=<id>` filter.
3. **Tabbed detail page** (Terraform Registry): `Overview | Inputs | Outputs | Resources | Example | Diagram`, hash-deep-linkable.

### Interactions worth copying
1. **Cmd-K command palette** (Linear) — Fuse.js across modules, inputs, outputs, resources.
2. **Minimal / advanced / with-remote-state tab-switch copy** (shadcn docs) with checkmark-flash confirmation.
3. **Card hover** = 4px lift + accent-orange outer halo, 150ms ease-out.

### Anti-patterns avoided
1. Dense registry tables with no visual hierarchy.
2. Gratuitous hero illustrations that inflate TTI.
3. Light-only or dark-only defaults — `next-themes` respects `prefers-color-scheme`.

### Typography
- **Inter** (variable, cv11 + ss01 on), sizes 12/14/16/18/20/24/32/48.
- **JetBrains Mono** for HCL, inline code, variable names.
- Line-height 1.5 body, 1.2 display; tight tracking on headings (`-0.01em`).

### Colour tokens (HSL, dark default)

| token        | dark                 | light              | role                         |
|--------------|----------------------|--------------------|------------------------------|
| `--bg`       | `220 13% 5%`         | `0 0% 100%`        | page background              |
| `--surface`  | `220 13% 8%`         | `220 20% 98%`      | cards, popovers              |
| `--surface-2`| `220 12% 11%`        | `220 14% 96%`      | code blocks, zebra rows      |
| `--border`   | `220 10% 16%`        | `220 13% 91%`      | hairlines                    |
| `--text`     | `220 14% 91%`        | `220 9% 10%`       | primary text                 |
| `--muted`    | `220 9% 60%`         | `220 9% 46%`       | secondary text               |
| `--accent`   | `20 100% 60%`        | `20 100% 55%`      | CTAs, required markers       |
| `--accent-2` | `220 90% 66%`        | `220 90% 60%`      | type names, info             |
| `--success`  | `142 71% 45%`        | `142 71% 45%`      | outputs, copy-success        |
| `--danger`   | `0 84% 60%`          | `0 84% 60%`        | errors                       |
| `--warn`     | `38 92% 50%`         | `38 92% 50%`       | sensitive flags              |

Category hues: `violet` (compute), `emerald` (storage), `amber` (database), `cyan` (messaging), `rose` (iam), `sky` (networking), `slate` (other).

_Rationale._ Orange accent breaks from every FAANG-default blue doc site while echoing AWS brand. Near-black (`#0A0B0D`) avoids OLED bleed and keeps body contrast > 13:1 — well above WCAG AA.

## 2. Component inventory

| component                       | role                                                             |
|---------------------------------|------------------------------------------------------------------|
| `Topbar`                        | sticky brand + search trigger + theme toggle                     |
| `CategoryChips`                 | URL-synced category filter                                       |
| `HomeGrid`                      | client-side Fuse.js search over modules                          |
| `ModuleCard`                    | catalog card: icon, name, summary, tags, stats, copy-snippet     |
| `ModuleDetail`                  | Radix tabs shell                                                 |
| `InputsTable` / `OutputsTable`  | tabular records with required/sensitive badges                   |
| `ResourcesTable`                | resources + data sources with `file:line` pointers               |
| `CodeBlock` (RSC)               | Shiki-highlighted HCL with copy + line count                     |
| `CopySnippetButton`             | clipboard with check-icon flash (1.5s)                           |
| `DiagramClient`                 | react-flow + dagre auto-laid-out resource graph                  |
| `CommandPalette`                | cmdk dialog, Cmd-K, jump to module/input/output/resource         |
| `ThemeProvider` / `ThemeToggle` | next-themes dark-first                                           |

## 3. Self-verification checklist

- [x] Catalog generated from `.tf` files — no hand-edits.
- [x] New `aws/<name>/` dir auto-appears (parser iterates `readdir`).
- [x] Every `variable`, `output`, `resource`, `data` + validations extracted to `catalog.json`.
- [x] Responsive at 375 / 768 / 1440 px (Tailwind breakpoints; Playwright asserts no horizontal overflow).
- [x] Keyboard-navigable: topbar, chips, tabs (Radix), palette (cmdk), focus-visible ring.
- [x] Copy-to-clipboard on every snippet (card, example tab, palette detail right-rail).
- [ ] Lighthouse ≥ 90 / 95 / 95 — pending first deploy.
- [x] No console errors on `pnpm dev` (verified on local run).
- [x] Empty/loading states (search empty, 404).

## 4. Screenshots

Captured by `web/e2e/smoke.spec.ts` via `page.screenshot()` hooks during CI; written to `web/e2e/__screenshots__/` and uploaded as a workflow artifact. Add to this document once CI has produced them.

| view                    | file                                                    |
|-------------------------|---------------------------------------------------------|
| Home, desktop 1440 px   | `web/e2e/__screenshots__/home-desktop.png`              |
| Home, mobile 375 px     | `web/e2e/__screenshots__/home-mobile.png`               |
| Detail (lambda), 1440px | `web/e2e/__screenshots__/detail-lambda-desktop.png`     |
| Detail (lambda), 375 px | `web/e2e/__screenshots__/detail-lambda-mobile.png`      |

## 5. Deviation log

- **Parser lang** — spec said `.ts|.py`; chose TypeScript to keep the entire toolchain in Node (one `pnpm install` at each workspace root, reused bundler settings).
- **Diagram edges v1** — conservative heuristic (every input → every resource → every referencing output). v2 will do real HCL expression walking. Edge count is noisy on `sqs-queue` (32 inputs × 3 resources) but visually readable thanks to dagre LR layout.
- **Module version fallback** — git-tag match `aws/<name>/v*` → generic `v*` → `unversioned`. All modules currently resolve to `unversioned` (no tags pushed).
