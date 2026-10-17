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
        // follow `open`, not `visible`: a reopen during fade-out must re-arm the grab
        active: root.open
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
