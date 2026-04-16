"use client";
import { catalog } from "@/lib/catalog";
import { useRouter, useSearchParams } from "next/navigation";
import { useCallback } from "react";

export function CategoryChips() {
  const params = useSearchParams();
  const router = useRouter();
  const active = params.get("cat");

  const set = useCallback(
    (id: string | null) => {
      const p = new URLSearchParams(params.toString());
      if (id === null || id === active) p.delete("cat");
      else p.set("cat", id);
      const q = p.toString();
      router.replace(q ? `/?${q}` : "/", { scroll: false });
    },
    [active, params, router],
  );

  return (
    <div className="flex flex-wrap gap-2" role="tablist" aria-label="Category filters">
      <button className="chip" data-active={!active} onClick={() => set(null)} role="tab" aria-selected={!active}>
        All
      </button>
      {catalog.categories.map((c) => (
        <button
          key={c.id}
          className="chip"
          data-active={active === c.id}
          onClick={() => set(c.id)}
          role="tab"
          aria-selected={active === c.id}
        >
          {c.label}
        </button>
      ))}
    </div>
  );
}
