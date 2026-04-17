/**
 * View counter — persistent across users/sessions without a custom backend.
 *
 * GitHub Pages is static, so the counter lives on a small key/value endpoint.
 * Default: https://api.counterapi.dev (free, no-auth, rate-limited). Both the
 * namespace and the base URL are overridable via env vars, so the site can
 * point at a self-hosted endpoint (Cloudflare Worker, Vercel Edge, Deno Deploy)
 * that exposes the same shape:
 *
 *   GET  {base}/{namespace}/{key}       -> { count }
 *   GET  {base}/{namespace}/{key}/up    -> { count } (increment then return)
 *
 * Env:
 *   NEXT_PUBLIC_COUNTER_BASE      (default: https://api.counterapi.dev/v1)
 *   NEXT_PUBLIC_COUNTER_NAMESPACE (default: tfbox-thiagopanini)
 *
 * A per-session guard (sessionStorage) prevents the same tab from incrementing
 * the same module twice.
 */
export const COUNTER_BASE =
  process.env.NEXT_PUBLIC_COUNTER_BASE || "https://api.counterapi.dev/v1";
export const COUNTER_NAMESPACE =
  process.env.NEXT_PUBLIC_COUNTER_NAMESPACE || "tfbox-thiagopanini";

const memCache = new Map<string, number>();

function keyFor(moduleId: string): string {
  return `mod-${moduleId.replace(/[^a-z0-9-]/gi, "-")}`;
}

function localKey(moduleId: string): string {
  return `tfbox:count:${moduleId}`;
}

function readLocal(moduleId: string): number | null {
  if (typeof window === "undefined") return null;
  const v = localStorage.getItem(localKey(moduleId));
  if (v === null) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

function writeLocal(moduleId: string, n: number): void {
  if (typeof window !== "undefined") localStorage.setItem(localKey(moduleId), String(n));
}

async function fetchJson(url: string, signal?: AbortSignal): Promise<number | null> {
  try {
    const r = await fetch(url, { signal, cache: "no-store" });
    if (!r.ok) return null;
    const data = (await r.json()) as { count?: number; value?: number };
    const n = typeof data.count === "number" ? data.count : data.value;
    return typeof n === "number" ? n : null;
  } catch {
    return null;
  }
}

export async function getCount(moduleId: string, signal?: AbortSignal): Promise<number | null> {
  const cached = memCache.get(moduleId);
  if (cached !== undefined) return cached;
  // GET endpoint returns 204 — fall back to last known value from localStorage
  const local = readLocal(moduleId);
  if (local !== null) {
    memCache.set(moduleId, local);
    return local;
  }
  // Attempt live read anyway in case API behavior changes
  const n = await fetchJson(`${COUNTER_BASE}/${COUNTER_NAMESPACE}/${keyFor(moduleId)}`, signal);
  if (n !== null) {
    memCache.set(moduleId, n);
    writeLocal(moduleId, n);
  }
  return n;
}

export async function incrementCount(moduleId: string, signal?: AbortSignal): Promise<number | null> {
  const sessionKey = `tfbox:hit:${moduleId}`;
  if (typeof window !== "undefined" && sessionStorage.getItem(sessionKey)) {
    return getCount(moduleId, signal);
  }
  if (typeof window !== "undefined") sessionStorage.setItem(sessionKey, "1");
  const n = await fetchJson(`${COUNTER_BASE}/${COUNTER_NAMESPACE}/${keyFor(moduleId)}/up`, signal);
  if (n !== null) {
    memCache.set(moduleId, n);
    writeLocal(moduleId, n);
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
