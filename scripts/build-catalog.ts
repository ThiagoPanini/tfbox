/**
 * build-catalog.ts
 *
 * Discovers every module under ../aws/<name>/ and emits a single catalog.json
 * consumed by the Next.js web app at build time. Idempotent; safe in CI.
 *
 * Usage:
 *   tsx build-catalog.ts [--out <path>] [--repo <owner/name>]
 */
import { parse as hcl2json } from "@cdktf/hcl2json";
import { readFile, writeFile, readdir, stat } from "node:fs/promises";
import { createHash } from "node:crypto";
import { execSync } from "node:child_process";
import { resolve, relative, join, basename } from "node:path";
import { inferCategory, inferIcon, CATEGORIES } from "./category-map.js";

// ---------------------------------------------------------------------------
// Types (mirror catalog.schema.json)
// ---------------------------------------------------------------------------
interface Input {
  name: string;
  type: string;
  description: string;
  required: boolean;
  default: unknown;
  sensitive: boolean;
  nullable: boolean;
  validation: Array<{ condition: string; error_message: string }>;
  sourceFile: string;
  sourceLine: number;
}
interface Output {
  name: string;
  description: string;
  sensitive: boolean;
  expression: string;
  sourceFile: string;
  sourceLine: number;
}
interface Resource {
  type: string;
  name: string;
  count: string | null;
  forEach: string | null;
  provider: string;
  sourceFile: string;
  sourceLine: number;
}
interface DataSource {
  type: string;
  name: string;
  sourceFile: string;
  sourceLine: number;
}
interface DiagramNode {
  id: string;
  kind: "input" | "resource" | "output" | "data";
  label: string;
}
interface DiagramEdge {
  from: string;
  to: string;
}
interface ModuleEntry {
  id: string;
  name: string;
  path: string;
  category: string;
  tags: string[];
  summary: string;
  description: string;
  icon: string;
  version: {
    module: string;
    terraform: string;
    providers: Array<{ name: string; source: string; version: string }>;
  };
  maintainers: Array<{ name: string; github?: string }>;
  inputs: Input[];
  outputs: Output[];
  resources: Resource[];
  dataSources: DataSource[];
  moduleDependencies: Array<{ source: string; alias: string }>;
  examples: { minimal: string; advanced: string; withRemoteState: string };
  diagram: { nodes: DiagramNode[]; edges: DiagramEdge[] };
  files: Array<{ path: string; bytes: number; sha: string }>;
  stats: {
    inputCount: number;
    outputCount: number;
    resourceCount: number;
    requiredInputCount: number;
  };
}

// ---------------------------------------------------------------------------
// CLI
// ---------------------------------------------------------------------------
const args = process.argv.slice(2);
const outArg = args.indexOf("--out");
const repoArg = args.indexOf("--repo");
const REPO_ROOT = resolve(new URL("..", import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, "$1"));
const OUT_PATH = outArg >= 0 && args[outArg + 1] ? resolve(process.cwd(), args[outArg + 1]!) : resolve(REPO_ROOT, "catalog.json");
const REPO_SLUG = repoArg >= 0 && args[repoArg + 1] ? args[repoArg + 1]! : "ThiagoPanini/tfbox";
const AWS_DIR = resolve(REPO_ROOT, "aws");

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function git(cmd: string, fallback = ""): string {
  try {
    return execSync(`git ${cmd}`, { cwd: REPO_ROOT, stdio: ["ignore", "pipe", "ignore"] })
      .toString()
      .trim();
  } catch {
    return fallback;
  }
}

function sha256(s: string | Buffer): string {
  return createHash("sha256").update(s).digest("hex").slice(0, 16);
}

// hcl2json loses type-expression literal text (converts `string` -> "${string}").
// Parse the original source with a line-scanner to capture the raw type expression
// and line number for each variable / output / resource / data block.
interface BlockPosition {
  kind: "variable" | "output" | "resource" | "data";
  labels: string[];
  line: number;
  file: string;
  rawType?: string;
}

function scanBlocks(tfText: string, file: string): BlockPosition[] {
  const positions: BlockPosition[] = [];
  const lines = tfText.split(/\r?\n/);
  const blockRe = /^(variable|output|resource|data)\s+"([^"]+)"(?:\s+"([^"]+)")?\s*\{/;
  for (let i = 0; i < lines.length; i++) {
    const m = blockRe.exec(lines[i]!.trim());
    if (!m) continue;
    const [, kind, a, b] = m;
    const labels = b ? [a!, b] : [a!];
    const pos: BlockPosition = { kind: kind as BlockPosition["kind"], labels, line: i + 1, file };
    if (kind === "variable") {
      // Scan forward for the `type = ...` line; capture balanced braces/parens.
      pos.rawType = scanTypeExpr(lines, i);
    }
    positions.push(pos);
  }
  return positions;
}

function scanTypeExpr(lines: string[], startIdx: number): string | undefined {
  // Limit to the containing block; stop at the first line with depth returning to 0.
  let depth = 0;
  let inBlock = false;
  for (let i = startIdx; i < lines.length; i++) {
    const line = lines[i]!;
    for (const ch of line) {
      if (ch === "{") {
        depth++;
        inBlock = true;
      } else if (ch === "}") {
        depth--;
      }
    }
    if (inBlock && depth === 0 && i > startIdx) return undefined;
    const tm = /^\s*type\s*=\s*(.+?)\s*$/.exec(line);
    if (tm) {
      let expr = tm[1]!;
      // Balance parentheses across continuation lines.
      let open = (expr.match(/\(/g) || []).length;
      let close = (expr.match(/\)/g) || []).length;
      let j = i;
      while (open > close && j + 1 < lines.length) {
        j++;
        expr += "\n" + lines[j]!;
        open = (expr.match(/\(/g) || []).length;
        close = (expr.match(/\)/g) || []).length;
      }
      return expr.trim();
    }
  }
  return undefined;
}

function findPos(positions: BlockPosition[], kind: BlockPosition["kind"], labels: string[]): BlockPosition | undefined {
  return positions.find(
    (p) => p.kind === kind && p.labels.length === labels.length && p.labels.every((l, i) => l === labels[i]),
  );
}

// Pretty-print default values as valid HCL literals.
function hclLiteral(v: unknown): string {
  if (v === null || v === undefined) return "null";
  if (typeof v === "string") return JSON.stringify(v);
  if (typeof v === "number" || typeof v === "boolean") return String(v);
  if (Array.isArray(v)) return `[${v.map(hclLiteral).join(", ")}]`;
  if (typeof v === "object") {
    const entries = Object.entries(v as Record<string, unknown>);
    if (entries.length === 0) return "{}";
    return `{\n${entries.map(([k, vv]) => `    ${k} = ${hclLiteral(vv)}`).join("\n")}\n  }`;
  }
  return "null";
}

// Placeholder values for example snippets when a required var has no default.
function placeholder(type: string, name: string): string {
  const t = type.toLowerCase();
  if (t.startsWith("string")) return `"${name}-example"`;
  if (t.startsWith("number")) return "0";
  if (t.startsWith("bool")) return "false";
  if (t.startsWith("list") || t.startsWith("set") || t.startsWith("tuple")) return "[]";
  if (t.startsWith("map") || t.startsWith("object")) return "{}";
  return "null";
}

// ---------------------------------------------------------------------------
// Parse one module
// ---------------------------------------------------------------------------
async function parseModule(modDir: string): Promise<ModuleEntry> {
  const name = basename(modDir);
  const relPath = relative(REPO_ROOT, modDir).replace(/\\/g, "/");
  const entries = await readdir(modDir, { withFileTypes: true });
  const tfFiles = entries.filter((e) => e.isFile() && e.name.endsWith(".tf")).map((e) => e.name);

  // Parse + scan all .tf files.
  const merged: Record<string, any> = {};
  const positions: BlockPosition[] = [];
  const files: ModuleEntry["files"] = [];

  for (const fname of tfFiles) {
    const p = join(modDir, fname);
    const text = await readFile(p, "utf8");
    const json = (await hcl2json(fname, text)) as Record<string, any>;
    // hcl2json returns { variable: { name: [{...}] }, resource: { type: { name: [{...}] } }, ... }
    deepMerge(merged, json);
    positions.push(...scanBlocks(text, fname));
    const st = await stat(p);
    files.push({ path: `${relPath}/${fname}`, bytes: st.size, sha: sha256(text) });
  }

  // ---- Inputs
  const inputs: Input[] = [];
  const vars = merged.variable ?? {};
  for (const [vname, arr] of Object.entries<any>(vars)) {
    const body = Array.isArray(arr) ? arr[0] : arr;
    const pos = findPos(positions, "variable", [vname]);
    const rawType = pos?.rawType ?? stripInterp(body.type);
    inputs.push({
      name: vname,
      type: rawType ?? "any",
      description: body.description ?? "",
      required: body.default === undefined,
      default: body.default === undefined ? null : body.default,
      sensitive: body.sensitive === true,
      nullable: body.nullable !== false,
      validation: (body.validation ?? []).map((v: any) => ({
        condition: stripInterp(v.condition) ?? "",
        error_message: v.error_message ?? "",
      })),
      sourceFile: pos?.file ?? "variables.tf",
      sourceLine: pos?.line ?? 0,
    });
  }

  // ---- Outputs
  const outputs: Output[] = [];
  const outs = merged.output ?? {};
  for (const [oname, arr] of Object.entries<any>(outs)) {
    const body = Array.isArray(arr) ? arr[0] : arr;
    const pos = findPos(positions, "output", [oname]);
    outputs.push({
      name: oname,
      description: body.description ?? "",
      sensitive: body.sensitive === true,
      expression: stripInterp(body.value) ?? "",
      sourceFile: pos?.file ?? "outputs.tf",
      sourceLine: pos?.line ?? 0,
    });
  }

  // ---- Resources
  const resources: Resource[] = [];
  const res = merged.resource ?? {};
  for (const [rtype, group] of Object.entries<any>(res)) {
    for (const [rname, arr] of Object.entries<any>(group)) {
      const body = Array.isArray(arr) ? arr[0] : arr;
      const pos = findPos(positions, "resource", [rtype, rname]);
      resources.push({
        type: rtype,
        name: rname,
        count: body.count !== undefined ? stripInterp(body.count) : null,
        forEach: body.for_each !== undefined ? stripInterp(body.for_each) : null,
        provider: rtype.split("_")[0] ?? "aws",
        sourceFile: pos?.file ?? "main.tf",
        sourceLine: pos?.line ?? 0,
      });
    }
  }

  // ---- Data sources
  const dataSources: DataSource[] = [];
  const datas = merged.data ?? {};
  for (const [dtype, group] of Object.entries<any>(datas)) {
    for (const [dname] of Object.entries<any>(group)) {
      const pos = findPos(positions, "data", [dtype, dname]);
      dataSources.push({
        type: dtype,
        name: dname,
        sourceFile: pos?.file ?? "data.tf",
        sourceLine: pos?.line ?? 0,
      });
    }
  }

  // ---- Module deps
  const moduleDependencies: ModuleEntry["moduleDependencies"] = [];
  const mods = merged.module ?? {};
  for (const [alias, arr] of Object.entries<any>(mods)) {
    const body = Array.isArray(arr) ? arr[0] : arr;
    moduleDependencies.push({ alias, source: body.source ?? "" });
  }

  // ---- Version metadata
  const tfBlock = merged.terraform?.[0] ?? merged.terraform ?? {};
  const requiredVersion: string = tfBlock.required_version ?? "";
  const providersRaw = tfBlock.required_providers?.[0] ?? tfBlock.required_providers ?? {};
  const providers = Object.entries<any>(providersRaw).map(([pname, meta]) => ({
    name: pname,
    source: meta.source ?? "",
    version: meta.version ?? "",
  }));

  // ---- Module version from git tag (prefix "<name>/v" or generic "v")
  const moduleVersion = (() => {
    const specific = git(`tag -l "${name}/v*" --sort=-version:refname --merged HEAD`).split('\n')[0];
    if (specific) return specific.replace(`${name}/`, "");
    const generic = git(`tag -l "v*" --sort=-version:refname --merged HEAD`).split('\n')[0];
    return generic ? generic.replace(/^v/, "") : "unversioned";
  })();

  // ---- Maintainers from git log (top 3 by commit count in this dir)
  const maintainersRaw = git(`log --format=%an -- ${relPath}`).split("\n").filter(Boolean);
  const countMap = new Map<string, number>();
  for (const a of maintainersRaw) countMap.set(a, (countMap.get(a) ?? 0) + 1);
  const maintainers = Array.from(countMap.entries())
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([who]) => ({ name: who }));

  // ---- Summary (first sentence of first top-comment DESCRIPTION in main.tf / <primary>.tf)
  const summary = await extractSummary(modDir, tfFiles, name);

  // ---- Examples
  const examples = renderExamples(name, inputs);

  // ---- Diagram
  const diagram = buildDiagram(inputs, resources, outputs, dataSources);

  const category = inferCategory(resources.map((r) => r.type), name);
  const icon = inferIcon(resources.map((r) => r.type), name);

  return {
    id: name,
    name,
    path: relPath,
    category,
    tags: uniqueTags([category, ...resources.map((r) => r.type.split("_")[1] ?? "")]),
    summary,
    description: summary, // TODO: extend with per-module README once present
    icon,
    version: { module: moduleVersion, terraform: requiredVersion, providers },
    maintainers,
    inputs,
    outputs,
    resources,
    dataSources,
    moduleDependencies,
    examples,
    diagram,
    files,
    stats: {
      inputCount: inputs.length,
      outputCount: outputs.length,
      resourceCount: resources.length,
      requiredInputCount: inputs.filter((i) => i.required).length,
    },
  };
}

function uniqueTags(t: string[]): string[] {
  return Array.from(new Set(t.filter(Boolean)));
}

async function extractSummary(modDir: string, tfFiles: string[], moduleName: string): Promise<string> {
  // Score every file's DESCRIPTION block-comment. Prefer phrasing that sounds
  // module-level ("This Terraform module provisions…") and files that plausibly
  // host the main resource (main.tf, <moduleName>.tf). Fall back to longest.
  const candidates: Array<{ text: string; score: number }> = [];
  for (const f of tfFiles) {
    let text: string;
    try {
      text = await readFile(join(modDir, f), "utf8");
    } catch {
      continue;
    }
    const m = /DESCRIPTION:\s*\n\s*([\s\S]*?)(?:\n\s*(?:RESOURCES?:|DATA SOURCES?:|---))/i.exec(text);
    if (!m) continue;
    const cleaned = m[1]!
      .split("\n")
      .map((l) => l.replace(/^\s*\*?\s?/, "").trim())
      .join(" ")
      .replace(/\s+/g, " ")
      .trim();
    if (!cleaned) continue;

    let score = cleaned.length;
    if (/^This Terraform module\b/i.test(cleaned)) score += 10_000;
    else if (/^This module\b/i.test(cleaned)) score += 5_000;
    else if (/\bprovisions\b|\bcreates\b/i.test(cleaned.slice(0, 80))) score += 2_000;
    // Per-file concerns are not module summaries.
    if (/^Input variables\b|^Variables for\b/i.test(cleaned)) score -= 8_000;
    if (/^Outputs for\b/i.test(cleaned)) score -= 8_000;
    if (/\blocal variables\b|\bCentralized\b.*\bdata source/i.test(cleaned)) score -= 8_000;
    // File-name hints that suggest a "main" file.
    const base = f.replace(/\.tf$/, "");
    if (base === "main") score += 1_000;
    if (base === moduleName.replace(/-/g, "_")) score += 800;
    if (base.endsWith("_function") || base.endsWith("_queue") || base.endsWith("_topic") || base.endsWith("_table")) {
      score += 500;
    }
    candidates.push({ text: cleaned, score });
  }
  candidates.sort((a, b) => b.score - a.score);
  return (candidates[0]?.text ?? "").slice(0, 240);
}

function renderExamples(modName: string, inputs: Input[]): ModuleEntry["examples"] {
  const required = inputs.filter((i) => i.required);
  const common = inputs.filter(
    (i) => !i.required && i.default !== undefined && i.default !== null && typeof i.default !== "object",
  );
  const src = `github.com/ThiagoPanini/tfbox//${join("aws", modName).replace(/\\/g, "/")}`;

  const renderRow = (i: Input, value: string): string =>
    `  ${i.name.padEnd(Math.max(20, i.name.length))} = ${value}`;

  const minimalBody = required.map((i) => renderRow(i, placeholder(i.type, i.name))).join("\n");
  const minimal =
    `module "${modName}" {\n  source = "${src}"\n\n${minimalBody}${minimalBody ? "\n" : ""}}`;

  const advancedBody = [
    ...required.map((i) => renderRow(i, placeholder(i.type, i.name))),
    ...common.slice(0, 8).map((i) => renderRow(i, hclLiteral(i.default))),
  ].join("\n");
  const advanced =
    `module "${modName}" {\n  source = "${src}"\n\n${advancedBody}${advancedBody ? "\n" : ""}}`;

  const withRemoteState = `data "terraform_remote_state" "shared" {
  backend = "s3"
  config = {
    bucket = "my-tfstate-bucket"
    key    = "shared/terraform.tfstate"
    region = "us-east-1"
  }
}

${minimal}`;

  return { minimal, advanced, withRemoteState };
}

function buildDiagram(
  inputs: Input[],
  resources: Resource[],
  outputs: Output[],
  data: DataSource[],
): ModuleEntry["diagram"] {
  const nodes: DiagramNode[] = [
    ...inputs.map<DiagramNode>((i) => ({ id: `in:${i.name}`, kind: "input", label: i.name })),
    ...data.map<DiagramNode>((d) => ({ id: `data:${d.type}.${d.name}`, kind: "data", label: `${d.type}.${d.name}` })),
    ...resources.map<DiagramNode>((r) => ({ id: `res:${r.type}.${r.name}`, kind: "resource", label: r.type })),
    ...outputs.map<DiagramNode>((o) => ({ id: `out:${o.name}`, kind: "output", label: o.name })),
  ];
  const edges: DiagramEdge[] = [];

  // Heuristic edges: input -> resource if resource references var.<input> anywhere (we already stripped expr).
  // Conservative: connect each input to every resource, each resource to every output. Replace with static
  // analysis in v2 once we bring in a real expression walker.
  for (const r of resources) {
    for (const i of inputs) edges.push({ from: `in:${i.name}`, to: `res:${r.type}.${r.name}` });
    for (const o of outputs) {
      if (o.expression.includes(`${r.type}.${r.name}`)) {
        edges.push({ from: `res:${r.type}.${r.name}`, to: `out:${o.name}` });
      }
    }
  }
  return { nodes, edges };
}

// hcl2json wraps every expression in ${...} — strip for display / search.
function stripInterp(v: unknown): string {
  if (typeof v !== "string") return v === undefined ? "" : JSON.stringify(v);
  const m = /^\$\{(.*)\}$/s.exec(v);
  return m ? m[1]! : v;
}

function deepMerge(target: Record<string, any>, src: Record<string, any>): void {
  for (const [k, v] of Object.entries(src)) {
    if (target[k] && typeof target[k] === "object" && !Array.isArray(target[k]) && typeof v === "object" && !Array.isArray(v)) {
      deepMerge(target[k], v);
    } else if (Array.isArray(target[k]) && Array.isArray(v)) {
      target[k].push(...v);
    } else {
      target[k] = v;
    }
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  const entries = await readdir(AWS_DIR, { withFileTypes: true });
  const moduleDirs = entries.filter((e) => e.isDirectory()).map((e) => join(AWS_DIR, e.name));
  moduleDirs.sort();

  const modules: ModuleEntry[] = [];
  for (const d of moduleDirs) {
    try {
      modules.push(await parseModule(d));
      process.stderr.write(`[ok]  ${basename(d)}\n`);
    } catch (e) {
      process.stderr.write(`[err] ${basename(d)}: ${(e as Error).message}\n`);
      throw e;
    }
  }

  const search = {
    documents: modules.flatMap((m) => [
      { id: m.id, type: "module" as const, text: `${m.name} ${m.summary} ${m.tags.join(" ")}` },
      ...m.inputs.map((i) => ({
        id: `${m.id}#var.${i.name}`,
        type: "input" as const,
        text: `${i.name} ${i.type} ${i.description}`,
      })),
      ...m.outputs.map((o) => ({
        id: `${m.id}#out.${o.name}`,
        type: "output" as const,
        text: `${o.name} ${o.description}`,
      })),
      ...m.resources.map((r) => ({
        id: `${m.id}#res.${r.type}.${r.name}`,
        type: "resource" as const,
        text: `${r.type} ${r.name}`,
      })),
    ]),
  };

  const catalog = {
    $schema: "./catalog.schema.json",
    schemaVersion: "1.0.0",
    generatedAt: new Date().toISOString(),
    repo: {
      name: REPO_SLUG.split("/")[1] ?? "tfbox",
      url: `https://github.com/${REPO_SLUG}`,
      commit: git("rev-parse HEAD", ""),
      branch: git("rev-parse --abbrev-ref HEAD", "main"),
    },
    categories: CATEGORIES,
    modules,
    search,
  };

  await writeFile(OUT_PATH, JSON.stringify(catalog, null, 2));
  process.stderr.write(`\nwrote ${relative(REPO_ROOT, OUT_PATH)} (${modules.length} modules)\n`);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
