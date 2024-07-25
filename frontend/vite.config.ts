import { fileURLToPath, URL } from 'node:url'

import { defineConfig } from 'vite'
import { ViteMinifyPlugin } from 'vite-plugin-minify'
import vue from '@vitejs/plugin-vue'
import postcss from './postcss.config'

// https://vitejs.dev/config/
export default defineConfig({
  server: {
    host: true,
    proxy: {
      '/api/rest/v0/': {
        target: 'http://127.0.0.1:5273',
        rewrite: path => path.replace('/api/rest/v0', '')
      }
    }
  },
  build: {
    cssMinify: 'lightningcss',
    minify: 'terser',
    terserOptions: {
      module: true,
      compress: {
        drop_console: ['log', 'info'] as unknown as boolean, // Terser supports array, but Vite wants boolean
      },
      mangle: {
        module: true,
        toplevel: true,
      },
      output: {
        comments: false,
      },
    },
  },
  css: {
    postcss,
  },
  plugins: [vue(), ViteMinifyPlugin()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
    },
  },
})
