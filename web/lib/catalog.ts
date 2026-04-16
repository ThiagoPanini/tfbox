import type { Catalog, Module } from "./types";
import catalogJson from "../public/catalog.json";

// Server-side singleton — bundled at build time, zero runtime fetch.
export const catalog = catalogJson as unknown as Catalog;

export function allModules(): Module[] {
  return catalog.modules;
}
export function moduleById(id: string): Module | undefined {
  return catalog.modules.find((m) => m.id === id);
}
export function moduleIds(): string[] {
  return catalog.modules.map((m) => m.id);
}
export function categoryById(id: string) {
  return catalog.categories.find((c) => c.id === id);
}
export function hueOf(categoryId: string): string {
  return categoryById(categoryId)?.hue ?? "slate";
}
