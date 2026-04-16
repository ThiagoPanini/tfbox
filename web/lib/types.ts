// Mirrors ../../catalog.schema.json. Keep in sync.
export interface Catalog {
  schemaVersion: string;
  generatedAt: string;
  repo: { name: string; url: string; commit: string; branch: string };
  categories: Array<{ id: string; label: string; hue: string }>;
  modules: Module[];
  search: { documents: SearchDoc[] };
}
export interface Module {
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
  moduleDependencies: Array<{ alias: string; source: string }>;
  examples: { minimal: string; advanced: string; withRemoteState: string };
  diagram: { nodes: DiagramNode[]; edges: DiagramEdge[] };
  files: Array<{ path: string; bytes: number; sha: string }>;
  stats: { inputCount: number; outputCount: number; resourceCount: number; requiredInputCount: number };
}
export interface Input {
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
export interface Output {
  name: string;
  description: string;
  sensitive: boolean;
  expression: string;
  sourceFile: string;
  sourceLine: number;
}
export interface Resource {
  type: string;
  name: string;
  count: string | null;
  forEach: string | null;
  provider: string;
  sourceFile: string;
  sourceLine: number;
}
export interface DataSource {
  type: string;
  name: string;
  sourceFile: string;
  sourceLine: number;
}
export interface DiagramNode {
  id: string;
  kind: "input" | "resource" | "output" | "data";
  label: string;
}
export interface DiagramEdge {
  from: string;
  to: string;
}
export type SearchDoc = {
  id: string;
  type: "module" | "input" | "output" | "resource";
  text: string;
};
