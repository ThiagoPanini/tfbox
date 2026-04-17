import type { Metadata } from "next";
import "./globals.css";
import { ThemeProvider } from "@/components/theme-provider";
import { Topbar } from "@/components/topbar";
import { CommandPaletteProvider } from "@/components/command-palette";
import { catalog } from "@/lib/catalog";

export const metadata: Metadata = {
  title: "tfbox — Terraform Module Catalog",
  description: "Discover, understand, and copy-paste AWS Terraform modules in under 30 seconds.",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="icon" href="/icon.svg" type="image/svg+xml" />
        <link rel="preconnect" href="https://rsms.me/" />
        <link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
      </head>
      <body>
        <ThemeProvider>
          <CommandPaletteProvider modules={catalog.modules}>
            <Topbar repoUrl={catalog.repo.url} />
            <main className="container pt-8 pb-20">{children}</main>
          </CommandPaletteProvider>
        </ThemeProvider>
      </body>
    </html>
  );
}
