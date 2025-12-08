import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// MindLab frontend Vite config – React + TS
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5177,
    strictPort: true
  },
  preview: {
    port: 4173,
    strictPort: true
  }
});
