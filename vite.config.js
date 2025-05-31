/// <reference types="vitest" />
/// <reference types="vite/client" /> // Si usas TypeScript para que reconozca import.meta.env

import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  test: { // Configuración de Vitest
    globals: true, // Para no tener que importar describe, it, expect, etc. en cada archivo de test
    environment: 'jsdom', // Simular un entorno DOM
    setupFiles: './src/setupTests.js', // (Opcional) Archivo para configuración global de pruebas
    css: true, // Si tus componentes importan CSS y quieres que se procese (o usa mocks)
  },
});