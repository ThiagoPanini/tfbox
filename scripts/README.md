# catalog-builder

Parses every Terraform module under `../aws/` and emits a single `catalog.json` consumed by the tfbox web catalog (`../web/`).

## Run

```bash
cd scripts
pnpm install
pnpm build            # writes ../catalog.json
pnpm build:web        # writes ../web/public/catalog.json
```

## CLI flags

| flag          | default                   | purpose                            |
|---------------|---------------------------|------------------------------------|
| `--out PATH`  | `<repo>/catalog.json`     | output location                    |
| `--repo SLUG` | `ThiagoPanini/tfbox`      | used for source-link URLs          |

## What the parser does

1. Enumerates `../aws/<module>/` directories.
2. For each module, reads every `*.tf` file, runs it through `@cdktf/hcl2json`, and merges the JSON blocks.
3. Runs a line-scanner over the original HCL to recover `type` expressions (hcl2json loses them) and line numbers for every `variable`, `output`, `resource`, and `data` block.
4. Extracts the module `DESCRIPTION:` block-comment as the summary.
5. Infers category + icon from the primary `aws_*` resource via `category-map.ts`.
6. Renders three copy-paste examples (minimal / advanced / with-remote-state).
7. Builds a diagram node/edge list for `react-flow`.
8. Emits `catalog.json` + a flat `search.documents` array for Fuse.js.

The script is idempotent — rerun after adding a new module in `aws/<name>/` and the catalog picks it up with zero manual edits.

## Idempotency check

```bash
pnpm build && sha1sum ../catalog.json
pnpm build && sha1sum ../catalog.json   # same hash, provided no .tf file changed
```
