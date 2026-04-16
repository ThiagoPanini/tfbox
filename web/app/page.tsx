import { Suspense } from "react";
import { allModules } from "@/lib/catalog";
import { CategoryChips } from "@/components/category-chips";
import { HomeGrid } from "@/components/home-grid";

export default function HomePage() {
  const modules = allModules();
  return (
    <>
      <section className="mb-10">
        <p className="mb-2 text-xs font-medium uppercase tracking-[0.18em] text-accent">tfbox / aws</p>
        <h1 className="text-balance text-3xl font-semibold tracking-tight sm:text-4xl">
          Production-grade Terraform modules, discoverable in 30 seconds.
        </h1>
        <p className="mt-3 max-w-2xl text-sm text-muted sm:text-base">
          Browse {modules.length} AWS modules. Copy a working snippet from the card. Drill in for inputs, outputs, resources,
          and an auto-generated dependency diagram — all kept in sync with the source <code className="font-mono text-text">.tf</code> files.
        </p>
      </section>

      <Suspense fallback={<div className="mb-6 h-8" />}>
        <section className="mb-6">
          <CategoryChips />
        </section>
        <HomeGrid modules={modules} />
      </Suspense>
    </>
  );
}
