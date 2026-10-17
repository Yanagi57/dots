# Quickshell Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace swaync with a Quickshell notification daemon: top-right popups plus a notification center dropping from the bar's bell (DND, media card with album art, history).

**Architecture:** `services/Notifs.qml` owns the `NotificationServer` and all state (history, popup list, unread, DND). `notifications/NotificationCard.qml` renders one notification and is shared by the popup stack (`notifications/NotificationPopups.qml`) and the bell dropdown (`bar/popups/NotificationCenterPopup.qml`). `widgets/MediaCard.qml` is a reusable album-art media card (reused later by the media popup). Pure rules in `lib/notifs.js` (unit-tested). Lists use Quickshell's `ScriptModel` so delegates (and their timers) survive list changes.

**Tech Stack:** Quickshell 0.3.2 (`Quickshell.Services.Notifications`, `Quickshell.Services.Mpris`, `ScriptModel`, `Quickshell.Widgets` `IconImage`/`ClippingRectangle`), qmltestrunner.

Design (approved in chat, 2026-10-17): bell dropdown, popups top-right under the bar (max 5, newest on top, 400 px), timeouts = app's own if set else low 4 s / normal 8 s, critical sticky with `error` left edge; hover pauses (restarts) the timer; click = default action else hide popup; popup ✕ hides the popup, history ✕ dismisses; DND suppresses non-critical popups; history kept until dismissed (survives config reloads, not restarts). No inline replies / 2FA / persistence.

---

## Conventions (read once)

- Config root `/home/yanagi/dotfiles/.config/quickshell` is the **live config** of the user's running bar (hot-reloads on save). Keep files valid when saving. If a new file isn't picked up, `touch shell.qml` triggers a reload.
- Imports: `import qs.<dir>`; JS libs by relative path with `.pragma library`. No hex colours outside `theme/Theme.qml`; no raw glyphs outside `theme/Icons.qml`.
- `tests/run.sh [file]` = unit tests. `tests/smoke.sh` = 6 s second instance; fails on WARN/ERROR except listed external noise. When grepping `qs` output, redirect to a file first.
- **swaync is still running** until the final cutover, so it owns `org.freedesktop.Notifications`. Quickshell's server will fail to register in both the user's instance and smoke runs, and likely log a warning. If smoke fails only because of that registration warning, add a narrowly-matching filter to `tests/smoke.sh` with a comment — do not filter anything broader. Do NOT kill swaync.
- Qt's JS engine doesn't iterate strings by code point; singletons are lazy.
- Never stage `.config/zsh/.zshrc` or `.config/VSCodium/`. Never `git stash`.
- Commit trailer: `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`

## File map

```
.config/quickshell/
├── lib/notifs.js                          # create: timeoutFor, ago, iconUrl
├── tests/tst_notifs.qml                   # create
├── theme/Icons.qml                        # modify: close, previous, next, music
├── services/Notifs.qml                    # create: server + state
├── widgets/MediaCard.qml                  # create
├── notifications/NotificationCard.qml     # create
├── notifications/NotificationPopups.qml   # create
├── bar/popups/NotificationCenterPopup.qml # create
├── bar/islands/TogglesIsland.qml          # modify: bell → Notifs + signal
├── bar/Bar.qml                            # modify: wire center popup
├── shell.qml                              # modify: NotificationPopups {}
├── services/NotifBridge.qml               # delete
├── lib/swaync.js, tests/tst_swaync.qml    # delete
.config/hypr/hyprland.lua                  # modify: drop swaync autostart
```

---

### Task 1: lib/notifs.js

**Files:** Create `lib/notifs.js`; Test `tests/tst_notifs.qml`

- [ ] **Step 1: Write the failing test**

`tests/tst_notifs.qml`:

```qml
import QtQuick
import QtTest
import "../lib/notifs.js" as N

TestCase {
    name: "Notifs"

    function test_timeoutFor() {
        compare(N.timeoutFor("critical", 5000), 0)
        compare(N.timeoutFor("low", 0), 4000)
        compare(N.timeoutFor("normal", -1), 8000)
        compare(N.timeoutFor("normal", 3000), 3000)
        compare(N.timeoutFor("low", 3000), 3000)
    }
    function test_ago() {
        compare(N.ago(0, 30000), "now")
        compare(N.ago(0, 5 * 60000), "5m")
        compare(N.ago(0, 3 * 3600000), "3h")
        compare(N.ago(0, 2 * 86400000), "2d")
        compare(N.ago(5000, 0), "now")
    }
    function test_iconUrl() {
        compare(N.iconUrl("image://qsimage/1", "firefox"), "image://qsimage/1")
        compare(N.iconUrl("", "/usr/share/x.png"), "file:///usr/share/x.png")
        compare(N.iconUrl("", "file:///a.png"), "file:///a.png")
        compare(N.iconUrl("", "firefox"), "")
        compare(N.iconUrl("", ""), "")
    }
}
```

- [ ] **Step 2: Run, expect failure** — `tests/run.sh tests/tst_notifs.qml` → error, `notifs.js` cannot be loaded

- [ ] **Step 3: Implement**

`lib/notifs.js`:

```js
.pragma library

// How long a popup stays up, in ms. 0 = until dismissed.
// urgency: "low" | "normal" | "critical"; appTimeoutMs: the app's request (<= 0 = none).
function timeoutFor(urgency, appTimeoutMs) {
    if (urgency === "critical") return 0
    if (appTimeoutMs > 0) return appTimeoutMs
    return urgency === "low" ? 4000 : 8000
}

// Compact age: "now", "5m", "3h", "2d".
function ago(thenMs, nowMs) {
    const s = Math.max(0, Math.floor((nowMs - thenMs) / 1000))
    if (s < 60) return "now"
    if (s < 3600) return Math.floor(s / 60) + "m"
    if (s < 86400) return Math.floor(s / 3600) + "h"
    return Math.floor(s / 86400) + "d"
}

// Image URL for a notification: its own image, else an app icon given as a path or URL.
// "" means: look `appIcon` up as an icon-theme name instead.
function iconUrl(image, appIcon) {
    if (image) return image
    if (appIcon.startsWith("/")) return "file://" + appIcon
    if (appIcon.indexOf("://") !== -1) return appIcon
    return ""
}
```

- [ ] **Step 4: Run, expect pass** — `Totals: 5 passed, 0 failed`

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/lib/notifs.js .config/quickshell/tests/tst_notifs.qml
git commit -m "Add notification timeout, age and icon helpers

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 2: Icons + Notifs service

**Files:** Modify `theme/Icons.qml`; Create `services/Notifs.qml`

- [ ] **Step 1: Verify APIs and glyphs before writing code**

```bash
grep -n -A3 'Signal {' $(find /usr/lib/qt6/qml/Quickshell/Services/Notifications -name '*.qmltypes') | grep -E 'name:' | head
grep -n -B2 -A12 'name: "expireTimeout"' $(find /usr/lib/qt6/qml/Quickshell/Services/Notifications -name '*.qmltypes') | head -20
for cp in f04ae f04ad f075a; do echo "$cp $(fc-list ":charset=$cp" family | grep -c 'JetBrainsMono Nerd Font')"; done
```

Expected: a `notification` signal on NotificationServer; the three glyphs present (non-zero counts). Check whether `expireTimeout` is seconds or ms: run `notify-send -t 3000 test` against a scratch instance only if you can without killing swaync — otherwise read the Quickshell docs comment in the qmltypes/headers (`/usr/include/quickshell` if present). Quickshell documents it as **seconds**; the code below multiplies by 1000. If you find it is ms, drop the `* 1000` and report it.

- [ ] **Step 2: Icons**

In `theme/Icons.qml`, after the `firefox` line, add:

```qml
    readonly property string close: "✕"
    readonly property string previous: g(0xF04AE)
    readonly property string next: g(0xF04AD)
    readonly property string music: g(0xF075A)
```

- [ ] **Step 3: Service**

`services/Notifs.qml`:

```qml
pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../lib/notifs.js" as NotifLib

// Notification daemon + state.
// History = the server's tracked notifications (newest first in `list`).
// Popups are a separate list so hiding a popup keeps the history entry.
Singleton {
    id: root

    property bool dnd: false
    property bool unread: false
    property var popups: []          // Notification objects, newest first, max 5
    property var arrivals: ({})      // notification id → arrival time (ms), for "5m"

    readonly property var list: server.trackedNotifications.values.slice().reverse()
    // dismissed notifications drop out of `list` (and become null refs)
    readonly property var visiblePopups: popups.filter(n => n && list.indexOf(n) !== -1)

    function urgencyName(u) {
        return u === NotificationUrgency.Critical ? "critical" : u === NotificationUrgency.Low ? "low" : "normal"
    }
    // Quickshell reports expireTimeout in seconds
    function timeoutFor(n) { return NotifLib.timeoutFor(urgencyName(n.urgency), n.expireTimeout * 1000) }
    function hidePopup(n) { popups = popups.filter(p => p !== n) }
    function clearAll() { for (const n of list) n.dismiss() }
    function markRead() { unread = false }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true
            const a = Object.assign({}, root.arrivals)
            a[n.id] = Date.now()
            root.arrivals = a
            root.unread = true
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n].concat(root.popups).slice(0, 5)
        }
    }
}
```

- [ ] **Step 4: Smoke** — `tests/smoke.sh` → `smoke ok` (Notifs isn't referenced yet; this just proves nothing broke). Then a scratch check that it loads: copy the config to `/tmp/claude-1000/-home-yanagi-dotfiles/7b14ef34-cedc-4018-880f-ed140bb7fd79/scratchpad/ncopy`, add `import qs.services` and `Component.onCompleted: console.log("NOTIFS", Notifs.list.length)` to its `shell.qml` `ShellRoot`, run `timeout 4 qs -p <copy> --no-color > <copy>.log 2>&1`, and confirm `NOTIFS 0` plus no QML errors (a registration warning because swaync owns the bus name is expected — note its exact text for Task 3). Delete the copy.

- [ ] **Step 5: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/theme/Icons.qml .config/quickshell/services/Notifs.qml
git commit -m "Add Quickshell notification server service

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 3: MediaCard, NotificationCard, popup stack

**Files:** Create `widgets/MediaCard.qml`, `notifications/NotificationCard.qml`, `notifications/NotificationPopups.qml`; Modify `shell.qml`, maybe `tests/smoke.sh`

- [ ] **Step 1: MediaCard**

`widgets/MediaCard.qml`:

```qml
import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import "../lib/media.js" as Media

// Album art + track + transport controls for the current MPRIS player. Hidden when none.
Rectangle {
    id: root
    readonly property var player: Media.pick(Mpris.players.values)

    visible: player !== null
    implicitWidth: 400
    implicitHeight: 84
    radius: Theme.radiusPopup
    color: Theme.base
    border.color: Theme.border
    border.width: 1

    RowLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            radius: 8
            color: Theme.elevated

            StyledText {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Icons.music
                color: Theme.gold
                font.pixelSize: 28
            }
            Image {
                id: art
                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(128, 128)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: root.player && root.player.trackTitle !== "" ? root.player.trackTitle : "Unknown title"
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                text: root.player ? (root.player.trackArtist || root.player.identity) : ""
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: 16
                Layout.topMargin: 4

                IconButton {
                    text: Icons.previous
                    enabled: root.player ? root.player.canGoPrevious : false
                    onClicked: root.player.previous()
                }
                IconButton {
                    text: root.player && root.player.isPlaying ? Icons.pause : Icons.play
                    baseColor: Theme.gold
                    onClicked: root.player.togglePlaying()
                }
                IconButton {
                    text: Icons.next
                    enabled: root.player ? root.player.canGoNext : false
                    onClicked: root.player.next()
                }
            }
        }
    }
}
```

- [ ] **Step 2: NotificationCard**

`notifications/NotificationCard.qml`:

```qml
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import "../lib/notifs.js" as NotifLib

// One notification, used by the popup stack (popup: true) and the history list.
// Popup: auto-hides after its timeout (restarted while hovered); ✕ hides the popup only.
// History: shows age; ✕ dismisses. Click runs the default action if there is one.
Rectangle {
    id: root
    required property var notif
    property bool popup: false
    property real now: Date.now()

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: notif.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notif.actions.filter(a => a.identifier !== "default")
    readonly property string iconSource: NotifLib.iconUrl(notif.image, notif.appIcon)
        || (notif.appIcon !== "" ? Quickshell.iconPath(notif.appIcon, true) : "")

    implicitWidth: 400
    implicitHeight: content.implicitHeight + 2 * Theme.padding
    radius: Theme.radiusPopup
    color: Theme.surface
    border.color: Theme.border
    border.width: 1

    Rectangle {
        visible: root.critical
        width: 3
        radius: 2
        color: Theme.error
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 6 }
    }

    HoverHandler { id: hover }

    Timer {
        interval: Notifs.timeoutFor(root.notif)
        running: root.popup && interval > 0 && !hover.hovered
        onTriggered: Notifs.hidePopup(root.notif)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.defaultAction) root.defaultAction.invoke()
            else if (root.popup) Notifs.hidePopup(root.notif)
        }
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.padding; leftMargin: Theme.padding + 4 }
        spacing: 10

        IconImage {
            Layout.alignment: Qt.AlignTop
            visible: root.iconSource !== ""
            source: root.iconSource
            implicitSize: 36
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: root.notif.summary
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                StyledText {
                    visible: !root.popup
                    text: NotifLib.ago(Notifs.arrivals[root.notif.id] ?? root.now, root.now)
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                }
                IconButton {
                    text: Icons.close
                    onClicked: root.popup ? Notifs.hidePopup(root.notif) : root.notif.dismiss()
                }
            }

            StyledText {
                visible: text !== ""
                text: root.notif.body
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                color: Theme.textSecondary
                linkColor: Theme.teal
                Layout.fillWidth: true
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                visible: root.buttons.length > 0
                spacing: 6
                Layout.fillWidth: true
                Layout.topMargin: 4

                Repeater {
                    model: root.buttons
                    ToggleChip {
                        required property var modelData
                        text: modelData.text
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }
}
```

- [ ] **Step 3: Popup stack**

`notifications/NotificationPopups.qml`:

```qml
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services

// Popup stack, top-right under the bar, on the focused monitor.
PanelWindow {
    id: root

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    visible: Notifs.visiblePopups.length > 0
    color: "transparent"
    anchors { top: true; right: true }
    margins { top: Theme.spacing; right: Theme.spacing }
    // sit below the bar's exclusive zone without reserving space ourselves
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    implicitWidth: 400
    implicitHeight: Math.max(1, stack.implicitHeight)
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
        id: stack
        width: parent.width
        spacing: Theme.spacing

        add: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Theme.animFast } }
        move: Transition { NumberAnimation { properties: "y"; duration: Theme.animFast; easing.type: Easing.OutCubic } }

        Repeater {
            model: ScriptModel { values: Notifs.visiblePopups }
            NotificationCard {
                required property var modelData
                notif: modelData
                popup: true
                width: stack.width
            }
        }
    }
}
```

- [ ] **Step 4: Wire into shell.qml**

Add `import qs.notifications` after `import qs.powermenu`, and `NotificationPopups {}` after `PowerMenu {}`.

- [ ] **Step 5: Smoke**

Run: `tests/smoke.sh`. If it fails only on the notification-server registration warning noted in Task 2, add a filter matching that exact text to `tests/smoke.sh` (with a comment: "swaync owns org.freedesktop.Notifications until cutover") and rerun → `smoke ok`.

- [ ] **Step 6: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/widgets/MediaCard.qml .config/quickshell/notifications .config/quickshell/shell.qml .config/quickshell/tests/smoke.sh
git commit -m "Add notification popups and reusable media card

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 4: Notification center + bell

**Files:** Create `bar/popups/NotificationCenterPopup.qml`; Modify `bar/islands/TogglesIsland.qml`, `bar/Bar.qml`; Delete `services/NotifBridge.qml`, `lib/swaync.js`, `tests/tst_swaync.qml`

- [ ] **Step 1: Center popup**

`bar/popups/NotificationCenterPopup.qml`:

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import qs.notifications

BarPopup {
    id: root
    name: "notifications"

    onOpenChanged: if (open) Notifs.markRead()

    SystemClock { id: clock; precision: SystemClock.Minutes }

    ColumnLayout {
        width: 420
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: "Notifications"
                color: Theme.gold
                font.bold: true
                Layout.fillWidth: true
            }
            ToggleChip {
                text: Icons.bellDnd + "  DND"
                checked: Notifs.dnd
                onClicked: Notifs.dnd = !Notifs.dnd
            }
        }

        MediaCard { Layout.fillWidth: true }

        StyledText {
            visible: Notifs.list.length === 0
            text: "No notifications"
            color: Theme.textTertiary
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            Layout.bottomMargin: 12
        }

        ListView {
            visible: Notifs.list.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 480)
            clip: true
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            model: ScriptModel { values: Notifs.list }

            delegate: NotificationCard {
                required property var modelData
                notif: modelData
                now: clock.date.getTime()
                width: ListView.view.width
            }
        }

        ToggleChip {
            visible: Notifs.list.length > 0
            text: "Clear all"
            Layout.alignment: Qt.AlignRight
            onClicked: Notifs.clearAll()
        }
    }
}
```

- [ ] **Step 2: Bell → Notifs**

In `bar/islands/TogglesIsland.qml`:
- add `signal notificationsClicked()` right after `Island {` (before `hoverable: false`);
- replace the bell `IconButton` block with:

```qml
    IconButton {
        text: Notifs.dnd ? Icons.bellDnd : Notifs.unread ? Icons.bell : Icons.bellIdle
        baseColor: Notifs.unread ? Theme.gold : Theme.textSecondary
        onClicked: m => m.button === Qt.RightButton ? (Notifs.dnd = !Notifs.dnd) : notificationsClicked()
    }
```

- [ ] **Step 3: Wire in Bar.qml**

Read `bar/Bar.qml`. Change `TogglesIsland {}` to:

```qml
        TogglesIsland { id: togglesIsland; onNotificationsClicked: panel.toggle("notifications") }
```

and after `QuickSettingsPopup { … }` add:

```qml
    NotificationCenterPopup { bar: panel; anchorItem: togglesIsland }
```

- [ ] **Step 4: Remove the swaync bridge**

```bash
cd /home/yanagi/dotfiles
git rm .config/quickshell/services/NotifBridge.qml .config/quickshell/lib/swaync.js .config/quickshell/tests/tst_swaync.qml
grep -rn 'NotifBridge\|swaync' .config/quickshell --include='*.qml' --include='*.js'
```

Expected grep: only the smoke.sh comment if one was added in Task 3 (that's a .sh file, so no output here).

- [ ] **Step 5: Tests + smoke + forced-open check**

`tests/run.sh` → `0 failed`. `tests/smoke.sh` → `smoke ok`.
Scratch copy check (as in earlier tasks): copy config, add to its `Bar.qml` a `Timer { interval: 1000; running: true; onTriggered: panel.openPopup = "notifications" }`, run `timeout 4 qs -p <copy>` to a log, confirm no QML WARN/ERROR beyond known noise, delete copy.

- [ ] **Step 6: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/quickshell/bar .config/quickshell/services .config/quickshell/lib .config/quickshell/tests
git commit -m "Add notification center to the bell and drop the swaync bridge

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

---

### Task 5: Drop swaync autostart

**Files:** Modify `.config/hypr/hyprland.lua`

- [ ] **Step 1:** Delete the line `    hl.exec_cmd("swaync")`. Verify: `grep -n swaync .config/hypr/hyprland.lua` → no output.

- [ ] **Step 2: Commit**

```bash
cd /home/yanagi/dotfiles
git add .config/hypr/hyprland.lua
git commit -m "Stop autostarting swaync; Quickshell is the notification daemon

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>"
```

- [ ] **Step 3: Cutover (user, live)** — `pkill swaync; qs kill; qs -d`, then `notify-send "hello" "world"`, `notify-send -u critical "crit" "sticky"`, `notify-send -u low "low" "4s"`; check popups, bell gold, dropdown history/✕/Clear all, DND chip, media card with a player running.
