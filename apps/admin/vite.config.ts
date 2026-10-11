/// <reference types="vitest/config" />
import {defineConfig} from 'vite';
import react from '@vitejs/plugin-react';
import {nxViteTsPaths} from '@nx/vite/plugins/nx-tsconfig-paths.plugin';

export default defineConfig({
    // tsconfig.base.json 의 paths 를 Vite alias 로. @board/* 가 libs/*/src 로 해석된다.
    plugins: [react(), nxViteTsPaths()],
    build: {outDir: '../../dist/apps/admin', emptyOutDir: true},
    test: {
        environment: 'jsdom',
        passWithNoTests: true,
        include: ['src/**/*.test.{ts,tsx}']
    }
});
