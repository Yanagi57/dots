import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import qs.theme
import qs.services
import qs.widgets
import "../lib/switcher.js" as Sw

// Mac-style app switcher. Hyprland binds: Super+Tab → `switcher next`, Super+Shift+Tab →
// `switcher prev`, Super release → `switcher commit`. We also commit on a Super key-release
// seen by our own surface, in case the compositor's release bind doesn't fire.
PanelWindow {
    id: root

    property bool open: false
    property bool loading: false
    property bool commitPending: false   // Super released before the client list arrived
    property int startDelta: 1
    property int pendingSteps: 0         // Tab presses that arrived while loading
    property var apps: []
    property int current: 0

    function appName(app) { return DesktopEntries.heuristicLookup(app.cls)?.name ?? app.cls }

    function advance(delta) {
        if (open) {
            current = Sw.step(current, delta, apps.length)
            return
        }
        if (loading) {
            pendingSteps += delta
            return
        }
        loading = true
        commitPending = false
        startDelta = delta
        pendingSteps = 0
        clientsProc.running = true
    }

    function loaded(text) {
        loading = false
        let clients = []
        try { clients = JSON.parse(text) } catch (e) { return }
        apps = Sw.groupApps(clients)
        if (apps.length === 0) return
        current = startDelta > 0 ? Sw.initialIndex(apps.length) : apps.length - 1
        current = Sw.step(current, pendingSteps, apps.length)
        if (commitPending) {
            // quick Super+Tab tap: switch straight away without showing the strip
            Compositor.focusWindow(apps[current].address)
            return
        }
        screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        open = true
        visible = true
        keys.forceActiveFocus()
    }

    function commit() {
        if (loading) {
            commitPending = true
            return
        }
        if (!open) return
        const app = apps[current]
        dismiss()
        if (app) Compositor.focusWindow(app.address)
    }

    function dismiss() { open = false }

    visible: false
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Math.max(260, strip.implicitWidth + 40)
    implicitHeight: 150
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-switcher"

    IpcHandler {
        target: "switcher"
        function next(): void { root.advance(1) }
        function prev(): void { root.advance(-1) }
        function commit(): void { root.commit() }
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector { onStreamFinished: root.loaded(text) }
        onExited: code => { if (code !== 0) root.loading = false }
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
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

        Row {
            id: strip
            anchors.horizontalCenter: parent.horizontalCenter
            y: 20
            spacing: 12

            Repeater {
                model: root.apps

                Rectangle {
                    id: cell
                    required property var modelData
                    required property int index
                    readonly property bool selected: root.current === index

                    width: 84
                    height: 84
                    radius: 12
                    color: selected ? Theme.elevated : "transparent"
                    border.color: selected ? Theme.gold : "transparent"
                    border.width: 1.5

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 56
                        source: Quickshell.iconPath(DesktopEntries.heuristicLookup(cell.modelData.cls)?.icon ?? cell.modelData.cls, "application-x-executable")
                    }

                    // window count badge
                    Rectangle {
                        visible: cell.modelData.count > 1
                        anchors { right: parent.right; top: parent.top; margins: 4 }
                        width: 18
                        height: 18
                        radius: 9
                        color: Theme.gold

                        StyledText {
                            anchors.centerIn: parent
                            text: cell.modelData.count
                            color: Theme.base
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.current = cell.index
                            root.commit()
                        }
                    }
                }
            }
        }

        StyledText {
            anchors { bottom: parent.bottom; bottomMargin: 14; horizontalCenter: parent.horizontalCenter }
            text: root.apps[root.current] ? root.appName(root.apps[root.current]) : ""
            color: Theme.textPrimary
        }
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) root.dismiss()
            else if (e.key === Qt.Key_Tab || e.key === Qt.Key_Right) root.advance(1)
            else if (e.key === Qt.Key_Backtab || e.key === Qt.Key_Left) root.advance(-1)
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.commit()
            else return
            e.accepted = true
        }
        Keys.onReleased: e => {
            if (e.key === Qt.Key_Super_L || e.key === Qt.Key_Super_R || e.key === Qt.Key_Meta) {
                root.commit()
                e.accepted = true
            }
        }
    }
}
