/**
 * View counter — persistent across users/sessions without a custom backend.
 *
 * GitHub Pages is static, so the counter lives on a small key/value endpoint.
 * Default: https://abacus.jasoncameron.dev (free, no-auth, CORS `*`).
 *
 *   GET {base}/get/{namespace}/{key}  -> { value }
 *   GET {base}/hit/{namespace}/{key}  -> { value } (increment then return)
 *
 * Env:
 *   NEXT_PUBLIC_COUNTER_BASE      (default: https://abacus.jasoncameron.dev)
 *   NEXT_PUBLIC_COUNTER_NAMESPACE (default: tfbox-thiagopanini)
 */
export const COUNTER_BASE =
  process.env.NEXT_PUBLIC_COUNTER_BASE || "https://abacus.jasoncameron.dev";
export const COUNTER_NAMESPACE =
  process.env.NEXT_PUBLIC_COUNTER_NAMESPACE || "tfbox-thiagopanini";

const memCache = new Map<string, number>();

function keyFor(moduleId: string): string {
  return `mod-${moduleId.replace(/[^a-z0-9-]/gi, "-")}`;
}

async function fetchJson(url: string, signal?: AbortSignal): Promise<number | null> {
  try {
    const r = await fetch(url, { signal, cache: "no-store" });
    if (r.status === 404) return 0;
    if (!r.ok) return null;
    const data = (await r.json()) as { value?: number; count?: number };
    const n = typeof data.value === "number" ? data.value : data.count;
    return typeof n === "number" ? n : null;
  } catch {
    return null;
  }
}

export async function getCount(moduleId: string, signal?: AbortSignal): Promise<number | null> {
  const cached = memCache.get(moduleId);
  if (cached !== undefined) return cached;
  const n = await fetchJson(`${COUNTER_BASE}/get/${COUNTER_NAMESPACE}/${keyFor(moduleId)}`, signal);
  if (n !== null) memCache.set(moduleId, n);
  return n;
}

export async function incrementCount(moduleId: string, signal?: AbortSignal): Promise<number | null> {
  const sessionKey = `tfbox:hit:${moduleId}`;
  if (typeof window !== "undefined" && sessionStorage.getItem(sessionKey)) {
    return getCount(moduleId, signal);
  }
  if (typeof window !== "undefined") sessionStorage.setItem(sessionKey, "1");
  const n = await fetchJson(`${COUNTER_BASE}/hit/${COUNTER_NAMESPACE}/${keyFor(moduleId)}`, signal);
  if (n !== null) {
    memCache.set(moduleId, n);
  } else if (typeof window !== "undefined") {
    sessionStorage.removeItem(sessionKey);
  }
  return n;
}

export function formatCount(n: number | null | undefined): string {
  if (n === null || n === undefined) return "—";
  if (n < 1000) return String(n);
  if (n < 10_000) return (n / 1000).toFixed(1).replace(/\.0$/, "") + "k";
  if (n < 1_000_000) return Math.round(n / 1000) + "k";
  return (n / 1_000_000).toFixed(1).replace(/\.0$/, "") + "M";
}
