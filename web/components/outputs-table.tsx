import type { Output } from "@/lib/types";

export function OutputsTable({ outputs }: { outputs: Output[] }) {
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-surface">
      <table className="w-full text-sm">
        <thead className="bg-surface2 text-xs uppercase tracking-wider text-muted">
          <tr>
            <th className="px-4 py-2 text-left font-medium">Name</th>
            <th className="px-4 py-2 text-left font-medium">Expression</th>
            <th className="px-4 py-2 text-left font-medium">Description</th>
          </tr>
        </thead>
        <tbody>
          {outputs.map((o) => (
            <tr key={o.name} className="border-t border-border/60 align-top">
              <td className="whitespace-nowrap px-4 py-3 font-mono text-[13px]">{o.name}{o.sensitive ? <span className="ml-2 text-[10px] text-warn">sensitive</span> : null}</td>
              <td className="whitespace-pre-wrap px-4 py-3 font-mono text-xs text-accent2">{o.expression}</td>
              <td className="px-4 py-3 text-muted">{o.description}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
