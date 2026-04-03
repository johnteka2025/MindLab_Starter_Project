import { defineConfig } from 'vite';

export default defineConfig({
    server: {
        port: 8090,
        proxy: {
            '/score': {
                target: 'http://127.0.0.1:8085',
                changeOrigin: true,
                secure: false
            }
        }
    }
});
