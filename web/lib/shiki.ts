import { getHighlighter, type Highlighter } from "shiki";

let highlighterPromise: Promise<Highlighter> | null = null;

export function getShikiHighlighter(): Promise<Highlighter> {
  if (!highlighterPromise) {
    highlighterPromise = getHighlighter({
      themes: ["github-dark-dimmed", "github-light"],
      langs: ["hcl", "terraform", "bash", "json"],
    });
  }
  return highlighterPromise;
}

export async function highlightHcl(code: string): Promise<string> {
  const h = await getShikiHighlighter();
  return h.codeToHtml(code, {
    lang: "hcl",
    themes: { dark: "github-dark-dimmed", light: "github-light" },
    defaultColor: false,
  });
}
