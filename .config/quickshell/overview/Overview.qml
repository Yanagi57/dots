import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services
import "../lib/grid.js" as Grid
import "../lib/overview.js" as Ov

// Workspaces 1–10 with live window previews. Opened with `qs ipc call overview toggle`.
PanelWindow {
    id: root

    readonly property int columns: 5
    readonly property int count: 10
    readonly property real tileScale: 0.18
    property bool open: false
    property int current: 0          // selected tile (workspace id - 1)
    property var monitor: null       // HyprlandMonitor the overview was opened on

    function toggle() {
        if (open) {
            dismiss()
            return
        }
        // pick the monitor once; a live binding would move the window while open
        monitor = Hyprland.focusedMonitor
        screen = Quickshell.screens.find(s => s.name === monitor?.name) ?? Quickshell.screens[0]
        // window positions in lastIpcObject can be stale
        Hyprland.refreshToplevels()
        Hyprland.refreshWorkspaces()
        current = Math.max(0, Math.min(count - 1, (Hyprland.focusedWorkspace?.id ?? 1) - 1))
        open = true
        visible = true
        keys.forceActiveFocus()
    }

    function dismiss() { open = false }

    function goTo(id) {
        dismiss()
        Compositor.afterLayerClosed("quickshell-overview", () => Compositor.focusWorkspace(id))
    }

    function focusWindow(address) {
        dismiss()
        Compositor.afterLayerClosed("quickshell-overview", () => Compositor.focusWindow(address))
    }

    function moveWindow(address, id) { Compositor.moveWindow(address, id) }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-overview"

    IpcHandler {
        target: "overview"
        function toggle(): void { root.toggle() }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Theme.base, 0.75)
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                onRunningChanged: if (!running && !root.open) { root.visible = false }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismiss()
        }

        Grid {
            anchors.centerIn: parent
            columns: root.columns
            spacing: 18
            scale: root.open ? 1 : 0.96
            Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

            Repeater {
                model: root.count
                WorkspaceTile {
                    required property int index
                    workspaceId: index + 1
                    monitor: root.monitor
                    tileScale: root.tileScale
                    overview: root
                    selected: root.current === index
                    active: (Hyprland.focusedWorkspace?.id ?? -1) === index + 1
                }
            }
        }
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: e => {
            const ws = Ov.workspaceForKey(e.text)
            if (e.key === Qt.Key_Escape) root.dismiss()
            else if (e.key === Qt.Key_Left) root.current = Grid.move(root.current, -1, 0, root.columns, root.count)
            else if (e.key === Qt.Key_Right) root.current = Grid.move(root.current, 1, 0, root.columns, root.count)
            else if (e.key === Qt.Key_Up) root.current = Grid.move(root.current, 0, -1, root.columns, root.count)
            else if (e.key === Qt.Key_Down) root.current = Grid.move(root.current, 0, 1, root.columns, root.count)
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.goTo(root.current + 1)
            else if (ws > 0) root.goTo(ws)
            else return
            e.accepted = true
        }
    }
}
