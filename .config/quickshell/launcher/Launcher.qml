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
