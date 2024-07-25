import type { Config } from 'tailwindcss'
// import plugin from 'tailwindcss/plugin';

export default {
  darkMode: 'selector',
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts}",
  ],
  theme: {
    screens: {
      sm: '40rem',
      md: '60rem',
      lg: '80rem',
      xl: '100rem',
    },
    fontFamily: {
      sans: ['Inter', 'sans-serif'],
    },
    colors: {
      inherit: 'inherit',
      current: 'currentColor',
      transparent: '#00000000',
      black: '#000000',
      white: '#ffffff',
      gray: '#3b3f48',
      'gray/30': '#3b3f484d',
      'gray/70': '#3b3f48b3',
      'gray-dark': '#2a2e37',
      'gray-dark/50': '#2a2e3780',
      'gray-dark/70': '#2a2e37b3',
      'gray-dark/80': '#2a2e37cc',
      'gray-dark/90': '#2a2e37e6',
      yellow: '#ffbb00',
      'yellow/70': '#ffbb00b3',
      green: '#7ac142',
      'green/70': '#7ac142b3',
      beige: '#c8bc9d',
      'beige/40': '#c8bc9d66',
      red: '#ff4646',
      pink: '#ff47de'
    },
    extend: {
      spacing: {
        13: '3.25rem',
        '15': '3.75rem',
        25: '6.25rem',
        33: '8.25rem',
        38: '9.5rem',
        50: '12.5rem',
        66: '16.5rem',
        88: '22rem',
        130: '32.5rem',
        140: '35rem',
        150: '37.5rem',
        160: '40rem',
        225: '56.25rem',
        240: '60rem',
        406: '101.5rem',
      },
      fontSize: {
        smaller: ['85%', '135%'],
        '2xl': ['1.375rem', '1.85rem'],
      },
      width: {
        v2: '200vw',
      },
      strokeWidth: {
        '1.4': '1.4',
        3: '3',
      },
      borderRadius: {
        '3xl': '1.25rem',
      },
      zIndex: {
        1: '1',
      },
      gap: {
        17: '4.25rem',
      },
      transitionProperty: {
        DEFAULT: 'color, background-color, border-color, fill, stroke, opacity, box-shadow',
      },
      transitionDuration: {
        DEFAULT: '.15s',
      },
      transitionTimingFunction: {
        DEFAULT: 'ease',
      },
      backgroundSize: {
        dotted: '5px 1px',
      },
      animation: {
        'arrow': 'arrow .5s linear forwards',
      },
      keyframes: {
        arrow: {
          '100%': { 'stroke-dashoffset': '0' },
        }
      }
    }
  },
  corePlugins: {
    // Disable all Opacity plugins since we use native #RRGGBBAA hex color notation for opacity
    backdropOpacity: false,
    backgroundOpacity: false,
    borderOpacity: false,
    divideOpacity: false,
    placeholderOpacity: false,
    ringOpacity: false,
    textOpacity: false,
    // Disable all Transform and Filter plugins, since they generate tons of redundant CSS styles. We use transform / filter classes instead, plus Utilities styles with variables they use
    scale: false,
    rotate: false,
    translate: false,
    skew: false,
    blur: false,
    brightness: false,
    contrast: false,
    dropShadow: false,
    grayscale: false,
    hueRotate: false,
    invert: false,
    saturate: false,
    sepia: false,
    boxShadow: false,
    // shadow: false,
  },
  plugins: [],
  experimental: {
    optimizeUniversalDefaults: true,
  },
  future: {
    hoverOnlyWhenSupported: true,
  },
} satisfies Config
