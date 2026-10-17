import Quickshell.Hyprland
import QtQuick
import qs.theme
import qs.widgets

// One workspace in the overview: a monitor-shaped tile with its windows.
// Click switches to it; it's also the drop target for dragged windows.
Rectangle {
    id: root
    required property int workspaceId
    required property var monitor
    required property real tileScale
    required property var overview
    property bool selected: false
    property bool active: false

    readonly property var windows: Hyprland.toplevels.values.filter(t => t.workspace && t.workspace.id === workspaceId)

    // hyprctl window coordinates are logical pixels
    width: (monitor ? monitor.width / monitor.scale : 1920) * tileScale
    height: (monitor ? monitor.height / monitor.scale : 1080) * tileScale
    radius: 8
    color: drop.containsDrag || area.containsMouse ? Theme.elevated : Theme.surface
    border.color: active ? Theme.gold : selected ? Theme.goldDim : Theme.border
    border.width: active || selected ? 2 : 1
    opacity: windows.length > 0 || active ? 1 : 0.6
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.overview.goTo(root.workspaceId)
    }

    DropArea {
        id: drop
        anchors.fill: parent
        onDropped: d => root.overview.moveWindow(d.source.address, root.workspaceId)
    }

    Repeater {
        model: root.windows
        WindowThumb {
            required property var modelData
            toplevel: modelData
            monitor: root.monitor
            tileScale: root.tileScale
            overview: root.overview
        }
    }

    StyledText {
        anchors { left: parent.left; top: parent.top; margins: 6 }
        z: 50
        text: root.workspaceId
        color: root.active ? Theme.gold : Theme.textSecondary
        font.bold: root.active
    }
}
