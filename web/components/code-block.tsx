import { highlightHcl } from "@/lib/shiki";
import { CopySnippetButton } from "./copy-snippet-button";

export async function CodeBlock({ code, label = "hcl", ariaLabel }: { code: string; label?: string; ariaLabel: string }) {
  const html = await highlightHcl(code);
  const lines = code.split(/\r?\n/).length;
  return (
    <div className="group relative overflow-hidden rounded-lg border border-border bg-surface2">
      <div className="flex items-center justify-between border-b border-border/60 bg-surface px-3 py-1.5">
        <span className="font-mono text-[10px] uppercase tracking-wider text-muted">{label}</span>
        <div className="flex items-center gap-3">
          <span className="text-[10px] text-muted">{lines} lines</span>
          <CopySnippetButton text={code} ariaLabel={ariaLabel} />
        </div>
      </div>
      <div
        className="shiki-wrap overflow-x-auto px-4 py-3 text-[13px] leading-[1.55]"
        // eslint-disable-next-line react/no-danger
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  );
}
