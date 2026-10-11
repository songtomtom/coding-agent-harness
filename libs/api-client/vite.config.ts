/// <reference types="vitest/config" />
import {defineConfig} from 'vite';
import react from '@vitejs/plugin-react';
import {nxViteTsPaths} from '@nx/vite/plugins/nx-tsconfig-paths.plugin';

export default defineConfig({
    plugins: [react(), nxViteTsPaths()],
    test: {
        environment: 'jsdom',
        passWithNoTests: true,
        include: ['src/**/*.test.{ts,tsx}']
    }
});
