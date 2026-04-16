"use client";
import { Command } from "cmdk";
import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Fuse from "fuse.js";
import type { Module } from "@/lib/types";
import { Box, FileInput, FileOutput, Server } from "lucide-react";

type PaletteCtx = { open: () => void; close: () => void };
const Ctx = createContext<PaletteCtx>({ open: () => {}, close: () => {} });
export const useCommandPalette = () => useContext(Ctx);

type Entry = { id: string; kind: "module" | "input" | "output" | "resource"; label: string; moduleId: string; hash?: string };

function buildEntries(modules: Module[]): Entry[] {
  const out: Entry[] = [];
  for (const m of modules) {
    out.push({ id: m.id, kind: "module", label: m.name, moduleId: m.id });
    for (const i of m.inputs) out.push({ id: `${m.id}#var-${i.name}`, kind: "input", label: `${m.name} · ${i.name}`, moduleId: m.id, hash: `inputs` });
    for (const o of m.outputs) out.push({ id: `${m.id}#out-${o.name}`, kind: "output", label: `${m.name} · ${o.name}`, moduleId: m.id, hash: `outputs` });
    for (const r of m.resources) out.push({ id: `${m.id}#res-${r.type}`, kind: "resource", label: `${m.name} · ${r.type}`, moduleId: m.id, hash: `resources` });
  }
  return out;
}

export function CommandPaletteProvider({ modules, children }: { modules: Module[]; children: React.ReactNode }) {
  const [isOpen, setOpen] = useState(false);
  const [q, setQ] = useState("");
  const router = useRouter();
  const entries = useMemo(() => buildEntries(modules), [modules]);
  const fuse = useMemo(
    () => new Fuse(entries, { keys: ["label"], threshold: 0.35, ignoreLocation: true, minMatchCharLength: 1 }),
    [entries],
  );
  const results = q ? fuse.search(q).slice(0, 40).map((r) => r.item) : entries.slice(0, 20);

  const open = useCallback(() => setOpen(true), []);
  const close = useCallback(() => setOpen(false), []);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setOpen((v) => !v);
      }
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, []);

  const go = (e: Entry) => {
    const hash = e.hash ? `#${e.hash}` : "";
    router.push(`/modules/${e.moduleId}${hash}`);
    setOpen(false);
    setQ("");
  };

  return (
    <Ctx.Provider value={{ open, close }}>
      {children}
      <Command.Dialog
        open={isOpen}
        onOpenChange={setOpen}
        label="Command Menu"
        className="fixed inset-0 z-50 flex items-start justify-center bg-black/40 p-4 pt-24 backdrop-blur-sm"
        contentClassName="w-full max-w-xl overflow-hidden rounded-xl border border-border bg-surface shadow-lift"
      >
        <Command.Input
          value={q}
          onValueChange={setQ}
          placeholder="Jump to module, input, output, resource…"
          className="w-full border-b border-border bg-transparent px-4 py-3 text-sm outline-hidden placeholder:text-muted"
        />
        <Command.List className="max-h-[60vh] overflow-y-auto p-2">
          <Command.Empty className="px-3 py-6 text-center text-sm text-muted">No matches.</Command.Empty>
          {results.map((r) => (
            <Command.Item
              key={r.id}
              value={`${r.kind} ${r.label}`}
              onSelect={() => go(r)}
              className="flex cursor-pointer items-center gap-3 rounded-md px-3 py-2 text-sm aria-selected:bg-surface2"
            >
              <KindIcon kind={r.kind} />
              <span className="flex-1 truncate">{r.label}</span>
              <span className="text-xs text-muted">{r.kind}</span>
            </Command.Item>
          ))}
        </Command.List>
      </Command.Dialog>
    </Ctx.Provider>
  );
}

function KindIcon({ kind }: { kind: Entry["kind"] }) {
  const cls = "h-4 w-4 text-muted";
  if (kind === "module") return <Box className={cls} />;
  if (kind === "input") return <FileInput className={cls} />;
  if (kind === "output") return <FileOutput className={cls} />;
  return <Server className={cls} />;
}
