import { Suspense } from "react";
import { allModules } from "@/lib/catalog";
import { CategoryChips } from "@/components/category-chips";
import { HomeGrid } from "@/components/home-grid";
import { Hero } from "@/components/hero";

export default function HomePage() {
  const modules = allModules();
  return (
    <>
      <Hero />

      <Suspense fallback={<div className="mb-6 h-8" />}>
        <section className="mb-6">
          <CategoryChips />
        </section>
        <HomeGrid modules={modules} />
      </Suspense>
    </>
  );
}
