"use client";
import { Check, Copy } from "lucide-react";
import { useState } from "react";

export function CopySnippetButton({ text, ariaLabel }: { text: string; ariaLabel: string }) {
  const [ok, setOk] = useState(false);
  return (
    <button
      type="button"
      aria-label={ariaLabel}
      onClick={async () => {
        try {
          await navigator.clipboard.writeText(text);
          setOk(true);
          window.setTimeout(() => setOk(false), 1500);
        } catch {
          /* ignore */
        }
      }}
      className="inline-flex h-7 items-center gap-1.5 rounded-md border border-border bg-surface2 px-2 text-xs text-muted transition-colors hover:text-text"
    >
      {ok ? <Check className="h-3.5 w-3.5 text-success" /> : <Copy className="h-3.5 w-3.5" />}
      {ok ? "Copied" : "Copy"}
    </button>
  );
}
