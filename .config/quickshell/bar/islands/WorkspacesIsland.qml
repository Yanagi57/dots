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

    // Touchpads send many small deltas; switch once per mouse-wheel notch (120).
    property real wheelAccum: 0

    hoverable: false
    onWheel: w => {
        wheelAccum += w.angleDelta.y
        if (Math.abs(wheelAccum) < 120) return
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", wheelAccum > 0 ? "m-1" : "m+1"])
        wheelAccum = 0
    }

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
