import Link from "next/link";
export default function NotFound() {
  return (
    <div className="mx-auto max-w-md py-24 text-center">
      <p className="text-xs font-medium uppercase tracking-[0.18em] text-accent">404</p>
      <h1 className="mt-2 text-2xl font-semibold tracking-tight">Module not found</h1>
      <p className="mt-2 text-sm text-muted">Check the URL or return to the catalog.</p>
      <Link href="/" className="mt-6 inline-flex items-center rounded-lg border border-border bg-surface px-4 py-2 text-sm">
        Back to catalog
      </Link>
    </div>
  );
}
