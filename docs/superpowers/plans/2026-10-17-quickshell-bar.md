# Quickshell Foundation + Bar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace Waybar with a Quickshell islands-style bar (Black & Gold theme) with calendar, sensors and quick-settings popups.

**Architecture:** `shell.qml` spawns one `Bar` per screen. Data lives in singleton services (`qs.services`), pure logic lives in plain JS libraries (`lib/*.js`, unit-tested with `qmltestrunner`), UI is small QML components (`qs.widgets`, `qs.bar.islands`, `qs.bar.popups`). All colours come from the `Theme` singleton; all glyphs from the `Icons` singleton.

**Tech Stack:** Quickshell 0.3.2 (QML / Qt 6), Qt Quick Layouts + Controls.Basic, QtTest (`/usr/lib/qt6/bin/qmltestrunner`), `sensors -j`, `nvidia-smi`, `swaync-client`.

Spec: `docs/superpowers/specs/2026-10-17-quickshell-bar-design.md`

---

## Conventions (read once)

- Config root: `/home/yanagi/dotfiles/.config/quickshell` (`~/.config` resolves into the dotfiles repo). All `cd`-relative commands below run from this directory unless they say otherwise. Git commands run from `/home/yanagi/dotfiles`.
- Imports: Quickshell exposes the config root as the `qs` module. `import qs.theme` loads `theme/*.qml`; **no qmldir files** are needed (verified on 0.3.2). JS libraries are imported by relative path, e.g. `import "../lib/format.js" as Format`.
- Singletons start with `pragma Singleton` and have `Singleton {}` as root.
- No hex colours outside `theme/Theme.qml`. No raw glyphs outside `theme/Icons.qml`.
- Pure logic goes in `lib/*.js` with `.pragma library` and gets a `tests/tst_*.qml` test. QML UI is verified by the smoke script plus a manual check step.
- `tests/run.sh [file]` runs unit tests headless. `tests/smoke.sh` launches the shell for 6 s and fails on any `WARN`/`ERROR` line. The smoke run briefly shows the bar on screen; that is expected.
- Hyprland uses the Lua config (`.config/hypr/hyprland.lua`); `hyprctl dispatch …` still works (existing binds use it).

## File map

```
.config/quickshell/
├── shell.qml                         # Variants over screens → Bar
├── theme/Theme.qml                   # palette, font, sizes, durations
├── theme/Icons.qml                   # Nerd Font glyphs by codepoint
├── lib/format.js                     # "--" for null, °, %, G, truncate, level, toPercent
├── lib/parse.js                      # sensors -j, nvidia-smi, /proc/stat, /proc/meminfo
├── lib/history.js                    # ring-buffer push, sparkline points
├── lib/workspaces.js                 # per-monitor filter + sort
├── lib/media.js                      # pick MPRIS player, icon key
├── lib/swaync.js                     # parse swaync-client -swb lines
├── lib/calendar.js                   # 6×7 month grid, month arithmetic
├── services/Sensors.qml              # temps + gpu util (+ history)
├── services/SystemStats.qml          # cpu %, mem (+ history)
├── services/PowerMode.qml            # power profile get/set/cycle
├── services/Net.qml                  # wired / wifi summary
├── services/NotifBridge.qml          # swaync status + actions (temporary)
├── services/Caffeine.qml             # idle-inhibit flag
├── widgets/StyledText.qml
├── widgets/Island.qml                # rounded pill container with click/wheel
├── widgets/Metric.qml                # icon + value, greys out when no data
├── widgets/IconButton.qml
├── widgets/Separator.qml
├── widgets/ToggleChip.qml
├── widgets/Sparkline.qml
├── widgets/BarPopup.qml              # dropdown under an island
├── bar/Bar.qml
├── bar/islands/{Workspaces,Media,Clock,System,Status,Toggles,Tray}Island.qml
├── bar/popups/{Calendar,Sensors,QuickSettings}Popup.qml
├── bar/popups/SensorRow.qml
└── tests/{run.sh,smoke.sh,tst_*.qml}
```

Spec deltas (decided while planning, spec updated in Task 1): no qmldir files; the power profile service is `PowerMode.qml` (a `PowerProfile` singleton would clash with UPower's `PowerProfile` enum); one `sensors -j` call every 5 s covers CPU and NVMe; extra services `Net`, `NotifBridge`, `Caffeine`; `lib/` and `tests/` directories added.

---

### Task 1: Scaffold, theme, test harness

**Files:**
- Create: `tests/run.sh`, `tests/smoke.sh`, `theme/Theme.qml`, `theme/Icons.qml`, `shell.qml`, `bar/Bar.qml`
- Modify: `/home/yanagi/dotfiles/docs/superpowers/specs/2026-10-17-quickshell-bar-design.md`

- [ ] **Step 1: Create the config dir and test runner**

```bash
mkdir -p /home/yanagi/dotfiles/.config/quickshell/{theme,lib,services,widgets,bar/islands,bar/popups,tests}
cd /home/yanagi/dotfiles/.config/quickshell
```

`tests/run.sh`:

```sh
#!/bin/sh
# Run QML unit tests headless. Optional arg: a single tst_*.qml file.
here="$(cd "$(dirname "$0")" && pwd)"
QT_QPA_PLATFORM=offscreen exec /usr/lib/qt6/bin/qmltestrunner -input "${1:-$here}"
```

`tests/smoke.sh`:

```sh
#!/bin/sh
# Launch the shell for a few seconds; fail on any warning/error or if config never loads.
dir="$(cd "$(dirname "$0")/.." && pwd)"
out="$(timeout 6 qs -p "$dir" --no-color 2>&1)"
if echo "$out" | grep -E 'WARN|ERROR'; then
  echo "smoke FAILED"
  exit 1
fi
echo "$out" | grep -q 'Configuration Loaded' || { echo "$out"; echo "smoke FAILED"; exit 1; }
echo "smoke ok"
```

```bash
chmod +x tests/run.sh tests/smoke.sh
```

- [ ] **Step 2: Theme singleton**

`theme/Theme.qml`:

```qml
pragma Singleton
import Quickshell
import QtQuick

// Black & Gold palette (see CLAUDE.md). The only place hex colours may appear.
Singleton {
    // Backgrounds
    readonly property color base: "#222222"
    readonly property color surface: "#2A2A2A"
    readonly property color elevated: "#333333"
    readonly property color border: "#3D3D3D"

    // Accents
    readonly property color gold: "#FFD700"
    readonly property color goldDim: "#C9A800"
    readonly property color teal: "#4DD9C0"
    readonly property color tealDim: "#2AA38E"

    // Text
    readonly property color textPrimary: "#F5F5F5"
    readonly property color textSecondary: "#BBBBBB"
    readonly property color textTertiary: "#777777"

    // Semantic
    readonly property color error: "#FF5555"
    readonly property color warning: "#FFB86C"

    // Type
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11

    // Geometry
    readonly property int barHeight: 34
    readonly property int islandHeight: 26
    readonly property int radius: 13
    readonly property int radiusPopup: 12
    readonly property int spacing: 8
    readonly property int padding: 10

    // Motion
    readonly property int animFast: 150
}
```

- [ ] **Step 3: Icons singleton**

Codepoints are copied from the current Waybar config and `power-profile.sh`, plus `wifiOff` (md-wifi_off) and `bluetoothOff` (md-bluetooth_off).

`theme/Icons.qml`:

```qml
pragma Singleton
import Quickshell
import QtQuick

// Nerd Font glyphs, by codepoint so the source stays readable.
Singleton {
    function g(cp) { return String.fromCodePoint(cp) }

    readonly property string clock: g(0xF017)
    readonly property string cpuTemp: g(0xF2DB)
    readonly property string cpu: g(0xF2DB)
    readonly property string gpu: g(0xF11B)
    readonly property string nvme: g(0xF0A0)
    readonly property string memory: g(0xF035B)

    readonly property string volumeLow: g(0xF026)
    readonly property string volumeMid: g(0xF027)
    readonly property string volumeHigh: g(0xF028)
    readonly property string volumeMuted: g(0xF0581)

    readonly property string bluetooth: g(0xF294)
    readonly property string bluetoothOff: g(0xF00B2)
    readonly property string wifi: g(0xF1EB)
    readonly property string wifiOff: g(0xF092E)
    readonly property string ethernet: g(0xF0200)

    readonly property string batteryCharging: g(0xF0084)
    readonly property string batteryPlugged: g(0xF06A5)
    // empty → full
    readonly property var battery: [g(0xF007A), g(0xF007B), g(0xF007C), g(0xF007D), g(0xF007E),
                                    g(0xF007F), g(0xF0080), g(0xF0081), g(0xF0082), g(0xF0079)]

    readonly property string bell: g(0xF009A)       // unread
    readonly property string bellIdle: g(0xF009C)   // nothing new
    readonly property string bellDnd: g(0xF009B)

    readonly property string caffeineOn: g(0xF0F4)
    readonly property string caffeineOff: g(0xF2FE)

    readonly property string powerSaver: g(0xF0F86)
    readonly property string balanced: g(0xF0F85)
    readonly property string performance: g(0xF140B)

    readonly property string play: "▶"
    readonly property string pause: g(0xF04C)
    readonly property string spotify: g(0xF1BC)
    readonly property string firefox: g(0xF0239)
}
```

- [ ] **Step 4: Entry point and empty bar**

`shell.qml`:

```qml
import Quickshell
import QtQuick
import qs.bar

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
}
```

`bar/Bar.qml`:

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme

PanelWindow {
    id: panel
    required property ShellScreen modelData

    // Name of the open popup ("" = none). Owned here so only one is open at a time.
    property string openPopup: ""
    function toggle(name) { openPopup = openPopup === name ? "" : name }

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: "transparent"

    RowLayout {
        id: leftGroup
        anchors { left: parent.left; leftMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing
    }

    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: Theme.spacing
    }

    RowLayout {
        id: rightGroup
        anchors { right: parent.right; rightMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing
    }
}
```

- [ ] **Step 5: Smoke test**

Run: `tests/smoke.sh`
Expected: `smoke ok`

- [ ] **Step 6: Update the spec with the planning deltas**

In `docs/superpowers/specs/2026-10-17-quickshell-bar-design.md`:
- In the Architecture tree, delete both `qmldir` lines, rename `PowerProfile.qml` to `PowerMode.qml`, and add `services/Net.qml`, `services/NotifBridge.qml`, `services/Caffeine.qml`, a `lib/` entry ("pure JS logic, unit-tested") and a `tests/` entry.
- In Data sources, replace the CPU temp and NVMe rows with one row: `CPU + NVMe temp | sensors -j (k10temp Tctl, nvme Composite) via Process | 5 s`.

- [ ] **Step 7: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell docs/superpowers/specs/2026-10-17-quickshell-bar-design.md
git commit -m "Scaffold Quickshell config with theme, icons and test harness

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 2: lib/format.js

**Files:**
- Create: `lib/format.js`
- Test: `tests/tst_format.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_format.qml`:

```qml
import QtQuick
import QtTest
import "../lib/format.js" as Format

TestCase {
    name: "Format"

    function test_temp() {
        compare(Format.temp(47.375), "47°")
        compare(Format.temp(null), "--")
    }
    function test_percent() {
        compare(Format.percent(8.4), "8%")
        compare(Format.percent(undefined), "--")
    }
    function test_gib() {
        compare(Format.gib(3.456), "3.5G")
        compare(Format.gib(null), "--")
    }
    function test_truncate() {
        compare(Format.truncate("abc", 30), "abc")
        compare(Format.truncate("abcdef", 4), "abc…")
    }
    function test_level() {
        const l = ["a", "b", "c"]
        compare(Format.level(l, 0), "a")
        compare(Format.level(l, 0.5), "b")
        compare(Format.level(l, 1), "c")
        compare(Format.level(l, 1.5), "c")
    }
    function test_toPercent() {
        compare(Format.toPercent(0.62), 62)
        compare(Format.toPercent(62), 62)
        compare(Format.toPercent(null), null)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_format.qml`
Expected: error, `format.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/format.js`:

```js
.pragma library
// Display helpers. null/undefined means "no reading" and renders as "--".

function temp(v) { return v == null ? "--" : Math.round(v) + "°" }

function percent(v) { return v == null ? "--" : Math.round(v) + "%" }

function gib(v) { return v == null ? "--" : v.toFixed(1) + "G" }

function truncate(s, max) { return s.length <= max ? s : s.slice(0, max - 1) + "…" }

// Pick an entry from an ordered icon list using a 0..1 fraction (volume, battery).
function level(list, fraction) {
    const i = Math.floor(Math.max(0, Math.min(1, fraction)) * list.length)
    return list[Math.min(i, list.length - 1)]
}

// Some APIs report 0..1, others 0..100; normalise to 0..100.
function toPercent(v) { return v == null ? null : (v <= 1 ? v * 100 : v) }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_format.qml`
Expected: `Totals: 8 passed, 0 failed` (6 tests + init/cleanup)

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/format.js .config/quickshell/tests/tst_format.qml
git commit -m "Add Quickshell display format helpers

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 3: lib/parse.js

**Files:**
- Create: `lib/parse.js`
- Test: `tests/tst_parse.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_parse.qml`:

```qml
import QtQuick
import QtTest
import "../lib/parse.js" as Parse

TestCase {
    name: "Parse"

    readonly property string sensorsJson: '{"k10temp-pci-00c3":{"Adapter":"PCI adapter","Tctl":{"temp1_input":47.375}},'
        + '"nvme-pci-0200":{"Adapter":"PCI adapter","Composite":{"temp1_input":39.85,"temp1_max":80.85}}}'

    function test_sensors() {
        compare(Parse.parseSensors(sensorsJson), { cpu: 47.375, nvme: 39.85 })
    }
    function test_sensors_garbage() {
        compare(Parse.parseSensors("not json"), { cpu: null, nvme: null })
        compare(Parse.parseSensors("{}"), { cpu: null, nvme: null })
    }
    function test_nvidia() {
        compare(Parse.parseNvidia("34, 0\n"), { temp: 34, util: 0 })
        compare(Parse.parseNvidia(""), { temp: null, util: null })
        compare(Parse.parseNvidia("[N/A], 5"), { temp: null, util: 5 })
    }
    function test_cpuTimes() {
        compare(Parse.parseCpuTimes("cpu  100 0 50 800 50 0 0 0 0 0\ncpu0 1 2 3 4\n"), { idle: 850, total: 1000 })
        compare(Parse.parseCpuTimes("nope"), null)
    }
    function test_cpuUsage() {
        compare(Parse.cpuUsage({ idle: 850, total: 1000 }, { idle: 900, total: 1100 }), 50)
        compare(Parse.cpuUsage(null, { idle: 1, total: 2 }), null)
        compare(Parse.cpuUsage({ idle: 1, total: 2 }, { idle: 1, total: 2 }), null)
    }
    function test_memUsed() {
        compare(Parse.parseMemUsedGiB("MemTotal:  4194304 kB\nMemFree: 1 kB\nMemAvailable:  1048576 kB\n"), 3)
        compare(Parse.parseMemUsedGiB("MemTotal: 1 kB\n"), null)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_parse.qml`
Expected: error, `parse.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/parse.js`:

```js
.pragma library
// Parsers for command / procfs output. Every function returns null for missing or bad data.

// `sensors -j` → { cpu, nvme } in °C
function parseSensors(text) {
    let data
    try { data = JSON.parse(text) } catch (e) { return { cpu: null, nvme: null } }
    return {
        cpu: readInput(data, "k10temp-pci-00c3", "Tctl"),
        nvme: readInput(data, "nvme-pci-0200", "Composite"),
    }
}

function readInput(data, chip, label) {
    const entry = data && data[chip] && data[chip][label]
    if (!entry) return null
    for (const key in entry)
        if (key.endsWith("_input")) return entry[key]
    return null
}

// `nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits` → { temp, util }
function parseNvidia(text) {
    const parts = text.trim().split(",").map(s => s.trim())
    const num = s => (s !== undefined && /^\d+(\.\d+)?$/.test(s)) ? Number(s) : null
    return { temp: num(parts[0]), util: num(parts[1]) }
}

// First line of /proc/stat → { idle, total } jiffies
function parseCpuTimes(text) {
    const line = text.split("\n")[0]
    if (!line.startsWith("cpu ")) return null
    const v = line.trim().split(/\s+/).slice(1).map(Number)
    if (v.length < 4 || v.some(isNaN)) return null
    return { idle: v[3] + (v[4] || 0), total: v.reduce((a, b) => a + b, 0) }
}

// Two /proc/stat samples → usage 0..100
function cpuUsage(prev, cur) {
    if (!prev || !cur) return null
    const dt = cur.total - prev.total
    if (dt <= 0) return null
    return Math.round(100 * (1 - (cur.idle - prev.idle) / dt))
}

// /proc/meminfo → used GiB (MemTotal - MemAvailable, same as Waybar)
function parseMemUsedGiB(text) {
    const kb = key => {
        const m = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"))
        return m ? Number(m[1]) : null
    }
    const total = kb("MemTotal"), avail = kb("MemAvailable")
    if (total === null || avail === null) return null
    return (total - avail) / 1048576
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_parse.qml`
Expected: `Totals: 8 passed, 0 failed`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/parse.js .config/quickshell/tests/tst_parse.qml
git commit -m "Add sensor and procfs parsers for Quickshell

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 4: lib/history.js

**Files:**
- Create: `lib/history.js`
- Test: `tests/tst_history.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_history.qml`:

```qml
import QtQuick
import QtTest
import "../lib/history.js" as History

TestCase {
    name: "History"

    function test_push() {
        compare(History.push([1, 2], 3, 3), [1, 2, 3])
        compare(History.push([1, 2, 3], 4, 3), [2, 3, 4])
        const src = [1]
        History.push(src, 2, 3)
        compare(src, [1])
    }
    function test_points_empty() {
        compare(History.points([], 100, 20, 5), [])
        compare(History.points([null], 100, 20, 5), [])
    }
    function test_points_scaled() {
        compare(History.points([10, 20], 100, 20, 5), [{ x: 75, y: 18 }, { x: 100, y: 2 }])
    }
    function test_points_flat() {
        compare(History.points([5, 5], 100, 20, 5), [{ x: 75, y: 10 }, { x: 100, y: 10 }])
    }
    function test_points_skip_null() {
        compare(History.points([10, null, 20], 100, 20, 3), [{ x: 0, y: 18 }, { x: 100, y: 2 }])
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_history.qml`
Expected: error, `history.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/history.js`:

```js
.pragma library

// Append and keep the last `max` items. Returns a new array so QML bindings notice.
function push(arr, value, max) {
    const out = arr.concat([value])
    return out.length > max ? out.slice(out.length - max) : out
}

// Map samples to sparkline coordinates. Newest sample sits at the right edge;
// x spacing is fixed by `capacity` so the line grows in from the right. nulls are skipped.
function points(values, width, height, capacity) {
    const pad = 2
    const nums = values.filter(v => v != null)
    if (nums.length === 0) return []
    const min = Math.min.apply(null, nums)
    const max = Math.max.apply(null, nums)
    const step = capacity > 1 ? width / (capacity - 1) : 0
    const out = []
    values.forEach((v, i) => {
        if (v == null) return
        const x = width - (values.length - 1 - i) * step
        const y = max === min ? height / 2 : pad + (1 - (v - min) / (max - min)) * (height - 2 * pad)
        out.push({ x: x, y: y })
    })
    return out
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_history.qml`
Expected: `Totals: 7 passed, 0 failed`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/history.js .config/quickshell/tests/tst_history.qml
git commit -m "Add history buffer and sparkline point helpers

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Sensors and SystemStats services

**Files:**
- Create: `services/Sensors.qml`, `services/SystemStats.qml`
- Modify: `shell.qml` (temporary debug log, removed in Step 4)

- [ ] **Step 1: Sensors service**

`services/Sensors.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/parse.js" as Parse
import "../lib/history.js" as History

// Temperatures and GPU load. null = no reading (command failed or unparsable).
Singleton {
    id: root

    readonly property int historyLength: 12   // 60 s at 5 s

    property var cpuTemp: null
    property var nvmeTemp: null
    property var gpuTemp: null
    property var gpuUtil: null

    property var cpuTempHistory: []
    property var nvmeTempHistory: []
    property var gpuTempHistory: []
    property var gpuUtilHistory: []

    Process {
        id: sensorsProc
        command: ["sensors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = Parse.parseSensors(text)
                root.cpuTemp = r.cpu
                root.nvmeTemp = r.nvme
                root.cpuTempHistory = History.push(root.cpuTempHistory, r.cpu, root.historyLength)
                root.nvmeTempHistory = History.push(root.nvmeTempHistory, r.nvme, root.historyLength)
            }
        }
        onExited: code => { if (code !== 0) { root.cpuTemp = null; root.nvmeTemp = null } }
    }

    Process {
        id: nvidiaProc
        command: ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = Parse.parseNvidia(text)
                root.gpuTemp = r.temp
                root.gpuUtil = r.util
                root.gpuTempHistory = History.push(root.gpuTempHistory, r.temp, root.historyLength)
                root.gpuUtilHistory = History.push(root.gpuUtilHistory, r.util, root.historyLength)
            }
        }
        onExited: code => { if (code !== 0) { root.gpuTemp = null; root.gpuUtil = null } }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sensorsProc.running = true
            nvidiaProc.running = true
        }
    }
}
```

- [ ] **Step 2: SystemStats service**

`services/SystemStats.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/parse.js" as Parse
import "../lib/history.js" as History

// CPU usage and memory from procfs.
Singleton {
    id: root

    readonly property int historyLength: 30   // 60 s at 2 s

    property var cpuUsage: null
    property var memUsedGiB: null
    property var cpuHistory: []
    property var memHistory: []

    property var lastCpuTimes: null

    FileView { id: statFile; path: "/proc/stat"; blockLoading: true }
    FileView { id: memFile; path: "/proc/meminfo"; blockLoading: true }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
            const times = Parse.parseCpuTimes(statFile.text())
            root.cpuUsage = Parse.cpuUsage(root.lastCpuTimes, times)
            root.lastCpuTimes = times
            root.memUsedGiB = Parse.parseMemUsedGiB(memFile.text())
            root.cpuHistory = History.push(root.cpuHistory, root.cpuUsage, root.historyLength)
            root.memHistory = History.push(root.memHistory, root.memUsedGiB, root.historyLength)
        }
    }
}
```

- [ ] **Step 3: Verify values with a temporary log**

Temporarily replace `shell.qml` with:

```qml
import Quickshell
import QtQuick
import qs.bar
import qs.services

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    Timer {
        interval: 5500; running: true
        onTriggered: console.log("DEBUG", Sensors.cpuTemp, Sensors.gpuTemp, Sensors.nvmeTemp, Sensors.gpuUtil,
                                 SystemStats.cpuUsage, SystemStats.memUsedGiB)
    }
}
```

Run: `timeout 7 qs -p . --no-color 2>&1 | grep DEBUG`
Expected: one line of six numbers, e.g. `DEBUG 47.375 34 39.85 0 6 3.4`, no `null`. Compare against `sensors` and `nvidia-smi` output.

- [ ] **Step 4: Restore shell.qml and smoke test**

Put `shell.qml` back to the Task 1 version (remove the `qs.services` import and the debug `Timer`).

Run: `tests/smoke.sh`
Expected: `smoke ok`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/services
git commit -m "Add sensors and system stats services

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Base widgets

**Files:**
- Create: `widgets/StyledText.qml`, `widgets/Island.qml`, `widgets/Metric.qml`, `widgets/IconButton.qml`, `widgets/Separator.qml`, `widgets/ToggleChip.qml`

- [ ] **Step 1: Write the widgets**

`widgets/StyledText.qml`:

```qml
import QtQuick
import qs.theme

Text {
    color: Theme.textPrimary
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    verticalAlignment: Text.AlignVCenter
}
```

`widgets/Island.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.theme

// Rounded pill holding a row of children. Children with their own MouseArea
// (declared later, so on top) take clicks first; everything else hits the island.
Rectangle {
    id: root
    default property alias content: row.data
    property bool hoverable: true
    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: row.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.islandHeight
    radius: Theme.radius
    color: area.containsMouse && hoverable ? Theme.elevated : Theme.surface
    border.color: Theme.border
    border.width: 1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: m => root.clicked(m)
        onWheel: w => root.wheel(w)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing
    }
}
```

`widgets/Metric.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.theme

// Icon + value. Greys out when `ok` is false (no reading).
RowLayout {
    id: root
    property string icon
    property string text
    property bool ok: true
    property color accent: Theme.textSecondary

    spacing: 4

    StyledText {
        text: root.icon
        color: root.ok ? root.accent : Theme.textTertiary
    }
    StyledText {
        visible: root.text !== ""
        text: root.text
        color: root.ok ? Theme.textPrimary : Theme.textTertiary
    }
}
```

`widgets/IconButton.qml`:

```qml
import QtQuick
import qs.theme

// Clickable glyph that turns gold on hover.
StyledText {
    id: root
    property color baseColor: Theme.textSecondary
    signal clicked(var mouse)

    color: area.containsMouse ? Theme.gold : baseColor

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => root.clicked(m)
    }
}
```

`widgets/Separator.qml`:

```qml
import QtQuick
import qs.theme

Rectangle {
    implicitWidth: 1
    implicitHeight: 14
    color: Theme.border
}
```

`widgets/ToggleChip.qml`:

```qml
import QtQuick
import qs.theme

// Rounded button; gold fill when checked.
Rectangle {
    id: root
    property string text
    property bool checked: false
    signal clicked()

    implicitWidth: label.implicitWidth + Theme.padding * 2
    implicitHeight: 28
    radius: 14
    color: checked ? Theme.gold : area.containsMouse ? Theme.elevated : Theme.base
    border.color: checked ? Theme.gold : Theme.border
    border.width: 1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.checked ? Theme.base : Theme.textPrimary
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
```

- [ ] **Step 2: Smoke test**

Run: `tests/smoke.sh`
Expected: `smoke ok` (widgets are not instantiated yet; this only proves nothing else broke)

- [ ] **Step 3: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/widgets
git commit -m "Add base Quickshell widgets

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 7: Workspaces island

**Files:**
- Create: `lib/workspaces.js`, `bar/islands/WorkspacesIsland.qml`
- Test: `tests/tst_workspaces.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_workspaces.qml`:

```qml
import QtQuick
import QtTest
import "../lib/workspaces.js" as WS

TestCase {
    name: "Workspaces"

    function mon(n) { return { name: n } }

    function test_filter_and_sort() {
        const list = [
            { id: 3, monitor: mon("A") },
            { id: -98, monitor: mon("A") },
            { id: 1, monitor: mon("A") },
            { id: 2, monitor: mon("B") },
        ]
        compare(WS.visible(list, "A").map(w => w.id), [1, 3, -98])
    }
    function test_no_monitor() {
        compare(WS.visible([{ id: 1, monitor: null }], "A"), [])
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_workspaces.qml`
Expected: error, `workspaces.js` cannot be loaded

- [ ] **Step 3: Implement the lib**

`lib/workspaces.js`:

```js
.pragma library

// Workspaces on one monitor: normal ones by id, special ones (negative id) last.
function visible(list, monitorName) {
    return list
        .filter(w => w.monitor && w.monitor.name === monitorName)
        .sort((a, b) => {
            const sa = a.id < 0, sb = b.id < 0
            if (sa !== sb) return sa ? 1 : -1
            return a.id - b.id
        })
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_workspaces.qml`
Expected: `Totals: 4 passed, 0 failed`

- [ ] **Step 5: Island**

`bar/islands/WorkspacesIsland.qml`:

```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.theme
import qs.widgets
import "../../lib/workspaces.js" as WS

// Dots per workspace; the active one stretches into a gold pill.
Island {
    id: root
    required property string screenName

    hoverable: false
    onWheel: w => Quickshell.execDetached(["hyprctl", "dispatch", "workspace", w.angleDelta.y > 0 ? "m-1" : "m+1"])

    Repeater {
        model: WS.visible(Hyprland.workspaces.values, root.screenName)

        delegate: Rectangle {
            id: dot
            required property var modelData
            readonly property bool special: modelData.id < 0

            implicitWidth: modelData.active ? 22 : 8
            implicitHeight: 8
            radius: 4
            color: modelData.active ? Theme.gold
                 : modelData.urgent ? Theme.warning
                 : special ? Theme.tealDim
                 : dotArea.containsMouse ? Theme.textSecondary
                 : Theme.textTertiary
            Behavior on implicitWidth { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: Theme.animFast } }

            MouseArea {
                id: dotArea
                anchors.fill: parent
                anchors.margins: -4
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: dot.modelData.activate()
            }
        }
    }
}
```

- [ ] **Step 6: Add to bar**

In `bar/Bar.qml`, add `import qs.bar.islands` after `import qs.theme`, and put the island inside `leftGroup`:

```qml
    RowLayout {
        id: leftGroup
        anchors { left: parent.left; leftMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing

        WorkspacesIsland { screenName: panel.screen.name }
    }
```

- [ ] **Step 7: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: `pkill waybar; qs -p .` then switch workspaces with your binds, click a dot, scroll over the island, open a special workspace. Active pill moves and animates; special workspace dot is teal. Ctrl+C, then `waybar &disown` to restore.

- [ ] **Step 8: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add workspaces island to Quickshell bar

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 8: Media island

**Files:**
- Create: `lib/media.js`, `bar/islands/MediaIsland.qml`
- Test: `tests/tst_media.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_media.qml`:

```qml
import QtQuick
import QtTest
import "../lib/media.js" as Media

TestCase {
    name: "Media"

    function p(name, playing, entry) {
        return { dbusName: "org.mpris.MediaPlayer2." + name, isPlaying: playing, desktopEntry: entry || "", identity: name }
    }

    function test_pick_prefers_playing() {
        const a = p("firefox", false), b = p("spotify", true)
        compare(Media.pick([a, b]), b)
    }
    function test_pick_ignores_playerctld() {
        const ctl = p("playerctld", true), a = p("mpv", false)
        compare(Media.pick([ctl, a]), a)
        compare(Media.pick([ctl]), null)
        compare(Media.pick([]), null)
    }
    function test_iconKey() {
        compare(Media.iconKey(p("spotify", true, "spotify")), "spotify")
        compare(Media.iconKey(p("Mozilla Firefox", true, "firefox")), "firefox")
        compare(Media.iconKey(p("mpv", true)), "play")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_media.qml`
Expected: error, `media.js` cannot be loaded

- [ ] **Step 3: Implement the lib**

`lib/media.js`:

```js
.pragma library

// Which MPRIS player the bar shows: a playing one first, else the first real one.
function pick(players) {
    const real = players.filter(p => p.dbusName.indexOf("playerctld") === -1)
    return real.find(p => p.isPlaying) || real[0] || null
}

// Icons key for a player ("spotify" | "firefox" | "play").
function iconKey(player) {
    const id = ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase()
    if (id.indexOf("spotify") !== -1) return "spotify"
    if (id.indexOf("firefox") !== -1) return "firefox"
    return "play"
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_media.qml`
Expected: `Totals: 5 passed, 0 failed`

- [ ] **Step 5: Island**

`bar/islands/MediaIsland.qml`:

```qml
import Quickshell.Services.Mpris
import QtQuick
import qs.theme
import qs.widgets
import "../../lib/media.js" as Media
import "../../lib/format.js" as Format

// Current track. Click: play/pause. Right click: next.
Island {
    id: root
    readonly property var player: Media.pick(Mpris.players.values)

    visible: player !== null && player.trackTitle !== ""
    onClicked: m => m.button === Qt.RightButton ? player.next() : player.togglePlaying()

    StyledText {
        text: root.player && root.player.isPlaying ? Icons[Media.iconKey(root.player)] : Icons.pause
        color: Theme.gold
    }
    StyledText {
        text: root.player ? Format.truncate(root.player.trackTitle, 30) : ""
        font.italic: root.player !== null && !root.player.isPlaying
        color: Theme.textSecondary
    }
}
```

- [ ] **Step 6: Add to bar**

In `bar/Bar.qml` `leftGroup`, after `WorkspacesIsland`:

```qml
        MediaIsland {}
```

- [ ] **Step 7: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual (Waybar stopped, `qs -p .`): play something in Spotify/Firefox → island appears with title; pause → pause icon + italic; left click toggles; right click skips; close player → island disappears.

- [ ] **Step 8: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add media island to Quickshell bar

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 9: Clock island

**Files:**
- Create: `bar/islands/ClockIsland.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Island**

`bar/islands/ClockIsland.qml`:

```qml
import Quickshell
import QtQuick
import qs.theme
import qs.widgets

Island {
    SystemClock { id: clock; precision: SystemClock.Minutes }

    StyledText { text: Icons.clock; color: Theme.gold }
    StyledText {
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.gold
        font.bold: true
    }
}
```

- [ ] **Step 2: Add to bar**

In `bar/Bar.qml` `centerGroup`:

```qml
    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: Theme.spacing

        ClockIsland { id: clockIsland; onClicked: panel.toggle("calendar") }
    }
```

- [ ] **Step 3: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`. Manual: clock centred, gold, matches `date +%H:%M`.

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add clock island to Quickshell bar

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 10: System island

**Files:**
- Create: `bar/islands/SystemIsland.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Island**

`bar/islands/SystemIsland.qml`:

```qml
import QtQuick
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

// Temps (teal) | usage. Click opens the sensors popup (wired in Bar).
Island {
    Metric { icon: Icons.cpuTemp; text: Format.temp(Sensors.cpuTemp); ok: Sensors.cpuTemp !== null; accent: Theme.teal }
    Metric { icon: Icons.gpu; text: Format.temp(Sensors.gpuTemp); ok: Sensors.gpuTemp !== null; accent: Theme.teal }
    Metric { icon: Icons.nvme; text: Format.temp(Sensors.nvmeTemp); ok: Sensors.nvmeTemp !== null; accent: Theme.teal }
    Separator {}
    Metric { icon: Icons.cpu; text: Format.percent(SystemStats.cpuUsage); ok: SystemStats.cpuUsage !== null }
    Metric { icon: Icons.gpu; text: Format.percent(Sensors.gpuUtil); ok: Sensors.gpuUtil !== null }
    Metric { icon: Icons.memory; text: Format.gib(SystemStats.memUsedGiB); ok: SystemStats.memUsedGiB !== null }
}
```

- [ ] **Step 2: Add to bar**

In `bar/Bar.qml` `rightGroup`:

```qml
    RowLayout {
        id: rightGroup
        anchors { right: parent.right; rightMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing

        SystemIsland { id: systemIsland; onClicked: panel.toggle("sensors") }
    }
```

- [ ] **Step 3: Smoke + manual check, including failure mode**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: values match Waybar (run `waybar` briefly side by side or compare with `sensors` / `nvidia-smi`).
Failure mode:

```bash
mkdir -p /tmp/claude-1000/nonvidia && for b in qs sensors hyprctl swaync-client; do ln -sf "$(command -v $b)" /tmp/claude-1000/nonvidia/; done
env PATH=/tmp/claude-1000/nonvidia timeout 8 qs -p . --no-color
```

Expected: bar runs, GPU temp and GPU % show `--` in grey, CPU/NVMe temps still show numbers. Then `rm -r /tmp/claude-1000/nonvidia`.

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add system island to Quickshell bar

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 11: Status island + Net service

**Files:**
- Create: `services/Net.qml`, `bar/islands/StatusIsland.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Net service**

`services/Net.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick
import "../lib/format.js" as Format

// What the bar needs from Networking: wired > wifi > none.
Singleton {
    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice ? (wifiDevice.networks.values.find(n => n.connected) ?? null) : null

    readonly property string kind: wired ? "wired" : wifiNetwork ? "wifi" : "none"
    readonly property var strength: wifiNetwork ? Format.toPercent(wifiNetwork.signalStrength) : null
    readonly property string ssid: wifiNetwork ? wifiNetwork.name : ""
}
```

- [ ] **Step 2: Island**

`bar/islands/StatusIsland.qml`:

```qml
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

// Volume, Bluetooth, network, battery. Click opens quick settings (wired in Bar).
Island {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var battery: UPower.displayDevice
    readonly property var batteryPct: Format.toPercent(battery.percentage)

    // audio properties are only valid on tracked nodes
    PwObjectTracker { objects: [root.sink] }

    Metric {
        ok: root.audio !== null
        icon: !root.audio || root.audio.muted ? Icons.volumeMuted
            : Format.level([Icons.volumeLow, Icons.volumeMid, Icons.volumeHigh], root.audio.volume)
        text: !root.audio ? "--" : root.audio.muted ? "muted" : Format.percent(root.audio.volume * 100)
    }

    Metric {
        visible: root.adapter !== null
        icon: root.adapter && root.adapter.enabled ? Icons.bluetooth : Icons.bluetoothOff
        text: !root.adapter || !root.adapter.enabled ? "off"
            : String(root.adapter.devices.values.filter(d => d.connected).length)
    }

    Metric {
        ok: Net.kind !== "none"
        icon: Net.kind === "wired" ? Icons.ethernet : Net.kind === "wifi" ? Icons.wifi : Icons.wifiOff
        text: Net.kind === "wifi" ? Format.percent(Net.strength) : ""
    }

    Metric {
        visible: root.battery.isLaptopBattery
        accent: root.batteryPct <= 15 ? Theme.error : root.batteryPct <= 30 ? Theme.warning : Theme.textSecondary
        icon: root.battery.state === UPowerDeviceState.Charging ? Icons.batteryCharging
            : root.battery.state === UPowerDeviceState.FullyCharged ? Icons.batteryPlugged
            : Format.level(Icons.battery, root.batteryPct / 100)
        text: Format.percent(root.batteryPct)
    }
}
```

- [ ] **Step 3: Add to bar**

In `bar/Bar.qml` `rightGroup`, after `SystemIsland`:

```qml
        StatusIsland { id: statusIsland; onClicked: panel.toggle("quick") }
```

- [ ] **Step 4: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: change volume with media keys → number updates; mute → `muted`; toggle Bluetooth with `bluetoothctl power off/on` → `off` / count; network icon matches connection (ethernet icon on wired). If on Wi-Fi, strength is 0–100 (if it shows 0–1 values, `toPercent` handles it — confirm the number looks like Waybar's). Battery hidden on this desktop.

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add status island and network service

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 12: Toggles island (power profile, notifications bell, caffeine)

**Files:**
- Create: `lib/swaync.js`, `services/NotifBridge.qml`, `services/PowerMode.qml`, `services/Caffeine.qml`, `bar/islands/TogglesIsland.qml`
- Test: `tests/tst_swaync.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_swaync.qml`:

```qml
import QtQuick
import QtTest
import "../lib/swaync.js" as SwayncParse

TestCase {
    name: "Swaync"

    function test_states() {
        compare(SwayncParse.parseStatus('{"text":"1","alt":"notification","class":["notification"]}'), { unread: true, dnd: false })
        compare(SwayncParse.parseStatus('{"text":"0","alt":"none"}'), { unread: false, dnd: false })
        compare(SwayncParse.parseStatus('{"alt":"dnd-notification"}'), { unread: true, dnd: true })
        compare(SwayncParse.parseStatus('{"alt":"dnd-none"}'), { unread: false, dnd: true })
        compare(SwayncParse.parseStatus('{"alt":"inhibited-notification"}'), { unread: true, dnd: false })
    }
    function test_bad() {
        compare(SwayncParse.parseStatus("garbage"), null)
        compare(SwayncParse.parseStatus('{"text":"x"}'), null)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_swaync.qml`
Expected: error, `swaync.js` cannot be loaded

- [ ] **Step 3: Implement the lib**

`lib/swaync.js`:

```js
.pragma library

// One line of `swaync-client -swb` → { unread, dnd }, or null if unparsable.
function parseStatus(line) {
    let o
    try { o = JSON.parse(line) } catch (e) { return null }
    if (!o || typeof o.alt !== "string") return null
    return { unread: o.alt.endsWith("notification"), dnd: o.alt.indexOf("dnd") !== -1 }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_swaync.qml`
Expected: `Totals: 4 passed, 0 failed`

- [ ] **Step 5: Services**

`services/NotifBridge.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/swaync.js" as SwayncParse

// Temporary bridge to swaync; replaced by the Quickshell notification server in sub-project 4.
Singleton {
    id: root
    property bool unread: false
    property bool dnd: false

    function toggleCenter() { Quickshell.execDetached(["swaync-client", "-t", "-sw"]) }
    function toggleDnd() { Quickshell.execDetached(["swaync-client", "-d", "-sw"]) }

    Process {
        id: watcher
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const s = SwayncParse.parseStatus(line)
                if (s) { root.unread = s.unread; root.dnd = s.dnd }
            }
        }
        // swaync restarts or isn't up yet: try again shortly
        onRunningChanged: if (!running) restart.start()
    }

    Timer { id: restart; interval: 3000; onTriggered: watcher.running = true }
}
```

`services/PowerMode.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import qs.theme

// power-profiles-daemon via UPower's PowerProfiles.
Singleton {
    readonly property var available: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]
    readonly property int current: PowerProfiles.profile

    function name(p) {
        return p === PowerProfile.PowerSaver ? "power-saver" : p === PowerProfile.Performance ? "performance" : "balanced"
    }
    function icon(p) {
        return p === PowerProfile.PowerSaver ? Icons.powerSaver : p === PowerProfile.Performance ? Icons.performance : Icons.balanced
    }
    function set(p) { PowerProfiles.profile = p }
    function cycle() {
        const i = available.indexOf(current)
        set(available[(i + 1) % available.length])
    }
}
```

`services/Caffeine.qml`:

```qml
pragma Singleton
import Quickshell
import QtQuick

// When active, every bar holds a Wayland idle inhibitor (hypridle respects it).
Singleton {
    property bool active: false
}
```

- [ ] **Step 6: Island**

`bar/islands/TogglesIsland.qml`:

```qml
import QtQuick
import qs.theme
import qs.services
import qs.widgets

Island {
    hoverable: false

    IconButton {
        text: PowerMode.icon(PowerMode.current)
        onClicked: PowerMode.cycle()
    }

    IconButton {
        text: NotifBridge.dnd ? Icons.bellDnd : NotifBridge.unread ? Icons.bell : Icons.bellIdle
        baseColor: NotifBridge.unread ? Theme.gold : Theme.textSecondary
        onClicked: m => m.button === Qt.RightButton ? NotifBridge.toggleDnd() : NotifBridge.toggleCenter()
    }

    IconButton {
        text: Caffeine.active ? Icons.caffeineOn : Icons.caffeineOff
        baseColor: Caffeine.active ? Theme.gold : Theme.textSecondary
        onClicked: Caffeine.active = !Caffeine.active
    }
}
```

- [ ] **Step 7: Add to bar + idle inhibitor**

In `bar/Bar.qml`:
- add imports `import Quickshell.Wayland` (after `import Quickshell`) and `import qs.services` (after `import qs.theme`);
- add after `color: "transparent"`:

```qml
    IdleInhibitor {
        window: panel
        enabled: Caffeine.active
    }
```

- in `rightGroup`, after `StatusIsland`:

```qml
        TogglesIsland {}
```

- [ ] **Step 8: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual:
- Click profile icon → `powerprofilesctl get` cycles power-saver → balanced → performance.
- `notify-send test` → bell turns gold; click bell → swaync panel opens; right click → DND icon.
- Click caffeine → gold; `hyprctl` idle inhibit check: leave idle past hypridle timeout, screen should not lock; click again to disable.

- [ ] **Step 9: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add toggles island with power profile, swaync bell and caffeine

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 13: Tray island

**Files:**
- Create: `bar/islands/TrayIsland.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Island**

`bar/islands/TrayIsland.qml`:

```qml
import Quickshell.Services.SystemTray
import QtQuick
import qs.theme
import qs.widgets

// Left click: activate (or menu for menu-only items). Right click: menu.
Island {
    id: root
    required property var bar

    hoverable: false
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items.values

        delegate: Image {
            id: trayIcon
            required property var modelData

            source: modelData.icon
            sourceSize: Qt.size(16, 16)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: m => {
                    const item = trayIcon.modelData
                    if (m.button === Qt.LeftButton && !item.onlyMenu) {
                        item.activate()
                        return
                    }
                    if (!item.hasMenu) return
                    const p = trayIcon.mapToItem(null, 0, trayIcon.height + 6)
                    item.display(root.bar, p.x, p.y)
                }
            }
        }
    }
}
```

- [ ] **Step 2: Add to bar**

In `bar/Bar.qml` `rightGroup`, after `TogglesIsland`:

```qml
        TrayIsland { bar: panel }
```

- [ ] **Step 3: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: tray apps (fcitx5, etc.) show icons; left click activates; right click opens menu below the icon.

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add system tray island

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 14: BarPopup + calendar popup

**Files:**
- Create: `widgets/BarPopup.qml`, `lib/calendar.js`, `bar/popups/CalendarPopup.qml`
- Test: `tests/tst_calendar.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_calendar.qml`:

```qml
import QtQuick
import QtTest
import "../lib/calendar.js" as Cal

TestCase {
    name: "Calendar"

    function test_grid_oct_2026() {
        // 1 Oct 2026 is a Thursday → 3 leading days from September (Monday-first)
        const cells = Cal.monthGrid(2026, 9, new Date(2026, 9, 17))
        compare(cells.length, 42)
        compare(cells[0], { day: 28, inMonth: false, isToday: false })
        compare(cells[3], { day: 1, inMonth: true, isToday: false })
        compare(cells[19], { day: 17, inMonth: true, isToday: true })
        compare(cells.filter(c => c.isToday).length, 1)
    }
    function test_addMonths() {
        compare(Cal.addMonths(2026, 11, 1), { year: 2027, month: 0 })
        compare(Cal.addMonths(2026, 0, -1), { year: 2025, month: 11 })
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_calendar.qml`
Expected: error, `calendar.js` cannot be loaded

- [ ] **Step 3: Implement the lib**

`lib/calendar.js`:

```js
.pragma library

// 42 cells (6 weeks, Monday first) for a month (0-based). Each: { day, inMonth, isToday }.
function monthGrid(year, month, today) {
    const offset = (new Date(year, month, 1).getDay() + 6) % 7
    const cells = []
    for (let i = 0; i < 42; i++) {
        const d = new Date(year, month, 1 - offset + i)
        cells.push({
            day: d.getDate(),
            inMonth: d.getMonth() === month,
            isToday: d.getFullYear() === today.getFullYear()
                && d.getMonth() === today.getMonth()
                && d.getDate() === today.getDate(),
        })
    }
    return cells
}

function addMonths(year, month, delta) {
    const d = new Date(year, month + delta, 1)
    return { year: d.getFullYear(), month: d.getMonth() }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_calendar.qml`
Expected: `Totals: 4 passed, 0 failed`

- [ ] **Step 5: BarPopup widget**

`widgets/BarPopup.qml`:

```qml
import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.theme

// Dropdown under a bar island. Open state lives in the bar (bar.openPopup) so only
// one popup is open at a time. Closes on outside click (focus grab) or Escape.
PopupWindow {
    id: root
    required property var bar
    required property Item anchorItem
    required property string name
    default property alias content: body.data
    readonly property bool open: bar.openPopup === name

    function close() { bar.openPopup = "" }

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.margins.top: 6
    implicitWidth: frame.implicitWidth
    implicitHeight: frame.implicitHeight
    color: "transparent"
    visible: false

    // show immediately; hide only after the fade-out finishes
    onOpenChanged: if (open) visible = true

    HyprlandFocusGrab {
        // include the bar so clicking an island toggles instead of close+reopen
        windows: [root, root.bar]
        active: root.visible
        onCleared: if (root.open) root.close()
    }

    Rectangle {
        id: frame
        implicitWidth: body.implicitWidth + Theme.padding * 2
        implicitHeight: body.implicitHeight + Theme.padding * 2
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.radiusPopup
        opacity: root.open ? 1 : 0
        y: root.open ? 0 : -8

        Behavior on y { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                onRunningChanged: if (!running && !root.open) root.visible = false
            }
        }

        Item {
            id: body
            x: Theme.padding
            y: Theme.padding
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
            focus: true
            Keys.onEscapePressed: root.close()
        }
    }
}
```

- [ ] **Step 6: Calendar popup**

`bar/popups/CalendarPopup.qml`:

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../../lib/calendar.js" as Cal

BarPopup {
    id: root
    name: "calendar"

    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()

    function shift(delta) {
        const m = Cal.addMonths(viewYear, viewMonth, delta)
        viewYear = m.year
        viewMonth = m.month
    }

    // jump back to today whenever it opens
    onOpenChanged: if (open) {
        viewYear = clock.date.getFullYear()
        viewMonth = clock.date.getMonth()
    }

    SystemClock { id: clock; precision: SystemClock.Hours }

    ColumnLayout {
        spacing: Theme.spacing

        WheelHandler { onWheel: e => root.shift(e.angleDelta.y > 0 ? -1 : 1) }

        StyledText {
            text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
            color: Theme.gold
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            IconButton { text: "‹"; onClicked: root.shift(-1) }
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
            }
            IconButton { text: "›"; onClicked: root.shift(1) }
        }

        GridLayout {
            columns: 7
            columnSpacing: 4
            rowSpacing: 4

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                StyledText {
                    required property string modelData
                    text: modelData
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 28
                }
            }

            Repeater {
                model: Cal.monthGrid(root.viewYear, root.viewMonth, clock.date)
                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 24
                    radius: 6
                    color: modelData.isToday ? Theme.gold : "transparent"

                    StyledText {
                        anchors.centerIn: parent
                        text: parent.modelData.day
                        color: parent.modelData.isToday ? Theme.base
                             : parent.modelData.inMonth ? Theme.textPrimary
                             : Theme.textTertiary
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 7: Add to bar**

In `bar/Bar.qml`, add `import qs.bar.popups` after `import qs.bar.islands`, and at the end of `PanelWindow` (after `rightGroup`):

```qml
    CalendarPopup { bar: panel; anchorItem: clockIsland }
```

- [ ] **Step 8: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual:
- Click clock → calendar fades/slides in under it, today gold.
- Scroll / click ‹ › → month changes. Close and reopen → back to current month.
- Click clock again → closes. Click on desktop/another window → closes. Press Escape while open → closes.
- If Escape does nothing, set `grabFocus: true` on the `PopupWindow` in `widgets/BarPopup.qml`, re-run this step, and note it in the commit message.

- [ ] **Step 9: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add bar popup widget and calendar popup

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 15: Sensors popup

**Files:**
- Create: `widgets/Sparkline.qml`, `bar/popups/SensorRow.qml`, `bar/popups/SensorsPopup.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Sparkline widget**

`widgets/Sparkline.qml`:

```qml
import QtQuick
import qs.theme
import "../lib/history.js" as History

Canvas {
    id: root
    property var values: []
    property int capacity: 12
    property color lineColor: Theme.teal

    implicitWidth: 140
    implicitHeight: 24

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const pts = History.points(values, width, height, capacity)
        if (pts.length < 2) return
        ctx.strokeStyle = lineColor
        ctx.lineWidth = 1.5
        ctx.beginPath()
        pts.forEach((p, i) => i === 0 ? ctx.moveTo(p.x, p.y) : ctx.lineTo(p.x, p.y))
        ctx.stroke()
    }
}
```

- [ ] **Step 2: SensorRow**

`bar/popups/SensorRow.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets

RowLayout {
    id: root
    property string label
    property string value
    property bool ok: true
    property var history: []
    property int capacity: 12
    property color lineColor: Theme.teal

    spacing: Theme.spacing

    StyledText { text: root.label; color: Theme.textSecondary; Layout.preferredWidth: 80 }
    Sparkline {
        values: root.history
        capacity: root.capacity
        lineColor: root.lineColor
        Layout.preferredWidth: 140
        Layout.preferredHeight: 24
    }
    StyledText {
        text: root.value
        color: root.ok ? Theme.textPrimary : Theme.textTertiary
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 48
    }
}
```

- [ ] **Step 3: SensorsPopup**

`bar/popups/SensorsPopup.qml`:

```qml
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

BarPopup {
    name: "sensors"

    ColumnLayout {
        spacing: 6

        StyledText { text: "Last 60 s"; color: Theme.gold; font.bold: true }

        SensorRow {
            label: "CPU temp"; value: Format.temp(Sensors.cpuTemp); ok: Sensors.cpuTemp !== null
            history: Sensors.cpuTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "GPU temp"; value: Format.temp(Sensors.gpuTemp); ok: Sensors.gpuTemp !== null
            history: Sensors.gpuTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "NVMe temp"; value: Format.temp(Sensors.nvmeTemp); ok: Sensors.nvmeTemp !== null
            history: Sensors.nvmeTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "CPU"; value: Format.percent(SystemStats.cpuUsage); ok: SystemStats.cpuUsage !== null
            history: SystemStats.cpuHistory; capacity: SystemStats.historyLength; lineColor: Theme.gold
        }
        SensorRow {
            label: "GPU"; value: Format.percent(Sensors.gpuUtil); ok: Sensors.gpuUtil !== null
            history: Sensors.gpuUtilHistory; capacity: Sensors.historyLength; lineColor: Theme.gold
        }
        SensorRow {
            label: "RAM"; value: Format.gib(SystemStats.memUsedGiB); ok: SystemStats.memUsedGiB !== null
            history: SystemStats.memHistory; capacity: SystemStats.historyLength; lineColor: Theme.gold
        }
    }
}
```

- [ ] **Step 4: Add to bar**

In `bar/Bar.qml`, after `CalendarPopup`:

```qml
    SensorsPopup { bar: panel; anchorItem: systemIsland }
```

- [ ] **Step 5: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: let the shell run ≥ 20 s, click the system island → six rows, lines drawn (teal temps, gold usage) and growing from the right; run `stress -c 4` or a game briefly → CPU line rises. Opening calendar while sensors is open closes sensors.

- [ ] **Step 6: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add sensors popup with sparklines

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 16: Quick settings popup

**Files:**
- Create: `bar/popups/QuickSettingsPopup.qml`
- Modify: `bar/Bar.qml`

- [ ] **Step 1: Popup**

`bar/popups/QuickSettingsPopup.qml`:

```qml
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

BarPopup {
    id: root
    name: "quick"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property var adapter: Bluetooth.defaultAdapter

    function launch(cmd) {
        Quickshell.execDetached(cmd)
        close()
    }

    PwObjectTracker { objects: [root.sink] }

    ColumnLayout {
        spacing: 10

        // Volume
        RowLayout {
            spacing: Theme.spacing

            IconButton {
                text: root.audio && root.audio.muted ? Icons.volumeMuted : Icons.volumeHigh
                baseColor: Theme.gold
                onClicked: if (root.audio) root.audio.muted = !root.audio.muted
            }

            Slider {
                id: volume
                Layout.preferredWidth: 220
                from: 0
                to: 1
                value: root.audio ? root.audio.volume : 0
                onMoved: if (root.audio) root.audio.volume = value

                background: Rectangle {
                    x: volume.leftPadding
                    y: volume.topPadding + volume.availableHeight / 2 - height / 2
                    width: volume.availableWidth
                    height: 4
                    radius: 2
                    color: Theme.border

                    Rectangle {
                        width: volume.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Theme.gold
                    }
                }

                handle: Rectangle {
                    x: volume.leftPadding + volume.visualPosition * (volume.availableWidth - width)
                    y: volume.topPadding + volume.availableHeight / 2 - height / 2
                    width: 14
                    height: 14
                    radius: 7
                    color: volume.pressed ? Theme.goldDim : Theme.gold
                }
            }

            StyledText {
                text: root.audio ? Format.percent(root.audio.volume * 100) : "--"
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 40
            }
        }

        // Radios
        RowLayout {
            spacing: Theme.spacing
            ToggleChip {
                visible: root.adapter !== null
                text: Icons.bluetooth + "  Bluetooth"
                checked: root.adapter ? root.adapter.enabled : false
                onClicked: root.adapter.enabled = !root.adapter.enabled
            }
            ToggleChip {
                text: Icons.wifi + "  Wi-Fi"
                checked: Networking.wifiEnabled
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        // Power profile
        StyledText { text: "Power profile"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
        RowLayout {
            spacing: Theme.spacing
            Repeater {
                model: PowerMode.available
                ToggleChip {
                    required property int modelData
                    text: PowerMode.icon(modelData) + "  " + PowerMode.name(modelData)
                    checked: PowerMode.current === modelData
                    onClicked: PowerMode.set(modelData)
                }
            }
        }

        // Full settings apps
        RowLayout {
            spacing: Theme.spacing
            ToggleChip { text: "Sound"; onClicked: root.launch(["pavucontrol"]) }
            ToggleChip { text: "Bluetooth"; onClicked: root.launch(["blueman-manager"]) }
            ToggleChip { text: "Network"; onClicked: root.launch(["nm-connection-editor"]) }
        }
    }
}
```

- [ ] **Step 2: Add to bar**

In `bar/Bar.qml`, after `SensorsPopup`:

```qml
    QuickSettingsPopup { bar: panel; anchorItem: statusIsland }
```

- [ ] **Step 3: Smoke + manual check**

Run: `tests/smoke.sh` → `smoke ok`.
Manual: click status island →
- drag slider → volume changes (`wpctl get-volume @DEFAULT_AUDIO_SINK@`), media keys move the slider; mute button works;
- Bluetooth chip toggles `bluetoothctl show | grep Powered`; Wi-Fi chip toggles `nmcli radio wifi`;
- profile chips set profile and highlight follows (also when changed via toggles island);
- Sound/Bluetooth/Network chips launch the app and close the popup.
- Popup stays on screen near the right edge (SlideX).

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell
git commit -m "Add quick settings popup

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 17: Autostart + full verification

**Files:**
- Modify: `/home/yanagi/dotfiles/.config/hypr/hyprland.lua:41`

- [ ] **Step 1: Run the whole test suite**

Run: `tests/run.sh`
Expected: `0 failed` in the totals line.

- [ ] **Step 2: Add autostart (Waybar stays)**

In `.config/hypr/hyprland.lua`, after line 41 (`hl.exec_cmd("waybar > ~/.cache/waybar.log 2>&1")`), add:

```lua
hl.exec_cmd("qs -d")
```

Both bars will start at login until sign-off; `pkill waybar` during the test period.

- [ ] **Step 3: Full manual checklist (Waybar stopped, `qs -d` running)**

Run each and confirm:
- every connected monitor has a bar (`hyprctl monitors`);
- each island matches what Waybar showed (temps, cpu, gpu, ram, volume, bt, net, profile, bell, caffeine, tray);
- each popup opens, closes on outside click, on Escape, and on second click; only one open at a time;
- `tests/smoke.sh` → `smoke ok`;
- no colours outside the palette: `grep -rn '#[0-9A-Fa-f]\{6\}' --include=*.qml . | grep -v theme/Theme.qml` → no output.

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/hypr/hyprland.lua
git commit -m "Autostart Quickshell alongside Waybar for testing

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```

---

### Task 18: Retire Waybar (ONLY after the user signs off on the bar)

**Files:**
- Modify: `/home/yanagi/dotfiles/.config/hypr/hyprland.lua:41,196`

- [ ] **Step 1: Ask the user for sign-off.** Stop here if they haven't explicitly approved.

- [ ] **Step 2: Remove Waybar autostart and repoint the restart bind**

In `.config/hypr/hyprland.lua` delete line 41 (`hl.exec_cmd("waybar > ~/.cache/waybar.log 2>&1")`) and change the `SHIFT + W` bind to:

```lua
hl.bind(mainMod .. " + SHIFT + W",         hl.dsp.exec_cmd("qs kill; qs -d"))
```

Leave `.config/waybar/` in the repo (spec: configs stay until confirmed unneeded).

- [ ] **Step 3: Verify**

Run: `hyprctl reload` then press Super+Shift+W → bar restarts; `pgrep waybar` → no output.

- [ ] **Step 4: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/hypr/hyprland.lua
git commit -m "Retire Waybar autostart in favour of Quickshell

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
```
