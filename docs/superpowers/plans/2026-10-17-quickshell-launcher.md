# Quickshell Launcher Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace wofi (apps), wofi-calc and wofi-emoji with one Quickshell launcher opened over IPC.

**Architecture:** A single overlay `PanelWindow` (`launcher/Launcher.qml`) with an `IpcHandler` named `launcher`. Query prefix picks the mode (apps / `=` calc / `:` emoji). Pure logic in `lib/launcher.js`, `lib/fuzzy.js`, `lib/frecency.js` (unit-tested); state in `services/AppUsage.qml` and `services/Calc.qml`. Reuses the bar's `Theme`, `Icons`, `StyledText` and test harness.

**Tech Stack:** Quickshell 0.3.2 (`DesktopEntries`, `IpcHandler`, `FileView`, `Process`, `WlrLayershell`, `Quickshell.Widgets.IconImage`), QtQuick.Controls.Basic, qmltestrunner, `qalc`, `wl-copy`, `wtype`.

Spec: `docs/superpowers/specs/2026-10-17-quickshell-launcher-design.md`

---

## Conventions (read once)

- Config root: `/home/yanagi/dotfiles/.config/quickshell` — this is also the **live config** of the user's running bar (`~/.config` resolves into the repo). Quickshell hot-reloads on save, so a broken file breaks the user's bar until fixed. Keep each file valid when saving.
- Imports: `import qs.<dir>` (no qmldir files). JS libs by relative path with `.pragma library`.
- No hex colours outside `theme/Theme.qml`.
- `tests/run.sh [file]` = unit tests (headless). `tests/smoke.sh` = 6 s launch of a second instance; fails on WARN/ERROR except listed external D-Bus noise.
- Qt's JS engine does not iterate strings by code point (`Array.from(str)` splits surrogate pairs). Quickshell singletons are created lazily on first reference.
- Never stage `.config/zsh/.zshrc` or `.config/VSCodium/`. Never run `git stash`.
- Do not open the launcher on the user's screen during automated work (it grabs the keyboard). Use `qs ipc show` to verify IPC registration instead.

## File map

```
.config/quickshell/
├── shell.qml                 # modify: add Launcher {}
├── data/emoji.txt            # create: copied from /usr/sbin/wofi-emoji
├── lib/launcher.js           # parseQuery, prefixFor, parseEmoji, filterEmoji
├── lib/fuzzy.js              # score(query, text)
├── lib/frecency.js           # record, boost
├── services/AppUsage.qml     # persisted launch history
├── services/Calc.qml         # debounced qalc
├── launcher/Launcher.qml     # window, IPC, search, list, activation
├── launcher/ResultRow.qml    # one result row
└── tests/tst_launcher.qml, tst_fuzzy.qml, tst_frecency.qml
.config/hypr/hyprland.lua     # modify: rebind Super+Space / C / M
```

---

### Task 1: Emoji data + lib/launcher.js

**Files:**
- Create: `data/emoji.txt`, `lib/launcher.js`
- Test: `tests/tst_launcher.qml`

- [ ] **Step 1: Copy emoji data**

```bash
cd /home/yanagi/dotfiles/.config/quickshell
mkdir -p data
sed '1,/^### DATA ###$/d' /usr/sbin/wofi-emoji > data/emoji.txt
wc -l data/emoji.txt; head -2 data/emoji.txt
```

Expected: ~1870 lines; first line starts with `😀 grinning face`.

- [ ] **Step 2: Write the failing test**

`tests/tst_launcher.qml`:

```qml
import QtQuick
import QtTest
import "../lib/launcher.js" as L

TestCase {
    name: "Launcher"

    readonly property var sample: [
        { emoji: "😀", description: "grinning face smile" },
        { emoji: "🔥", description: "fire hot flame" },
    ]

    function test_parseQuery() {
        compare(L.parseQuery("=2+2"), { mode: "calc", term: "2+2" })
        compare(L.parseQuery(": fire"), { mode: "emoji", term: "fire" })
        compare(L.parseQuery("fire"), { mode: "apps", term: "fire" })
        compare(L.parseQuery(""), { mode: "apps", term: "" })
    }
    function test_prefixFor() {
        compare(L.prefixFor("calc"), "=")
        compare(L.prefixFor("emoji"), ":")
        compare(L.prefixFor("apps"), "")
    }
    function test_parseEmoji() {
        compare(L.parseEmoji("😀 grinning face smile\n\n🔥 fire hot flame\n"), sample)
    }
    function test_filterEmoji() {
        compare(L.filterEmoji(sample, "fire", 10), [sample[1]])
        compare(L.filterEmoji(sample, "face SMILE", 10), [sample[0]])
        compare(L.filterEmoji(sample, "", 10), sample)
        compare(L.filterEmoji(sample, "", 1), [sample[0]])
        compare(L.filterEmoji(sample, "nope", 10), [])
    }
}
```

- [ ] **Step 3: Run test to verify it fails**

Run: `tests/run.sh tests/tst_launcher.qml`
Expected: error, `launcher.js` cannot be loaded

- [ ] **Step 4: Implement**

`lib/launcher.js`:

```js
.pragma library

// Query text → { mode: "apps" | "calc" | "emoji", term }
function parseQuery(text) {
    if (text.startsWith("=")) return { mode: "calc", term: text.slice(1).trim() }
    if (text.startsWith(":")) return { mode: "emoji", term: text.slice(1).trim() }
    return { mode: "apps", term: text.trim() }
}

// Text to prefill when opening the launcher in a mode.
function prefixFor(mode) { return mode === "calc" ? "=" : mode === "emoji" ? ":" : "" }

// emoji.txt ("<emoji> <description words…>" per line) → [{ emoji, description }]
function parseEmoji(text) {
    const out = []
    for (const line of text.split("\n")) {
        const i = line.indexOf(" ")
        if (i <= 0) continue
        out.push({ emoji: line.slice(0, i), description: line.slice(i + 1).trim() })
    }
    return out
}

// Entries whose description contains every word of `term` (case-insensitive); at most `limit`.
function filterEmoji(entries, term, limit) {
    const words = term.toLowerCase().split(/\s+/).filter(w => w !== "")
    const out = []
    for (const e of entries) {
        const d = e.description.toLowerCase()
        if (words.every(w => d.indexOf(w) !== -1)) {
            out.push(e)
            if (out.length >= limit) break
        }
    }
    return out
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `tests/run.sh tests/tst_launcher.qml`
Expected: `Totals: 6 passed, 0 failed`

- [ ] **Step 6: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/data/emoji.txt .config/quickshell/lib/launcher.js .config/quickshell/tests/tst_launcher.qml
git commit -m "Add launcher query parsing and emoji data

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 2: lib/fuzzy.js

**Files:**
- Create: `lib/fuzzy.js`
- Test: `tests/tst_fuzzy.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_fuzzy.qml`:

```qml
import QtQuick
import QtTest
import "../lib/fuzzy.js" as Fuzzy

TestCase {
    name: "Fuzzy"

    function test_empty() { compare(Fuzzy.score("", "Firefox"), 0) }
    function test_noMatch() { compare(Fuzzy.score("xyz", "Firefox"), -1) }
    function test_subsequence() { verify(Fuzzy.score("ff", "Firefox") > 0) }
    function test_prefixBeatsMiddle() {
        verify(Fuzzy.score("fire", "Firefox") > Fuzzy.score("fire", "Campfire"))
    }
    function test_wordStarts() {
        verify(Fuzzy.score("vc", "VS Code") > Fuzzy.score("vc", "Vacation"))
    }
    function test_caseInsensitive() {
        compare(Fuzzy.score("FIRE", "firefox"), Fuzzy.score("fire", "firefox"))
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_fuzzy.qml`
Expected: error, `fuzzy.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/fuzzy.js`:

```js
.pragma library

// Subsequence fuzzy match, case-insensitive. Higher is better, -1 = no match,
// empty query = 0. Bonuses: consecutive chars, word starts, whole-prefix; shorter text wins ties.
function score(query, text) {
    const q = query.toLowerCase()
    const t = text.toLowerCase()
    if (q === "") return 0
    let s = 0
    let from = 0
    let prev = -2
    for (let qi = 0; qi < q.length; qi++) {
        const found = t.indexOf(q[qi], from)
        if (found === -1) return -1
        s += 1
        if (found === prev + 1) s += 5
        if (found === 0 || /[\s\-_.]/.test(t[found - 1])) s += 8
        prev = found
        from = found + 1
    }
    if (t.startsWith(q)) s += 20
    return s - (t.length - q.length) * 0.1
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_fuzzy.qml`
Expected: `Totals: 8 passed, 0 failed`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/fuzzy.js .config/quickshell/tests/tst_fuzzy.qml
git commit -m "Add fuzzy matcher for the launcher

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 3: lib/frecency.js

**Files:**
- Create: `lib/frecency.js`
- Test: `tests/tst_frecency.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_frecency.qml`:

```qml
import QtQuick
import QtTest
import "../lib/frecency.js" as Frecency

TestCase {
    name: "Frecency"

    readonly property real day: 86400000

    function test_record() {
        const a = Frecency.record({}, "kitty", 100)
        compare(a, { kitty: { count: 1, last: 100 } })
        const b = Frecency.record(a, "kitty", 200)
        compare(b, { kitty: { count: 2, last: 200 } })
        compare(a, { kitty: { count: 1, last: 100 } })
    }
    function test_boost_none() { compare(Frecency.boost({}, "kitty", 0), 0) }
    function test_boost_counts() {
        fuzzyCompare(Frecency.boost({ k: { count: 1, last: 0 } }, "k", 0), 1, 1e-9)
        fuzzyCompare(Frecency.boost({ k: { count: 3, last: 0 } }, "k", 0), 2, 1e-9)
    }
    function test_boost_decay() {
        fuzzyCompare(Frecency.boost({ k: { count: 1, last: 0 } }, "k", 14 * day), 0.5, 1e-9)
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `tests/run.sh tests/tst_frecency.qml`
Expected: error, `frecency.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/frecency.js`:

```js
.pragma library

const DAY_MS = 86400000
const HALF_LIFE_DAYS = 14

// New usage map with `key` launched at `now` (ms). Does not mutate `usage`.
function record(usage, key, now) {
    const out = Object.assign({}, usage)
    const prev = usage[key]
    out[key] = { count: (prev ? prev.count : 0) + 1, last: now }
    return out
}

// log2(1 + count), halved for every 14 days since the last launch. 0 if never launched.
function boost(usage, key, now) {
    const u = usage[key]
    if (!u) return 0
    const ageDays = Math.max(0, now - u.last) / DAY_MS
    return Math.log2(1 + u.count) * Math.pow(0.5, ageDays / HALF_LIFE_DAYS)
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `tests/run.sh tests/tst_frecency.qml`
Expected: `Totals: 6 passed, 0 failed`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/frecency.js .config/quickshell/tests/tst_frecency.qml
git commit -m "Add frecency scoring for the launcher

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 4: AppUsage and Calc services

**Files:**
- Create: `services/AppUsage.qml`, `services/Calc.qml`

- [ ] **Step 1: AppUsage**

`services/AppUsage.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/frecency.js" as Frecency

// App launch history for frecency ranking, persisted in the Quickshell state dir.
// A missing or corrupt file just means an empty history.
Singleton {
    id: root
    property var usage: ({})

    function boost(key) { return Frecency.boost(usage, key, Date.now()) }

    function record(key) {
        usage = Frecency.record(usage, key, Date.now())
        file.setText(JSON.stringify(usage))
    }

    FileView {
        id: file
        path: Quickshell.statePath("app-usage.json")
        blockLoading: true
        printErrors: false
        onLoaded: {
            try { root.usage = JSON.parse(text()) || {} } catch (e) { root.usage = {} }
        }
    }
}
```

- [ ] **Step 2: Calc**

`services/Calc.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Debounced qalc. Set `expression`; `result` follows ~150 ms after it stops changing.
// "" = no result (empty expression or qalc failed).
Singleton {
    id: root
    property string expression: ""
    property string result: ""

    onExpressionChanged: {
        if (expression === "") {
            debounce.stop()
            result = ""
            return
        }
        debounce.restart()
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: proc.exec(["qalc", "-t", root.expression])
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: root.result = text.trim()
        }
        onExited: code => { if (code !== 0) root.result = "" }
    }
}
```

- [ ] **Step 3: Verify with a temporary log**

Temporarily add to `shell.qml` inside `ShellRoot` (and `import qs.services` at the top):

```qml
    Timer {
        interval: 300; running: true
        onTriggered: { Calc.expression = "2+2*3"; AppUsage.record("__plan_test__"); console.log("USAGE", JSON.stringify(AppUsage.usage)) }
    }
    Timer { interval: 1200; running: true; onTriggered: console.log("CALC", Calc.result) }
```

Run: `timeout 3 qs -p . --no-color 2>&1 | grep -E 'USAGE|CALC|WARN|ERROR'`
Expected: `USAGE {"__plan_test__":{"count":1,...}}` and `CALC 8`, no WARN/ERROR. Then check the state file exists: `find ~/.local/state/quickshell -name app-usage.json` → one path; remove the test key by deleting that file (`rm` the printed path — it only contains the test entry).

If `setText` fails because the state directory does not exist, report it (do not invent a workaround silently).

- [ ] **Step 4: Restore shell.qml, smoke**

Revert the temporary edits (`git checkout .config/quickshell/shell.qml` from the repo root is fine — shell.qml has no other uncommitted changes).

Run: `tests/smoke.sh` → `smoke ok`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/services/AppUsage.qml .config/quickshell/services/Calc.qml
git commit -m "Add app usage and qalc services for the launcher

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Launcher window

**Files:**
- Create: `launcher/ResultRow.qml`, `launcher/Launcher.qml`
- Modify: `shell.qml`

- [ ] **Step 1: ResultRow**

`launcher/ResultRow.qml`:

```qml
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets

// One launcher result. modelData: { kind, title, subtitle, icon, payload }.
// Apps show a theme icon; calc/emoji show `icon` as a glyph.
Rectangle {
    id: root
    required property var modelData
    property bool selected: false
    signal activated()

    implicitHeight: 44
    radius: 8
    color: selected ? Theme.elevated : area.containsMouse ? Theme.base : "transparent"

    Rectangle {
        visible: root.selected
        width: 3
        height: parent.height - 16
        radius: 2
        anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
        color: Theme.gold
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 14; rightMargin: 10 }
        spacing: 10

        IconImage {
            visible: root.modelData.kind === "app"
            source: visible ? Quickshell.iconPath(root.modelData.icon, "application-x-executable") : ""
            implicitSize: 24
        }
        StyledText {
            visible: root.modelData.kind !== "app"
            text: root.modelData.icon
            color: Theme.gold
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 24
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true

            StyledText {
                text: root.modelData.title
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                visible: text !== ""
                text: root.modelData.subtitle
                color: Theme.textTertiary
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
```

- [ ] **Step 2: Launcher**

`launcher/Launcher.qml`:

```qml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.theme
import qs.services
import "../lib/launcher.js" as L
import "../lib/fuzzy.js" as Fuzzy

// App / calc / emoji launcher. Opened with `qs ipc call launcher toggle <apps|calc|emoji>`.
PanelWindow {
    id: root

    property bool open: false
    property alias query: search.text
    readonly property var parsed: L.parseQuery(query)
    property var emojiEntries: []
    readonly property var results: computeResults(parsed, Calc.result, AppUsage.usage)

    function toggle(mode) {
        if (open) {
            dismiss()
            return
        }
        query = L.prefixFor(mode)
        list.currentIndex = 0
        open = true
        visible = true
        search.forceActiveFocus()
    }

    function dismiss() { open = false }

    // calcResult / usage are passed so the binding re-evaluates when they change
    function computeResults(p, calcResult, usage) {
        if (p.mode === "calc") {
            return p.term !== "" && calcResult !== ""
                ? [{ kind: "calc", title: calcResult, subtitle: "Enter to copy", icon: "=", payload: calcResult }]
                : []
        }
        if (p.mode === "emoji") {
            return L.filterEmoji(emojiEntries, p.term, 200)
                .map(e => ({ kind: "emoji", title: e.description, subtitle: "", icon: e.emoji, payload: e.emoji }))
        }
        return DesktopEntries.applications.values
            .filter(a => !a.noDisplay)
            .map(a => ({ app: a, score: Fuzzy.score(p.term, a.name) }))
            .filter(x => x.score >= 0)
            .map(x => ({ app: x.app, rank: x.score + 10 * AppUsage.boost(x.app.name) }))
            .sort((x, y) => y.rank - x.rank || x.app.name.localeCompare(y.app.name))
            .map(x => ({
                kind: "app",
                title: x.app.name,
                subtitle: x.app.comment || x.app.genericName || "",
                icon: x.app.icon,
                payload: x.app,
            }))
    }

    function activate(item) {
        if (!item) return
        dismiss()
        if (item.kind === "app") {
            AppUsage.record(item.title)
            item.payload.execute()
        } else if (item.kind === "calc") {
            Quickshell.execDetached(["wl-copy", item.payload])
        } else if (item.kind === "emoji") {
            Quickshell.execDetached(["wl-copy", item.payload])
            // type into the previous window once our surface (and keyboard grab) is gone
            Quickshell.execDetached(["sh", "-c", "sleep 0.3; wtype \"$1\"", "sh", item.payload])
        }
    }

    function handleKey(e) {
        const ctrl = e.modifiers & Qt.ControlModifier
        if (e.key === Qt.Key_Escape) dismiss()
        else if (e.key === Qt.Key_Down || (ctrl && e.key === Qt.Key_J)) list.incrementCurrentIndex()
        else if (e.key === Qt.Key_Up || (ctrl && e.key === Qt.Key_K)) list.decrementCurrentIndex()
        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) activate(results[list.currentIndex])
        else return
        e.accepted = true
    }

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-launcher"

    IpcHandler {
        target: "launcher"
        function toggle(mode: string): void { root.toggle(mode) }
    }

    Binding {
        target: Calc
        property: "expression"
        value: root.parsed.mode === "calc" ? root.parsed.term : ""
    }

    FileView {
        path: Quickshell.shellPath("data/emoji.txt")
        blockLoading: true
        onLoaded: root.emojiEntries = L.parseEmoji(text())
    }

    // click outside the box closes
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismiss()
    }

    Rectangle {
        id: box
        anchors.centerIn: parent
        width: 600
        height: 550
        radius: Theme.radiusPopup
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96

        Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }
        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                onRunningChanged: if (!running && !root.open) root.visible = false
            }
        }

        // swallow clicks inside the box so they don't reach the close area
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors { fill: parent; margins: Theme.padding }
            spacing: Theme.spacing

            TextField {
                id: search
                Layout.fillWidth: true
                placeholderText: "Search apps      = calc      : emoji"
                color: Theme.textPrimary
                placeholderTextColor: Theme.textTertiary
                selectionColor: Theme.goldDim
                selectedTextColor: Theme.base
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
                leftPadding: 12
                background: Rectangle {
                    implicitHeight: 40
                    radius: 8
                    color: Theme.base
                    border.color: search.activeFocus ? Theme.goldDim : Theme.border
                    border.width: 1
                }
                onTextChanged: list.currentIndex = 0
                Keys.onPressed: e => root.handleKey(e)
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: root.results

                delegate: ResultRow {
                    width: ListView.view.width
                    selected: ListView.isCurrentItem
                    onActivated: root.activate(modelData)
                }
            }
        }
    }
}
```

- [ ] **Step 3: Add to shell.qml**

`shell.qml` becomes:

```qml
//@ pragma IconTheme Adwaita
import Quickshell
import QtQuick
import qs.bar
import qs.launcher

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Launcher {}
}
```

- [ ] **Step 4: Smoke + IPC registration**

Run: `tests/smoke.sh` → `smoke ok`.
The user's running instance hot-reloads from the same directory. Run: `qs ipc show`
Expected: output lists target `launcher` with function `toggle(mode: string): void`. Do NOT call it (it would grab the user's keyboard).

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/launcher .config/quickshell/shell.qml
git commit -m "Add Quickshell launcher with apps, calc and emoji modes

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 6: Rebind Hyprland keys

**Files:**
- Modify: `/home/yanagi/dotfiles/.config/hypr/hyprland.lua:30,193,194`

- [ ] **Step 1: Edit binds**

- Line 30: `local menu        = "qs ipc call launcher toggle apps"`
- Line 193: `hl.bind(mainMod .. " + C",                 hl.dsp.exec_cmd("qs ipc call launcher toggle calc"))`
- Line 194: `hl.bind(mainMod .. " + M",                 hl.dsp.exec_cmd("qs ipc call launcher toggle emoji"))`

Verify: `grep -nE 'wofi|launcher' .config/hypr/hyprland.lua` → only the three `launcher` lines, no `wofi`.

- [ ] **Step 2: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/hypr/hyprland.lua
git commit -m "Bind Super+Space/C/M to the Quickshell launcher

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 3: Manual checks (user)**

After `hyprctl reload`:
- Super+Space opens centered launcher on the focused monitor; typing filters apps with icons; Enter launches; Escape / outside click / Super+Space again closes.
- Launch an app twice, reopen: it ranks near the top with an empty query.
- Super+C → `=` prefilled; `2+2*3` shows `8`; Enter copies (`wl-paste` → `8`).
- Super+M → `:` prefilled; `fire` shows 🔥; Enter types it into the focused window and copies it.
- Ctrl+J / Ctrl+K and arrow keys move the gold selection bar.
