"use client";
import { useMemo } from "react";
import ReactFlow, { Background, Controls, MarkerType, Position, type Edge, type Node } from "reactflow";
import "reactflow/dist/style.css";
import dagre from "dagre";
import type { Module } from "@/lib/types";

const NODE_W = 200;
const NODE_H = 44;

function layout(nodes: Node[], edges: Edge[]): { nodes: Node[]; edges: Edge[] } {
  const g = new dagre.graphlib.Graph();
  g.setDefaultEdgeLabel(() => ({}));
  g.setGraph({ rankdir: "LR", nodesep: 30, ranksep: 80, marginx: 16, marginy: 16 });
  nodes.forEach((n) => g.setNode(n.id, { width: NODE_W, height: NODE_H }));
  edges.forEach((e) => g.setEdge(e.source, e.target));
  dagre.layout(g);
  const out = nodes.map((n) => {
    const p = g.node(n.id);
    return { ...n, position: { x: p.x - NODE_W / 2, y: p.y - NODE_H / 2 } };
  });
  return { nodes: out, edges };
}

export function DiagramClient({ diagram }: { diagram: Module["diagram"] }) {
  const { nodes, edges } = useMemo(() => {
    const baseNodes: Node[] = diagram.nodes.map((n) => ({
      id: n.id,
      data: { label: n.label },
      position: { x: 0, y: 0 },
      style: nodeStyle(n.kind),
      sourcePosition: Position.Right,
      targetPosition: Position.Left,
    }));
    const baseEdges: Edge[] = diagram.edges.map((e, i) => ({
      id: `e${i}`,
      source: e.from,
      target: e.to,
      markerEnd: { type: MarkerType.ArrowClosed, color: "hsl(var(--muted))" },
      style: { stroke: "hsl(var(--border))", strokeWidth: 1.25 },
    }));
    return layout(baseNodes, baseEdges);
  }, [diagram]);

  return (
    <div className="h-[480px] overflow-hidden rounded-xl border border-border bg-surface">
      <ReactFlow nodes={nodes} edges={edges} fitView proOptions={{ hideAttribution: true }} nodesDraggable={false} zoomOnScroll>
        <Background color="hsl(var(--border))" gap={18} />
        <Controls showInteractive={false} />
      </ReactFlow>
    </div>
  );
}

function nodeStyle(kind: "input" | "resource" | "output" | "data") {
  const base = {
    padding: "8px 12px",
    borderRadius: 10,
    border: "1px solid hsl(var(--border))",
    fontSize: 12,
    fontFamily: "JetBrains Mono, ui-monospace",
    color: "hsl(var(--text))",
    background: "hsl(var(--surface-2))",
  } as const;
  if (kind === "input") return { ...base, borderColor: "hsl(var(--accent) / 0.7)", color: "hsl(var(--accent))" };
  if (kind === "output") return { ...base, borderColor: "hsl(var(--success) / 0.7)", color: "hsl(var(--success))" };
  if (kind === "data") return { ...base, borderStyle: "dashed" };
  return base;
}
