import { defineConfig } from 'vite';

export default defineConfig({
  server: {
    port: 8090,
    proxy: {
      '/score': {
        target: 'http://localhost:8085',
        changeOrigin: true,
        secure: false
      }
    }
  }
});
