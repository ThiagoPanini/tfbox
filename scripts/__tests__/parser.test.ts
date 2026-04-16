import { describe, it, expect } from "vitest";
import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

// The parser is invoked end-to-end via `pnpm build`, which writes catalog.json.
// This suite asserts shape + invariants over the produced artifact so that any
// regression in source parsing, category inference, or example rendering fails
// loudly in CI.

const CATALOG_PATH = resolve(__dirname, "../../catalog.json");

async function loadCatalog() {
  const text = await readFile(CATALOG_PATH, "utf8");
  return JSON.parse(text);
}

describe("catalog.json", () => {
  it("contains every aws/<module> directory", async () => {
    const c = await loadCatalog();
    const ids = new Set(c.modules.map((m: any) => m.id));
    for (const expected of ["dynamodb-table", "iam-role", "lambda-function", "lambda-layer", "sns-topic", "sqs-queue"]) {
      expect(ids.has(expected)).toBe(true);
    }
  });

  it("classifies lambda-function as compute with aws/lambda icon", async () => {
    const c = await loadCatalog();
    const m = c.modules.find((m: any) => m.id === "lambda-function");
    expect(m.category).toBe("compute");
    expect(m.icon).toBe("aws/lambda");
  });

  it("extracts a module-level summary (never a per-file variables/locals blurb)", async () => {
    const c = await loadCatalog();
    for (const m of c.modules) {
      expect(m.summary).toBeTruthy();
      expect(m.summary).not.toMatch(/^Input variables\b/i);
      expect(m.summary).not.toMatch(/^Outputs for\b/i);
      expect(m.summary).not.toMatch(/^This file defines local variables\b/i);
    }
  });

  it("records line numbers for every input/output/resource", async () => {
    const c = await loadCatalog();
    for (const m of c.modules) {
      for (const i of m.inputs) expect(i.sourceLine).toBeGreaterThan(0);
      for (const o of m.outputs) expect(o.sourceLine).toBeGreaterThan(0);
      for (const r of m.resources) expect(r.sourceLine).toBeGreaterThan(0);
    }
  });

  it("renders minimal example containing every required input", async () => {
    const c = await loadCatalog();
    for (const m of c.modules) {
      for (const i of m.inputs) {
        if (i.required) expect(m.examples.minimal).toContain(i.name);
      }
    }
  });

  it("search index references only known modules", async () => {
    const c = await loadCatalog();
    const ids = new Set(c.modules.map((m: any) => m.id));
    for (const d of c.search.documents) {
      const moduleId = d.id.split("#")[0];
      expect(ids.has(moduleId)).toBe(true);
    }
  });

  it("produces diagram edges only between declared nodes", async () => {
    const c = await loadCatalog();
    for (const m of c.modules) {
      const nodeIds = new Set(m.diagram.nodes.map((n: any) => n.id));
      for (const e of m.diagram.edges) {
        expect(nodeIds.has(e.from)).toBe(true);
        expect(nodeIds.has(e.to)).toBe(true);
      }
    }
  });
});
