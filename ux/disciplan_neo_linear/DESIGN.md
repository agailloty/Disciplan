---
name: Disciplan Neo-Linear
colors:
  surface: '#fbf9f4'
  surface-dim: '#dbdad5'
  surface-bright: '#fbf9f4'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ee'
  surface-container: '#f0eee9'
  surface-container-high: '#eae8e3'
  surface-container-highest: '#e4e2dd'
  on-surface: '#1b1c19'
  on-surface-variant: '#494740'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f1ec'
  outline: '#7a776f'
  outline-variant: '#cbc6bd'
  surface-tint: '#605e5b'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#1c1b19'
  on-primary-container: '#868380'
  inverse-primary: '#cac6c2'
  secondary: '#7b5900'
  on-secondary: '#ffffff'
  secondary-container: '#ffbf28'
  on-secondary-container: '#6e4f00'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002113'
  on-tertiary-container: '#009668'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#e6e2de'
  primary-fixed-dim: '#cac6c2'
  on-primary-fixed: '#1c1b19'
  on-primary-fixed-variant: '#484644'
  secondary-fixed: '#ffdea4'
  secondary-fixed-dim: '#fcbc24'
  on-secondary-fixed: '#261900'
  on-secondary-fixed-variant: '#5d4200'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#fbf9f4'
  on-background: '#1b1c19'
  surface-variant: '#e4e2dd'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: -0.01em
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: -0.005em
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 21px
    letterSpacing: 0em
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 19px
    letterSpacing: 0.005em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.03em
  code-inline:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
    letterSpacing: 0em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.25rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style

This design system embodies high-velocity agile craftsmanship. It fuses the rapid, keyboard-centric precision of modern developer tools with the considered warmth of editorial paper goods. The target audience comprises senior product squads, engineers, and designers who demand uncompromised interface speed, zero ambient clutter, and precise information density.

The aesthetic direction is **Warm Editorial Minimalism**:
- **Tactility without weight:** Surfaces feel grounded and parchment-clean, eschewing both harsh synthetic grays and heavy brutalist strokes.
- **Micro-focused efficiency:** Visual hierarchy is communicated through tight typographical scales, restrained color pops, and micro-delicacy (1px whisper borders).
- **Frictionless flow:** Chrome recedes entirely. The interface presents itself as a quiet, lightning-fast canvas optimized for instant capture, inline editing, and keyboard navigation.

## Colors

The palette establishes an organic, quiet studio workspace where purposeful signals take absolute precedence over ornamental color.

### Palette Architecture
- **Primary Ink (`#1A1917`):** Deep carbon black with a warm umber undertone; applied to primary typography, selected states, and crisp focus rings.
- **Secondary / Kinetic Amber (`#E5A800`):** Electric, warm amber calibrated strictly for intentional focal points: command palette active indices, keyboard shortcuts, urgent highlights, and inline status badges.
- **Tertiary / Emerald (`#10B981`):** Subdued botanical green for completed milestones, passing CI states, and resolution tags.
- **Canvas / Neutral (`#F7F5F0`):** Soft, archival alabaster that neutralizes monitor glare while maintaining clean separation against pure white element surfaces.

### Semantic & Functional Accents
- **Card / Island Fill:** `#FFFFFF` (Crisp white for primary item focus and active panels).
- **Border Whisper:** `#E4E0D7` (Subtle 1px boundary lines dividing workspaces without optical weight).
- **Secondary Ink / Muted:** `#6E6B65` (Balanced mid-tone for metadata, issue keys, and structural icons).
- **Tertiary Ink / Subdued:** `#A39F96` (Placeholder text, subtle breadcrumbs, and disabled affordances).
- **Status Amber:** `#F59E0B` (In-flight and actively tracking issues).
- **Status Slate:** `#9CA3AF` (Triage, backlog, and suspended states).

## Typography

Typography establishes an intentional cadence between editorial balance and industrial rigor.

- **Primary Typeface (Plus Jakarta Sans):** Selected for its geometric discipline tempered by natural, contemporary humanist contours. Headings retain tight letter spacing (`-0.02em`) to build visual authority without shouting. Body text prioritizes scannability across dense tables and board columns.
- **Monospace Discipline (JetBrains Mono):** Deployed for metadata, issue identifiers (`DIS-1042`), cycle markers, keyboard shortcut chips (`⌘K`), and technical status codes. Its clear tabular figures align effortlessly in compact vertical lists.
- **Hierarchy Rules:** Reserve `headline-xl` solely for top-tier views and sprint overviews. All contextual metadata and issue badges default to `label-sm` or `label-md` to avoid competing with card titles.

## Layout & Spacing

This design system utilizes an agile dual-model layout engine that balances structured data tables with multi-column boards.

### Layout Model
- **Grid Architecture:** Desktop workspace layouts employ a flexible column framework (typically 12 columns or continuous horizontal board tracks) flanked by persistent navigation trees and collapsible inspector sidebars.
- **Canvas Insets:**
  - **Desktop (≥ 1280px):** 2rem outer canvas margin with 1.25rem internal gutters between sprint columns or panel panes.
  - **Tablet (768px - 1279px):** 1.5rem outer canvas margin; Kanban views horizontally scroll with fixed-width (300px) lanes.
  - **Mobile (< 768px):** 1rem outer canvas margin; board columns automatically condense into a switchable swipe view or a single unified issue list.

### Spacing Philosophy
- Base layout rhythm aligns strictly to increments of 4px.
- Internal component density is kept tight: `space-xs` (4px) and `space-sm` (8px) govern list items, badge insets, and keycap groupings.
- Structural breathing room is preserved by using `space-lg` (20px) and `space-xl` (32px) around container modules to prevent visual fatigue during intensive task triage.

## Elevation & Depth

Visual hierarchy rejects thick drop shadows and heavy overlays, relying instead on surface tiers, whisper borders, and luminous micro-shadows.

### Layer Hierarchy
- **Base Canvas (`#F7F5F0`):** The ground plane. Houses the top navigation bar, backdrop workspaces, and list troughs.
- **Surface Elevation 1 (`#FFFFFF`):** Work cards, kanban item blocks, sidebars, and filter rails. Bound by a crisp `1px solid #E4E0D7` border.
- **Surface Elevation 2 (Floating Overlays):** Command palettes (`⌘K`), context menus, dropdown lists, and modal drawers. Rendered in `#FFFFFF` with a faint warm ambient shadow: `0 8px 30px rgba(26, 25, 23, 0.06), 0 1px 3px rgba(26, 25, 23, 0.04)`.
- **Active Focus & Selection:** Selection states never use deep elevation steps. Instead, a targeted `1.5px solid #1A1917` ring or a subtle kinetic highlight tint (`rgba(229, 168, 0, 0.08)`) marks the element without displacing layout geometry.

## Shapes

The shape system adopts a refined, subtle curve profile (Soft / Level 1) to evoke precision tools, drafted paper cards, and engineered hardware.

- **Base Corner Radius (`rounded-sm` / 0.25rem):** Standard interactive surfaces, including list items, input fields, keycaps, and dropdown triggers.
- **Card & Lane Radius (`rounded-lg` / 0.5rem):** Task item cards, modal dialog containers, command palette frames, and board containers.
- **Large Panels (`rounded-xl` / 0.75rem):** Deep inspector flyouts and primary dashboard sheets.
- **Pill Exception:** Purely designated for discrete semantic tags, filter pills, and author avatars to produce an unmistakable structural contrast against rectangular issue rows.

## Components

### Buttons
- **Primary:** Solid `#1A1917` fill, `#FFFFFF` text, `rounded-sm` (4px). On hover, shifts softly to `#302E2B`. Zero heavy drop shadows.
- **Secondary / Ghost:** Transparent background with a `1px solid #E4E0D7` border. Transitions to `rgba(26, 25, 23, 0.04)` fill on hover.
- **Keycap Buttons (`Kbd`):** Compact inline boxes using `JetBrains Mono` at `label-sm`, set in a `#FFFFFF` fill with a `1px solid #D8D4CA` perimeter and a `1px` subtle bottom offset border to provide micro-tactility.

### Input Fields & Command Palette
- **Inline Inputs:** Borderless or faint single-underline within issue lists for instantaneous creation.
- **Structured Fields:** `#FFFFFF` background, `1px solid #E4E0D7` border, `rounded-sm`, 8px vertical padding. Focus transitions border to `#1A1917` with no heavy outer glow.
- **The Command Palette (`⌘K`):** Fixed center-top sheet (max width 640px). Minimal header with a borderless auto-focus input (`headline-sm`). Item results display an issue title on the left, an issue ID in `label-sm` monospace, and the assigned shortcut sequence on the far right. Active row is tinted with `#F2EFE8` and marked by an `#E5A800` accent stroke on the left edge.

### Cards & List Rows
- **List Row:** High-density, single-line representation. Features priority icon, identifier (`DIS-89`), title (`body-md`), labels, assignee avatar (20px), and status indicator. On hover, reveals hidden action shortcuts.
- **Board Card:** Minimal `#FFFFFF` card bounded by `1px solid #E4E0D7`. Internal padding of `space-md` (12px). Contains priority marker, title (`headline-sm`), cycle date (`label-sm`), and subtle tag pills.

### Chips & Semantic Status Badges
- **Format:** Height 22px, `rounded-full`, padding: 2px 8px.
- **Done:** Light green tint background (`rgba(16, 185, 129, 0.1)`) with `#0D9488` text.
- **Active / In Progress:** Warm amber background (`rgba(245, 158, 11, 0.12)`) with `#B45309` text.
- **Backlog / Draft:** Slate tint (`rgba(156, 163, 175, 0.15)`) with `#4B5563` text.

### Checkboxes & Selection Affordances
- **Checkbox:** Crisp 14x14px box, `rounded-sm` (3px), `#E4E0D7` border. When marked, fills `#1A1917` with a razor-thin white checkmark icon.
- **Multi-select Bar:** Floats anchored at bottom-center when items are flagged via spacebar or multi-click; displays selected counter, batch operation shortcuts (`E` for Archive, `S` for Status), and clean divider rules.