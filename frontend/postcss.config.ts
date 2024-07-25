import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'
import type { Plugin } from 'postcss'

const redundancyFixer = (): Plugin => {
  return {
    postcssPlugin: 'redundancyFixer',
    Declaration(decl: Record<string, any>) {
      if (decl.prop == 'content' && (decl.value == 'var(--tw-content)' || (decl.value == "''" && decl.parent.selector == '.content'))) {
        decl.remove()
      } else if (decl.prop == '--tw-content') {
        if (decl.value == "''" || decl.value == '""') {
          decl.remove()
        } else {
          decl.prop = 'content'
        }
      } else if (decl.prop == '--tw-shadow-color' || decl.prop == '--tw-shadow') {
        decl.remove()
      } else {
        // We can safely remove the standard Tailwind variable prefix since we don't use any other CSS framework except Tailwind
        decl.prop = decl.prop.replaceAll('--tw-', '--')
        decl.value = decl.value.replaceAll('--tw-', '--')
      }
    },
  }
}
redundancyFixer.postcss = true

export default {
  plugins: [tailwindcss(), autoprefixer(), redundancyFixer()],
}
