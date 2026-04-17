import Link from "next/link";
import { Package, Tag } from "lucide-react";
import type { Module } from "@/lib/types";
import { hueOf } from "@/lib/catalog";
import { ViewCounter } from "./view-counter";

export function ModuleCard({ m }: { m: Module }) {
  const hue = hueOf(m.category);
  return (
    <Link
      href={`/modules/${m.id}`}
      aria-label={`Open ${m.name} module`}
      className="group block focus:outline-hidden"
    >
      <article className="card flex h-full flex-col transition-all duration-150 ease-out group-hover:-translate-y-0.5 group-hover:shadow-lift group-hover:border-accent/50 group-focus-visible:-translate-y-0.5 group-focus-visible:shadow-lift group-focus-visible:border-accent/50">
        <div className="flex items-start gap-3">
          <div
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg text-white"
            style={{ backgroundColor: `hsl(var(--accent))` }}
            aria-hidden
          >
            <Package className="h-5 w-5" />
          </div>
          <div className="min-w-0 flex-1">
            <div className="flex items-center justify-between gap-2">
              <h3 className="truncate text-base font-semibold tracking-tight">{m.name}</h3>
              <span className="shrink-0 rounded-md border border-border bg-surface2 px-1.5 py-0.5 font-mono text-[10px] text-muted">
                {m.version.module}
              </span>
            </div>
            <span
              className="inline-flex items-center gap-1 text-xs text-muted"
              style={{ color: `var(--hue-${hue}, inherit)` }}
            >
              <span className="h-1.5 w-1.5 rounded-full" style={{ backgroundColor: `hsl(var(--accent))` }} />
              <span className={`text-hue-${hue}`}>{m.category}</span>
            </span>
          </div>
        </div>

        <p className="mt-3 line-clamp-3 text-sm text-muted">{m.summary}</p>

        <div className="mt-4 flex flex-wrap gap-1.5">
          {m.tags.slice(0, 4).map((t) => (
            <span key={t} className="chip">
              <Tag className="h-3 w-3" /> {t}
            </span>
          ))}
        </div>

        <div className="mt-auto flex items-center justify-between border-t border-border pt-4 text-xs text-muted">
          <div className="flex gap-4">
            <span><b className="text-text">{m.stats.inputCount}</b> inputs</span>
            <span><b className="text-text">{m.stats.outputCount}</b> outputs</span>
            <span><b className="text-text">{m.stats.resourceCount}</b> resources</span>
          </div>
          <ViewCounter moduleId={m.id} mode="read" />
        </div>
      </article>
    </Link>
  );
}
