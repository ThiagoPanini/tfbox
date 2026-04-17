"use client";
import { useEffect, useState } from "react";
import { Eye } from "lucide-react";
import { formatCount, getCount, incrementCount } from "@/lib/view-counter";

interface Props {
  moduleId: string;
  mode?: "read" | "increment";
  className?: string;
}

export function ViewCounter({ moduleId, mode = "read", className }: Props) {
  const [count, setCount] = useState<number | null | undefined>(undefined);

  useEffect(() => {
    const ac = new AbortController();
    const fn = mode === "increment" ? incrementCount(moduleId) : getCount(moduleId, ac.signal);
    fn.then((n) => setCount(n));
    return () => ac.abort();
  }, [moduleId, mode]);

  return (
    <span
      className={
        "inline-flex items-center gap-1 text-xs tabular-nums text-muted " +
        (className ?? "")
      }
      title={count != null ? `${count} views` : "views"}
      aria-label={count != null ? `${count} views` : "view count loading"}
    >
      <Eye className="h-3 w-3" />
      <span>{count === undefined ? "…" : formatCount(count)}</span>
    </span>
  );
}
