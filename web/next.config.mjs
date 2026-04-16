/** @type {import('next').NextConfig} */
const isProd = process.env.NODE_ENV === "production";
// Publishing under https://<user>.github.io/tfbox — basePath required for assets to resolve.
const basePath = process.env.NEXT_PUBLIC_BASE_PATH ?? (isProd ? "/tfbox" : "");

const nextConfig = {
  output: "export",
  reactStrictMode: true,
  trailingSlash: true,
  images: { unoptimized: true },
  basePath,
  assetPrefix: basePath || undefined,
  env: { NEXT_PUBLIC_BASE_PATH: basePath },
};

export default nextConfig;
