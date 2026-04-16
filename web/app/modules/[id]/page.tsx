import { notFound } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, ExternalLink, GitBranch } from "lucide-react";
import { moduleById, moduleIds, catalog } from "@/lib/catalog";
import { ModuleDetail } from "@/components/module-detail";

export function generateStaticParams() {
  return moduleIds().map((id) => ({ id }));
}

export default async function ModulePage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const m = moduleById(id);
  if (!m) return notFound();

  return (
    <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_320px]">
      <div>
        <div className="mb-6 flex items-center gap-3 text-sm">
          <Link href="/" className="inline-flex items-center gap-1 text-muted transition-colors hover:text-text">
            <ArrowLeft className="h-4 w-4" /> All modules
          </Link>
          <span className="text-muted">/</span>
          <span className="text-text">{m.name}</span>
        </div>

        <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="mb-2 text-xs font-medium uppercase tracking-[0.18em] text-accent">{m.category}</p>
            <h1 className="text-3xl font-semibold tracking-tight">{m.name}</h1>
            <p className="mt-2 max-w-2xl text-sm text-muted">{m.summary}</p>
          </div>
          <div className="flex flex-wrap gap-2">
            <span className="chip"><GitBranch className="h-3 w-3" /> {m.version.module}</span>
            <span className="chip">terraform {m.version.terraform}</span>
            {m.version.providers.map((p) => (
              <span key={p.name} className="chip">{p.name} {p.version}</span>
            ))}
            <a
              href={`${catalog.repo.url}/tree/${catalog.repo.branch}/${m.path}`}
              target="_blank"
              rel="noreferrer"
              className="chip hover:text-text"
            >
              Source <ExternalLink className="h-3 w-3" />
            </a>
          </div>
        </div>

        <ModuleDetail m={m} />
      </div>

      <aside className="hidden lg:block">
        <div className="sticky top-20 space-y-6">
          <nav className="text-sm">
            <p className="mb-3 text-xs font-medium uppercase tracking-wider text-muted">On this page</p>
            <ul className="space-y-1.5">
              {["Overview", "Inputs", "Outputs", "Resources", "Example", "Diagram"].map((s) => (
                <li key={s}>
                  <a href={`#${s.toLowerCase()}`} className="text-muted transition-colors hover:text-text">{s}</a>
                </li>
              ))}
            </ul>
          </nav>
          <div className="rounded-xl border border-border bg-surface p-4">
            <p className="mb-2 text-xs font-medium uppercase tracking-wider text-muted">Maintainers</p>
            <ul className="space-y-1 text-sm">
              {m.maintainers.slice(0, 3).map((who) => (
                <li key={who.name}>{who.name}</li>
              ))}
            </ul>
          </div>
        </div>
      </aside>
    </div>
  );
}
