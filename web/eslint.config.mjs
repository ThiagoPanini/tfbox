import { dirname } from "path";
import { fileURLToPath } from "url";
import nextConfig from "eslint-config-next";

const __dirname = dirname(fileURLToPath(import.meta.url));

const config = [
  { ignores: [".next/**", "out/**"] },
  ...nextConfig.map((c) => ({ ...c, settings: { ...c.settings, next: { rootDir: __dirname } } })),
];

export default config;
