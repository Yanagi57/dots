# Theme: Black & Gold

A custom dark theme built around a black base with gold and teal accents. No purple, no blue, no pink. Minimal, high contrast, clean.

Inspired by Monokai Machine and Nord, with a completely custom accent palette.

---

## Color Palette

### Backgrounds

| Name      | Hex       | Usage                        |
|-----------|-----------|------------------------------|
| base      | `#222222` | Main background              |
| surface   | `#2A2A2A` | Panels, sidebars, popups     |
| elevated  | `#333333` | Floating elements, modals    |
| border    | `#3D3D3D` | Dividers, borders, outlines  |

### Accents

| Name      | Hex       | Usage                                  |
|-----------|-----------|----------------------------------------|
| gold      | `#FFD700` | Primary accent, keywords, highlights   |
| gold dim  | `#C9A800` | Hover states, secondary gold elements  |
| teal      | `#4DD9C0` | Secondary accent, strings, links       |
| teal dim  | `#2AA38E` | Hover states, secondary teal elements  |

### Text

| Name      | Hex       | Usage                      |
|-----------|-----------|----------------------------|
| primary   | `#F5F5F5` | Main text                  |
| secondary | `#BBBBBB` | Comments, muted text       |
| tertiary  | `#777777` | Placeholders, disabled     |

### Semantic

| Name    | Hex       | Usage          |
|---------|-----------|----------------|
| error   | `#FF5555` | Errors         |
| warning | `#FFB86C` | Warnings       |

---

## Syntax Highlighting Guidelines

Map these roles to the palette above. No purple or pink anywhere.

| Syntax Role        | Color         |
|--------------------|---------------|
| Keywords           | `#FFD700` gold |
| Functions          | `#FFD700` gold |
| Strings            | `#4DD9C0` teal |
| Constants/numbers  | `#4DD9C0` teal dim |
| Types/classes      | `#F5F5F5` primary |
| Comments           | `#777777` tertiary |
| Operators          | `#BBBBBB` secondary |
| Variables          | `#F5F5F5` primary |
| Parameters         | `#BBBBBB` secondary |

---

## Apps to Theme

- [ ] Neovim (fork Monokai Machine, swap purple tokens to gold)
- [ ] Kitty
- [ ] Waybar
- [ ] Wofi
- [ ] Wlogout

---

## Design Principles

- No purple, pink, or blue anywhere
- High contrast -- legible without being harsh
- Minimal -- syntax roles should be distinguishable but not loud
- Gold is primary, teal is secondary. Don't overuse either
- Let the dark background do most of the work
