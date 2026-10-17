# Quickshell Migration — Sub-project 1: Foundation + Bar

Date: 2026-10-17
Status: approved design, pending implementation plan

## Context

The desktop currently uses Waybar (bar), wofi (launcher + calc/emoji/power-profile pickers),
wlogout (power menu), swaync (notifications) and hyprlock (lockscreen), all themed
Black & Gold per `CLAUDE.md`. Quickshell 0.3.2 is installed. The goal is to move all of
these into one Quickshell config, written from scratch using end-4's dots-hyprland as
visual/pattern reference only (no code fork).

## Roadmap

Each item is its own spec → plan → implementation cycle. Old tools keep running until
their replacement is signed off; only then is their autostart line removed (configs stay
in the repo until confirmed unneeded).

1. **Foundation + bar** (this spec) — replaces Waybar
2. Launcher — replaces wofi, wofi-calc, wofi-emoji. Separate centered list popup.
   `=` prefix = calc, `:` prefix = emoji. Super+Space / Super+C / Super+M open it in the
   matching mode.
3. Power menu — replaces wlogout. Fullscreen dim overlay, 6 buttons, same letter keys
   (l/h/o/s/u/r).
4. Notifications — replaces swaync. Top-right popups + control center (DND, media, history).
5. OSD — volume/brightness pill, bottom center.
6. Workspace overview — Super+Tab, live previews.
7. Lockscreen — replaces hyprlock; hypridle stays and calls the Quickshell lock.

## Architecture

```
.config/quickshell/
├── shell.qml              # entry; Variants over Quickshell.screens → one Bar per monitor
├── theme/
│   ├── qmldir
│   └── Theme.qml          # singleton: palette, font, radius, spacing, anim durations
├── services/              # singletons, data only, no UI
│   ├── qmldir
│   ├── Sensors.qml        # cpu/gpu/nvme temps, gpu utilisation
│   ├── SystemStats.qml    # cpu %, memory
│   └── PowerProfile.qml   # get/set power profile
├── widgets/               # reusable UI: Island.qml, Popup.qml, Icon.qml
└── bar/
    ├── Bar.qml            # PanelWindow, top layer, ~34px tall, islands style
    ├── islands/           # one file per island
    └── popups/            # CalendarPopup, SensorsPopup, QuickSettingsPopup
```

Rules:

- Data flows one way: services expose properties, UI binds to them. UI never runs commands
  for data directly.
- No hex colours outside `Theme.qml`. Palette is exactly the `CLAUDE.md` table (base
  `#222222`, surface `#2A2A2A`, elevated `#333333`, border `#3D3D3D`, gold `#FFD700`,
  gold dim `#C9A800`, teal `#4DD9C0`, teal dim `#2AA38E`, text `#F5F5F5`/`#BBBBBB`/`#777777`,
  error `#FF5555`, warning `#FFB86C`). No purple, pink or blue.
- Font: JetBrainsMono Nerd Font (installed).
- `theme/`, `services/` and `widgets/` are shared by later sub-projects.
- `~/.config` resolves into the dotfiles repo, so no extra linking is needed.

## Bar

Islands style: transparent bar background, each group is a rounded pill (surface fill,
1px border colour outline). Layout: left — workspaces, media; center — clock;
right — system, status, toggles, tray.

| Island | Content | Interaction |
|---|---|---|
| Workspaces | Dots; active = wide gold pill; special workspaces shown | Click to switch, scroll to cycle |
| Media | Player icon + title (max 30 chars), italic when paused. Hidden when no player. Ignore `playerctld`. | Click play/pause, right-click next |
| Clock | `HH:MM`, gold | Click opens **CalendarPopup** |
| System | CPU temp, GPU temp, NVMe temp (teal) · CPU %, GPU %, RAM used (GiB) | Click opens **SensorsPopup** |
| Status | Volume, Bluetooth, network (wifi strength / ethernet), battery (hidden if absent) | Click opens **QuickSettingsPopup** |
| Toggles | Power profile icon, notification bell (gold when unread), caffeine | Profile: click cycles. Bell: `swaync-client -t -sw` (until sub-project 4). Caffeine: toggles an idle inhibitor. |
| Tray | SystemTray items | Native menus |

### Popups

All popups use one shared `widgets/Popup.qml`: anchored below the island that opened it,
fade + slide in ~150ms, close on outside click or Escape. Only one popup open at a time.

- **CalendarPopup** — month grid, today highlighted gold, scroll to change month, header
  with weekday + full date.
- **SensorsPopup** — each metric (cpu/gpu/nvme temp, cpu %, gpu %, ram) with current
  value and a sparkline of the last 60 s.
- **QuickSettingsPopup** — volume slider + mute, Bluetooth toggle, Wi-Fi toggle, power
  profile picker (power-saver / balanced / performance), buttons to open pavucontrol,
  blueman-manager, nm-connection-editor.

## Data sources

| Data | Source | Rate |
|---|---|---|
| CPU temp | `sensors k10temp-pci-00c3` (Tctl) via `Process` | 5 s |
| GPU temp, GPU util | `nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits` | 5 s |
| NVMe temp | `sensors nvme-pci-0200` (Composite) | 10 s |
| CPU %, memory | `/proc/stat`, `/proc/meminfo` via `FileView` | 2 s |
| Volume | `Quickshell.Services.Pipewire` | events |
| Media | `Quickshell.Services.Mpris` | events |
| Battery | `Quickshell.Services.UPower` | events |
| Bluetooth | `Quickshell.Bluetooth` | events |
| Network | `Quickshell.Networking` | events |
| Workspaces | `Quickshell.Hyprland` | events |
| Tray | `Quickshell.Services.SystemTray` | events |
| Power profile | UPower `PowerProfiles` if exposed in 0.3.2, else `powerprofilesctl` via `Process` | events / 5 s |

Sensor history for sparklines (60 s) is kept in the services, not the popups, so it is
populated even when the popup was closed.

## Error handling

- A failing or unparsable sensor command sets that value to `null`; UI renders `--` in
  tertiary grey. The bar keeps running; no notifications are raised.
- Missing hardware (no battery, no Bluetooth adapter) hides that item instead of showing
  an error.
- A failing `Process` is retried on its next poll interval; no backoff needed at these rates.

## Integration

- Add `hl.exec_cmd("qs")` to `.config/hypr/hyprland.lua` alongside the existing Waybar line.
- Waybar is stopped manually during testing. Removing Waybar's autostart line (and the
  Super+Shift+W restart bind, repointed to restart `qs`) happens only after sign-off.

## Testing

- Run `qs -p ~/.config/quickshell` with Waybar stopped; compare each island to Waybar's values.
- Force failure: run with a `PATH` lacking `nvidia-smi` and confirm GPU values show `--`
  without breaking the bar.
- Check both monitors render a bar.
- Check each popup opens, closes on outside click and Escape, and only one is open at a time.

## Out of scope

Launcher, power menu, notifications, OSD, overview, lockscreen (later sub-projects).
Wallpaper (awww) and hypridle stay as they are.
