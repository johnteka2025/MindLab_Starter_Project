import { defineConfig, loadEnv } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig(({ mode }) => {
  // Load env from the frontend root (where vite.config.ts lives)
  const env = loadEnv(mode, process.cwd(), "VITE_");

  // Force: if missing, fail FAST at dev-server start (not at runtime in api.ts)
  if (!env.VITE_API_BASE_URL || !env.VITE_API_BASE_URL.trim()) {
    throw new Error(
      `VITE_API_BASE_URL is missing. Create frontend/.env.local with:\n` +
      `VITE_API_BASE_URL=http://localhost:8085\n` +
      `Current mode=${mode} cwd=${process.cwd()}`
    );
  }

  return {
    plugins: [react()],
    server: { port: 5177, strictPort: true },
    preview: { port: 4173, strictPort: true },

    // Hard-define so import.meta.env has it even if some env load edge-case happens
    define: {
      "import.meta.env.VITE_API_BASE_URL": JSON.stringify(env.VITE_API_BASE_URL),
    },
  };
});
