"use client";
import Fuse from "fuse.js";
import { useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import type { Module } from "@/lib/types";
import { ModuleCard } from "./module-card";
import { Search } from "lucide-react";

export function HomeGrid({ modules }: { modules: Module[] }) {
  const params = useSearchParams();
  const cat = params.get("cat");
  const [q, setQ] = useState("");

  const fuse = useMemo(
    () =>
      new Fuse(modules, {
        keys: ["name", "summary", "tags", "resources.type", "inputs.name", "outputs.name"],
        threshold: 0.35,
        ignoreLocation: true,
      }),
    [modules],
  );
  const filteredByCat = cat ? modules.filter((m) => m.category === cat) : modules;
  const visible = q ? fuse.search(q).map((r) => r.item).filter((m) => !cat || m.category === cat) : filteredByCat;

  return (
    <>
      <div className="relative mb-6 w-full max-w-xl">
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" aria-hidden />
        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="Filter modules by name, input, or AWS resource…"
          aria-label="Filter modules"
          className="h-10 w-full rounded-lg border border-border bg-surface pl-9 pr-3 text-sm outline-none transition-colors focus:border-accent/60"
        />
      </div>

      {visible.length === 0 ? (
        <div className="rounded-xl border border-dashed border-border bg-surface p-12 text-center">
          <p className="text-sm text-muted">No modules match <span className="font-mono text-text">{q || cat}</span>.</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 gap-4 animate-fade-in sm:grid-cols-2 xl:grid-cols-3">
          {visible.map((m) => (
            <ModuleCard key={m.id} m={m} />
          ))}
        </div>
      )}
    </>
  );
}
