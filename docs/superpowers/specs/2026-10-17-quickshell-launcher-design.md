# Quickshell Migration — Sub-project 2: Launcher

Date: 2026-10-17
Status: approved design, pending implementation plan
Roadmap: see `2026-10-17-quickshell-bar-design.md` (sub-project 1, done)

## Goal

Replace `wofi --show drun`, `wofi-calc` and `wofi-emoji` with one Quickshell launcher
that reuses the bar's `Theme`, `Icons`, widgets and test harness.

## Behaviour

- Opened via IPC from Hyprland binds:
  - Super+Space → `qs ipc call launcher toggle apps`
  - Super+C → `qs ipc call launcher toggle calc` (opens with `=` prefilled)
  - Super+M → `qs ipc call launcher toggle emoji` (opens with `:` prefilled)
  - Toggling while open closes it.
- Shows on the Hyprland-focused monitor.
- Centered box ~600×550 on the overlay layer with exclusive keyboard focus. Search field on
  top, scrolling result list below. Selected row uses `elevated` background and a gold
  left bar. Fade + scale in over `Theme.animFast`.
- Keys: Up/Down and Ctrl+J/Ctrl+K move selection, Enter activates, Escape closes. Clicking
  outside the box closes; clicking a row activates it.
- Mode is decided by the first character of the query:

| Prefix | Mode | Results | Enter |
|---|---|---|---|
| none | apps | `DesktopEntries.applications` minus `noDisplay`; icon, name, comment; ranked by fuzzy score + frecency (empty query: frecency, then name) | `entry.execute()`, record usage, close |
| `=` | calc | one row: `qalc -t <expr>` result, recomputed 150 ms after typing stops | `wl-copy` result, close |
| `:` | emoji | rows from `data/emoji.txt` whose description contains every query word (max 200) | `wtype` + `wl-copy` the emoji, close (same as wofi-emoji) |

## Architecture

```
.config/quickshell/
├── shell.qml                 # + Launcher {}
├── launcher/
│   ├── Launcher.qml          # PanelWindow, IpcHandler "launcher", search + ListView
│   └── ResultRow.qml         # one row: icon/glyph, title, subtitle
├── services/
│   ├── AppUsage.qml          # frecency store (JSON via FileView at Quickshell.statePath)
│   └── Calc.qml              # debounced qalc Process; `result` property
├── data/emoji.txt            # copied from /usr/sbin/wofi-emoji DATA section
└── lib/
    ├── fuzzy.js              # score(query, text) → number, -1 = no match
    ├── frecency.js           # record(usage, key, now), boost(usage, key, now)
    └── launcher.js           # parseQuery(text) → {mode, term}; parseEmoji / filterEmoji
```

- Frecency: per app name `{count, last}`; boost = `log2(1 + count) × 0.5^(ageDays / 14)`.
  Rank = fuzzy score + 10 × boost.
- Results are plain JS objects `{kind, title, subtitle, icon, payload}`; `Launcher.activate()`
  dispatches on `kind`.

## Error handling

- `qalc` fails or prints nothing → no calc row.
- Missing or corrupt usage file → start empty; it is rewritten on the next launch.
- Missing `data/emoji.txt` → emoji mode shows no rows.
- No visible error UI for any of these.

## Integration

- `.config/hypr/hyprland.lua`: `menu` → `qs ipc call launcher toggle apps`; the Super+C and
  Super+M binds → `qs ipc call launcher toggle calc|emoji`.
- `.config/wofi/` stays in the repo. `power-profile.sh` (wofi picker) is obsolete; it stays
  with `.config/waybar/` until that directory is removed.

## Testing

- Unit tests (qmltestrunner): fuzzy ordering, frecency maths, query parsing, emoji filter.
- `tests/smoke.sh` stays clean.
- With the shell running: `qs ipc call launcher toggle apps` opens it; calling again closes.
- Manual: type to filter apps, launch one, reopen and see it ranked first; `=2+2` shows 4
  and Enter copies it; `:fire` finds 🔥 and Enter types it.

## Out of scope

Window switcher, clipboard history, web search, shell commands (candidate follow-ups).
