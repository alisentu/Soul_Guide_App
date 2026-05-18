---
name: SoulGuide
colors:
  surface: '#111316'
  surface-dim: '#111316'
  surface-bright: '#37393d'
  surface-container-lowest: '#0c0e11'
  surface-container-low: '#1a1c1f'
  surface-container: '#1e2023'
  surface-container-high: '#282a2d'
  surface-container-highest: '#333538'
  on-surface: '#e2e2e6'
  on-surface-variant: '#c3c6cf'
  inverse-surface: '#e2e2e6'
  inverse-on-surface: '#2f3034'
  outline: '#8d9199'
  outline-variant: '#43474e'
  surface-tint: '#a9c9f3'
  primary: '#e5eeff'
  on-primary: '#0c3254'
  primary-container: '#b4d4ff'
  on-primary-container: '#3c5c81'
  inverse-primary: '#416086'
  secondary: '#d2bfe7'
  on-secondary: '#382a4a'
  secondary-container: '#4f4062'
  on-secondary-container: '#c0aed5'
  tertiary: '#cef7de'
  on-tertiary: '#123726'
  tertiary-container: '#b2dbc2'
  on-tertiary-container: '#3d614e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d2e4ff'
  primary-fixed-dim: '#a9c9f3'
  on-primary-fixed: '#001c37'
  on-primary-fixed-variant: '#28496c'
  secondary-fixed: '#eedcff'
  secondary-fixed-dim: '#d2bfe7'
  on-secondary-fixed: '#221534'
  on-secondary-fixed-variant: '#4f4062'
  tertiary-fixed: '#c3ecd3'
  tertiary-fixed-dim: '#a7d0b8'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#294e3c'
  background: '#111316'
  on-background: '#e2e2e6'
  surface-variant: '#333538'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.2'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.3'
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '600'
    lineHeight: '1.3'
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.6'
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.05em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  container-max: 1200px
  gutter: 24px
  margin-mobile: 20px
  margin-desktop: 40px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

This design system is built to evoke a sense of digital tranquility paired with a quiet, focused energy. It targets a modern audience seeking mindfulness and professional personal growth. The aesthetic direction is a fusion of **Minimalism** and **Glassmorphism**, emphasizing clarity through generous whitespace (even in a dark theme) and depth through translucent, glowing elements. 

The visual language avoids harshness, opting instead for a "luminous dark" feel where UI elements appear to hold a soft internal light rather than reflecting external sources. Every interaction should feel fluid and intentional, maintaining a professional demeanor while remaining approachable.

## Colors

The palette is anchored by a deep anthracite base, layered with subtle navy radial gradients to prevent the interface from feeling flat or "true black." This creates a canvas that feels expansive like a night sky.

The functional palette uses soft, desaturated pastels that provide high legibility against the dark background without the optical vibration of neon colors.
- **Primary (Powder Blue):** Used for primary actions and active states.
- **Secondary (Soft Lilac):** Used for decorative accents and secondary categories.
- **Tertiary (Mint Green):** Used for success states and growth-related metrics.
- **Accent (Peach):** Used sparingly for notifications or specific highlights.

Gradients should be applied with a 45-degree angle, transitioning between a pastel tint and a slightly more saturated version of the same hue to maintain a "fresh" appearance.

## Typography

This design system utilizes **Plus Jakarta Sans** across all levels to maintain a friendly, welcoming, and optimistic tone. The typeface's wide apertures and modern geometric construction ensure high readability on dark backgrounds.

- **Headlines:** Use tighter letter-spacing and heavier weights to anchor the page.
- **Body Text:** Use the "Regular" weight (400) with generous line-height to ensure a calming reading experience.
- **Contrast:** High-emphasis text should use the Primary (Powder Blue) color, while secondary information should use a 60% opacity white to maintain hierarchy.

## Layout & Spacing

The layout follows a **Fluid Grid** model with a 12-column structure for desktop and a 4-column structure for mobile. A "Soft-Grid" approach is used for internal component spacing, based on 4px increments.

- **Margins:** Large outer margins are essential to maintain the minimalist and "breathable" feel.
- **Padding:** Components like cards and buttons use generous internal padding to emphasize the "Full" roundness of the shapes.
- **Alignment:** Content is generally center-aligned for landing experiences and left-aligned for dashboard/utility views to preserve a professional structure.

## Elevation & Depth

Depth is achieved through **Glassmorphism** and **Tonal Layers** rather than traditional drop shadows.

1.  **Level 0 (Base):** Deep anthracite with a subtle navy radial gradient centered at the top-left.
2.  **Level 1 (Cards):** Surfaces use a semi-transparent dark grey (approx. 8% white overlay) with a 20px backdrop blur and a 1px soft-white border at 10% opacity.
3.  **Level 2 (Popovers/Modals):** Increased backdrop blur (40px) and a subtle glow effect using a very low-opacity Primary color shadow (0px 20px 40px rgba(180, 212, 255, 0.05)).

## Shapes

The shape language is defined by **Full Roundness**. This creates an organic, soft, and safe environment for the user.

- **Buttons & Chips:** Must always be fully pill-shaped (height/2).
- **Cards & Containers:** Utilize a minimum of 2rem (32px) corner radius to maintain a consistent visual rhythm with the pill-shaped elements.
- **Icons:** Should feature rounded terminals and soft corners, avoiding any sharp 90-degree angles.

## Components

### Buttons
Primary buttons use a subtle gradient transition (e.g., Powder Blue to Soft Lilac). Text is high-contrast dark anthracite for readability. Hover states should involve a slight "glow" or increase in gradient saturation.

### Cards
Cards are the primary content vessel. They feature a 1px "ghost border" (low-opacity white) to define their edges against the dark background. Inner padding should be at least 24px-32px.

### Inputs & Fields
Input fields are pill-shaped with a dark, recessed background color. The border highlights in the Primary color gradient when focused.

### Chips & Tags
Small, fully rounded elements used for categorization. These use the secondary or tertiary colors at 15% opacity with a solid-colored label to maintain a soft, energetic look.

### Icons
Icons should be thin-stroke (1.5px to 2px) and use the pastel palette. For interactive icons, a soft "halo" background (10% opacity) appears on hover.

### Progress Indicators
Progress bars and rings should use a dual-pastel gradient (e.g., Mint to Powder Blue) to signify "energy" and "movement" in a calming way.