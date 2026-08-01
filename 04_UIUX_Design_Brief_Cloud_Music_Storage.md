# UI/UX Design Brief
## Cloud Music Storage

---

## Table of Contents
1. Design Philosophy
2. Design System Overview
3. Typography
4. Spacing System
5. Color Palette
6. Dark / Light Theme
7. Iconography
8. Buttons
9. Cards
10. Navigation
11. Animation Principles
12. Accessibility
13. Responsive Layout Rules
14. Design Tokens
15. Component Library Index

---

## 1. Design Philosophy

Calm, content-forward, music-first. The UI recedes so album art and typography carry visual interest — similar restraint to Apple Music, with the organizational clarity of Google Drive. Motion is used purposefully (playback transitions, queue reordering) and never decoratively.

## 2. Design System Overview

- Grid: 8pt spacing base.
- Corner radius: 12px (cards), 24px (sheets/modals), full-round (pills, avatars, play buttons).
- Elevation via soft shadow + subtle blur, not heavy drop shadows.
- One primary accent color used sparingly against a neutral base (see palette).

## 3. Typography

| Role | Font | Size | Weight |
|---|---|---|---|
| Display (Now Playing title) | Inter / SF Pro | 28–32px | Bold (700) |
| H1 (Screen titles) | Inter | 24px | SemiBold (600) |
| H2 (Section headers) | Inter | 18px | SemiBold (600) |
| Body | Inter | 15px | Regular (400) |
| Caption/meta | Inter | 12–13px | Medium (500), 70% opacity |
| Button label | Inter | 15px | SemiBold (600) |

## 4. Spacing System

Base unit: 8px. Scale: `4, 8, 12, 16, 24, 32, 48, 64`.
- Screen horizontal padding: 16px (mobile), 24px (tablet/desktop).
- Card internal padding: 16px.
- Section vertical gap: 24–32px.

## 5. Color Palette

| Token | Hex | Usage |
|---|---|---|
| `--color-primary` | #1DB954-alt custom: `#2E6BFF` | Primary actions, play button, active states |
| `--color-accent` | `#FF6B4A` | Highlights, badges (e.g., "New", "Live") |
| `--color-bg-dark` | `#0B0D12` | Dark theme background |
| `--color-surface-dark` | `#14171F` | Dark theme cards/sheets |
| `--color-bg-light` | `#FAFAFB` | Light theme background |
| `--color-surface-light` | `#FFFFFF` | Light theme cards/sheets |
| `--color-text-primary-dark` | `#F5F6F8` | Primary text, dark theme |
| `--color-text-primary-light` | `#14171F` | Primary text, light theme |
| `--color-text-secondary` | 60–70% opacity of primary text | Meta/labels |
| `--color-success` | `#2ECC71` | Upload success, confirmations |
| `--color-error` | `#EF4444` | Errors, destructive actions |
| `--color-warning` | `#F5A623` | Quota warnings, moderation flags |

## 6. Dark / Light Theme

- Dark theme is default (music-app convention); light theme fully supported, toggle in Settings + system-preference auto-detect.
- All tokens defined as CSS/Dart theme variables — never hardcoded hex in components — so both themes stay in sync structurally.
- Album art remains the one place vivid, uncontrolled color is allowed; UI chrome stays neutral around it.

## 7. Iconography

- Line-style icon set (24px grid, 1.5–2px stroke), consistent with Material Symbols / SF Symbols outline style for native platform familiarity.
- Filled variant used only for active/selected state (e.g., filled heart when liked, filled play in mini player).

## 8. Buttons

| Type | Usage | Style |
|---|---|---|
| Primary | Main CTA (Play, Upload, Save) | Filled, primary color, full-round for play actions |
| Secondary | Supporting actions | Outlined, 1.5px border, transparent fill |
| Tertiary/Text | Low-emphasis (Cancel, Skip) | Text-only, no border |
| Destructive | Delete, Remove | Error-color text/outline, confirmation dialog required |
| Icon Button | Compact controls | 40x40 touch target minimum |

## 9. Cards

- **Track Card**: artwork (square, 56–64px in lists, larger in grid), title, artist/meta, trailing action (more menu / like).
- **Playlist/Album Card**: artwork grid tile, title, track count, optional gradient scrim for text legibility over art.
- **Artist Card**: circular avatar, name, follower count, follow button.
- Cards use consistent 12px radius and a 1px hairline border in light theme / subtle surface elevation in dark theme.

## 10. Navigation

- Mobile: bottom tab bar — Home, Library, Search, Downloads, Profile — with persistent mini player docked above the tab bar.
- Desktop/Web: left sidebar navigation (collapsible) + persistent bottom player bar, mirroring familiar desktop music-app conventions.
- Deep navigation (e.g., Playlist → Track → Artist) always leaves a clear back path; mini player never disappears during navigation.

## 11. Animation Principles

- Duration: 150–250ms for micro-interactions, 300–400ms for screen transitions.
- Easing: standard ease-in-out; spring curves reserved for playback control feedback (play/pause morph, like heart pop).
- Mini player → full player expands via a shared-element transition on artwork.
- No animation blocks user input; all transitions interruptible.

## 12. Accessibility

- Minimum contrast ratio 4.5:1 for body text, 3:1 for large text/icons, verified against both themes.
- All interactive elements ≥44x44pt touch target.
- Full semantic labeling for screen readers (TalkBack/VoiceOver): track cards announce title, artist, and playback state.
- Captions/lyrics support screen-reader-friendly text rendering, not image-only text.
- Reduced-motion setting disables non-essential transitions.

## 13. Responsive Layout Rules

| Breakpoint | Layout |
|---|---|
| <600px (mobile) | Single column, bottom nav, mini player docked |
| 600–1024px (tablet) | Two-column library grid, bottom or rail nav |
| >1024px (desktop/web) | Sidebar nav + multi-column content + persistent bottom player bar |

## 14. Design Tokens (excerpt, JSON-style)

```json
{
  "radius": { "sm": 8, "md": 12, "lg": 24, "full": 999 },
  "spacing": { "xs": 4, "sm": 8, "md": 16, "lg": 24, "xl": 32, "2xl": 48 },
  "elevation": { "card": "0 2px 8px rgba(0,0,0,0.12)", "sheet": "0 -4px 24px rgba(0,0,0,0.2)" },
  "typography": { "display": 28, "h1": 24, "h2": 18, "body": 15, "caption": 12 }
}
```

## 15. Component Library Index

Buttons, Icon Buttons, Text Fields, Search Bar, Track List Item, Track Grid Card, Playlist Card, Artist Card, Mini Player, Full Player Sheet, Queue Sheet, Bottom Tab Bar, Sidebar Nav, Progress/Upload Indicator, Empty State, Error State, Toast/Snackbar, Modal/Dialog, Bottom Sheet, Avatar, Badge/Chip, Equalizer Widget, OTP Input, Storage Usage Bar, Admin Data Table.
