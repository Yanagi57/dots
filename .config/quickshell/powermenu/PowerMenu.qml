import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services
import "../lib/powermenu.js" as PM

// Lock / logout / suspend / hibernate / reboot / shutdown.
// Opened with `qs ipc call powermenu toggle` or the bar's power button.
PanelWindow {
    id: root

    readonly property int columns: 3
    property bool open: false
    property int current: 0

    function toggle() {
        if (open) {
            dismiss()
            return
        }
        // pick the monitor once; a live binding would move the window while open
        screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        current = 0
        open = true
        visible = true
        keys.forceActiveFocus()
    }

    function dismiss() { open = false }

    function run(index) {
        if (index < 0) return
        dismiss()
        Quickshell.execDetached(PM.actions[index].command)
    }

    visible: false
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-powermenu"

    IpcHandler {
        target: "powermenu"
        function toggle(): void { root.toggle() }
    }

    Connections {
        target: Panels
        function onPowerMenuRequested() { root.toggle() }
    }

    // dimmed backdrop; click closes
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.alpha(Theme.base, 0.7)
        opacity: root.open ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                onRunningChanged: if (!running && !root.open) root.visible = false
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismiss()
        }

        Grid {
            id: grid
            anchors.centerIn: parent
            columns: root.columns
            spacing: 26
            scale: root.open ? 1 : 0.96
            Behavior on scale { NumberAnimation { duration: Theme.animFast; easing.type: Easing.OutCubic } }

            Repeater {
                model: PM.actions
                PowerButton {
                    required property var modelData
                    required property int index
                    action: modelData
                    selected: root.current === index
                    onHovered: root.current = index
                    onActivated: root.run(index)
                }
            }
        }
    }

    Item {
        id: keys
        focus: true
        Keys.onPressed: e => {
            if (e.key === Qt.Key_Escape) root.dismiss()
            else if (e.key === Qt.Key_Left) root.current = PM.move(root.current, -1, 0, root.columns, PM.actions.length)
            else if (e.key === Qt.Key_Right) root.current = PM.move(root.current, 1, 0, root.columns, PM.actions.length)
            else if (e.key === Qt.Key_Up) root.current = PM.move(root.current, 0, -1, root.columns, PM.actions.length)
            else if (e.key === Qt.Key_Down) root.current = PM.move(root.current, 0, 1, root.columns, PM.actions.length)
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.run(root.current)
            else if (PM.indexForKey(e.text) >= 0) root.run(PM.indexForKey(e.text))
            else return
            e.accepted = true
        }
    }
}
