import * as Tabs from "@radix-ui/react-tabs";
import type { Module } from "@/lib/types";
import { CodeBlock } from "./code-block";
import { InputsTable } from "./inputs-table";
import { OutputsTable } from "./outputs-table";
import { ResourcesTable } from "./resources-table";
import { DiagramClient } from "./diagram-client";

export function ModuleDetail({ m }: { m: Module }) {
  return (
    <Tabs.Root defaultValue="overview" className="w-full">
      <Tabs.List className="mb-6 flex gap-1 border-b border-border" aria-label="Module sections">
        {["overview", "inputs", "outputs", "resources", "example", "diagram"].map((t) => (
          <Tabs.Trigger
            key={t}
            value={t}
            className="relative -mb-px border-b-2 border-transparent px-4 py-2 text-sm font-medium capitalize text-muted transition-colors data-[state=active]:border-accent data-[state=active]:text-text"
          >
            {t}
          </Tabs.Trigger>
        ))}
      </Tabs.List>

      <Tabs.Content value="overview" id="overview" className="animate-fade-in">
        <div className="prose prose-invert max-w-none text-sm text-muted">
          <p>{m.description || m.summary}</p>
          <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-4">
            <StatCard label="Inputs" value={m.stats.inputCount} accent={m.stats.requiredInputCount} accentLabel="required" />
            <StatCard label="Outputs" value={m.stats.outputCount} />
            <StatCard label="Resources" value={m.stats.resourceCount} />
            <StatCard label="Data sources" value={m.dataSources.length} />
          </div>
        </div>
      </Tabs.Content>

      <Tabs.Content value="inputs" id="inputs" className="animate-fade-in">
        <InputsTable inputs={m.inputs} />
      </Tabs.Content>

      <Tabs.Content value="outputs" id="outputs" className="animate-fade-in">
        <OutputsTable outputs={m.outputs} />
      </Tabs.Content>

      <Tabs.Content value="resources" id="resources" className="animate-fade-in">
        <ResourcesTable resources={m.resources} dataSources={m.dataSources} />
      </Tabs.Content>

      <Tabs.Content value="example" id="example" className="animate-fade-in space-y-6">
        <div>
          <h3 className="mb-2 text-sm font-semibold">Minimal</h3>
          <CodeBlock code={m.examples.minimal} ariaLabel={`Copy ${m.name} minimal example`} />
        </div>
        <div>
          <h3 className="mb-2 text-sm font-semibold">Advanced</h3>
          <CodeBlock code={m.examples.advanced} ariaLabel={`Copy ${m.name} advanced example`} />
        </div>
        <div>
          <h3 className="mb-2 text-sm font-semibold">With remote state</h3>
          <CodeBlock code={m.examples.withRemoteState} ariaLabel={`Copy ${m.name} remote-state example`} />
        </div>
      </Tabs.Content>

      <Tabs.Content value="diagram" id="diagram" className="animate-fade-in">
        <DiagramClient diagram={m.diagram} />
      </Tabs.Content>
    </Tabs.Root>
  );
}

function StatCard({ label, value, accent, accentLabel }: { label: string; value: number; accent?: number; accentLabel?: string }) {
  return (
    <div className="rounded-xl border border-border bg-surface p-4">
      <p className="text-xs uppercase tracking-wider text-muted">{label}</p>
      <p className="mt-1 text-2xl font-semibold tracking-tight">{value}</p>
      {accent !== undefined ? <p className="text-[11px] text-accent">{accent} {accentLabel}</p> : null}
    </div>
  );
}
