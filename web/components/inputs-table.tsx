import type { Input } from "@/lib/types";

export function InputsTable({ inputs }: { inputs: Input[] }) {
  const sorted = [...inputs].sort((a, b) => Number(b.required) - Number(a.required) || a.name.localeCompare(b.name));
  return (
    <div className="overflow-hidden rounded-xl border border-border bg-surface">
      <table className="w-full text-sm">
        <thead className="bg-surface2 text-xs uppercase tracking-wider text-muted">
          <tr>
            <th className="px-4 py-2 text-left font-medium">Name</th>
            <th className="px-4 py-2 text-left font-medium">Type</th>
            <th className="px-4 py-2 text-left font-medium">Default</th>
            <th className="px-4 py-2 text-left font-medium">Description</th>
          </tr>
        </thead>
        <tbody>
          {sorted.map((i) => (
            <tr key={i.name} className="border-t border-border/60 align-top">
              <td className="whitespace-nowrap px-4 py-3 font-mono text-[13px]">
                <span className="text-text">{i.name}</span>
                {i.required ? (
                  <span className="ml-2 rounded bg-accent/10 px-1.5 py-0.5 font-sans text-[10px] font-semibold uppercase tracking-wider text-accent">
                    required
                  </span>
                ) : (
                  <span className="ml-2 rounded border border-border px-1.5 py-0.5 font-sans text-[10px] font-medium uppercase tracking-wider text-muted">
                    optional
                  </span>
                )}
                {i.sensitive ? <span className="ml-2 text-[10px] text-warn">sensitive</span> : null}
              </td>
              <td className="whitespace-pre-wrap px-4 py-3 font-mono text-xs text-accent2">{i.type}</td>
              <td className="whitespace-pre-wrap px-4 py-3 font-mono text-xs text-muted">
                {i.required ? "—" : JSON.stringify(i.default)}
              </td>
              <td className="px-4 py-3 text-muted">{i.description}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
