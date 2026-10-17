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
