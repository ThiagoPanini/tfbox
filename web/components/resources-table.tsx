import type { Resource, DataSource } from "@/lib/types";

export function ResourcesTable({ resources, dataSources }: { resources: Resource[]; dataSources: DataSource[] }) {
  return (
    <div className="space-y-6">
      <div className="overflow-hidden rounded-xl border border-border bg-surface">
        <div className="border-b border-border bg-surface2 px-4 py-2 text-xs font-medium uppercase tracking-wider text-muted">Resources ({resources.length})</div>
        <table className="w-full text-sm">
          <tbody>
            {resources.map((r) => (
              <tr key={`${r.type}.${r.name}`} className="border-t border-border/60">
                <td className="px-4 py-3 font-mono text-[13px] text-accent2">{r.type}<span className="text-muted">.{r.name}</span></td>
                <td className="px-4 py-3 text-xs text-muted">
                  {r.count ? <span>count = {r.count}</span> : r.forEach ? <span>for_each = {r.forEach}</span> : <span className="text-muted/60">single</span>}
                </td>
                <td className="px-4 py-3 text-right font-mono text-xs text-muted">{r.sourceFile}:{r.sourceLine}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {dataSources.length > 0 ? (
        <div className="overflow-hidden rounded-xl border border-border bg-surface">
          <div className="border-b border-border bg-surface2 px-4 py-2 text-xs font-medium uppercase tracking-wider text-muted">Data sources ({dataSources.length})</div>
          <table className="w-full text-sm">
            <tbody>
              {dataSources.map((d) => (
                <tr key={`${d.type}.${d.name}`} className="border-t border-border/60">
                  <td className="px-4 py-3 font-mono text-[13px] text-accent2">{d.type}<span className="text-muted">.{d.name}</span></td>
                  <td className="px-4 py-3 text-right font-mono text-xs text-muted">{d.sourceFile}:{d.sourceLine}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : null}
    </div>
  );
}
