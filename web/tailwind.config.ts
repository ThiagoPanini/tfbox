import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    container: { center: true, padding: "1.5rem", screens: { "2xl": "1440px" } },
    extend: {
      fontFamily: {
        sans: ["Inter", "ui-sans-serif", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "ui-monospace", "SFMono-Regular", "monospace"],
      },
      colors: {
        bg: "hsl(var(--bg))",
        surface: "hsl(var(--surface))",
        surface2: "hsl(var(--surface-2))",
        border: "hsl(var(--border))",
        text: "hsl(var(--text))",
        muted: "hsl(var(--muted))",
        accent: {
          DEFAULT: "hsl(var(--accent))",
          fg: "hsl(var(--accent-fg))",
        },
        accent2: "hsl(var(--accent-2))",
        success: "hsl(var(--success))",
        danger: "hsl(var(--danger))",
        warn: "hsl(var(--warn))",
        hue: {
          violet: "hsl(262 83% 58%)",
          emerald: "hsl(160 84% 39%)",
          amber: "hsl(38 92% 50%)",
          cyan: "hsl(189 94% 43%)",
          rose: "hsl(346 77% 50%)",
          sky: "hsl(199 89% 48%)",
          slate: "hsl(215 16% 47%)",
        },
      },
      boxShadow: {
        card: "0 1px 2px 0 rgb(0 0 0 / 0.05), 0 1px 3px 0 rgb(0 0 0 / 0.1)",
        lift: "0 10px 30px -12px hsl(var(--accent) / 0.35), 0 2px 8px rgb(0 0 0 / 0.25)",
      },
      keyframes: {
        "fade-in": { from: { opacity: "0", transform: "translateY(4px)" }, to: { opacity: "1", transform: "translateY(0)" } },
      },
      animation: { "fade-in": "fade-in 200ms ease-out" },
    },
  },
  plugins: [],
};
export default config;
