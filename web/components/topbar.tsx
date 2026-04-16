"use client";
import Link from "next/link";
import { Github, Search } from "lucide-react";
import { ThemeToggle } from "./theme-toggle";
import { useCommandPalette } from "./command-palette";

export function Topbar({ repoUrl }: { repoUrl: string }) {
  const { open } = useCommandPalette();
  return (
    <header className="sticky top-0 z-40 border-b border-border/70 bg-bg/80 backdrop-blur">
      <div className="container flex h-14 items-center gap-4">
        <Link href="/" className="flex items-center gap-2 font-semibold tracking-tight">
          <span className="inline-block h-6 w-6 rounded bg-accent" aria-hidden />
          <span>tfbox</span>
          <span className="text-xs font-normal text-muted">/ catalog</span>
        </Link>

        <button
          type="button"
          onClick={open}
          className="ml-auto inline-flex h-9 items-center gap-2 rounded-lg border border-border bg-surface px-3 text-sm text-muted transition-colors hover:text-text"
        >
          <Search className="h-4 w-4" />
          <span className="hidden sm:inline">Search modules, inputs, resources…</span>
          <span className="sm:hidden">Search</span>
          <span className="ml-2 hidden items-center gap-1 sm:inline-flex">
            <kbd className="kbd">⌘</kbd>
            <kbd className="kbd">K</kbd>
          </span>
        </button>

        <a
          href={repoUrl}
          target="_blank"
          rel="noreferrer"
          className="inline-flex h-9 w-9 items-center justify-center rounded-lg border border-border bg-surface text-muted transition-colors hover:text-text"
          aria-label="Source repository"
        >
          <Github className="h-4 w-4" />
        </a>
        <ThemeToggle />
      </div>
    </header>
  );
}
