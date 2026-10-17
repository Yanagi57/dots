import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.widgets
import "../lib/overview.js" as Ov

// A window inside a workspace tile: live preview (falls back to icon + title).
// Click focuses it; drag onto another tile moves it there.
Rectangle {
    id: root
    required property var toplevel
    required property var monitor
    required property real tileScale
    required property var overview

    readonly property string address: toplevel.address
    readonly property var ipc: toplevel.lastIpcObject
    readonly property var rect: ipc && ipc.at && ipc.size
        ? Ov.thumbRect(ipc.at, ipc.size, toplevel.monitor ?? monitor, tileScale)
        : ({ x: 0, y: 0, width: 0, height: 0 })

    x: rect.x
    y: rect.y
    width: rect.width
    height: rect.height
    visible: width > 0 && height > 0
    radius: 4
    color: Theme.elevated
    border.color: area.containsMouse ? Theme.gold : Theme.border
    border.width: 1
    clip: true
    z: area.drag.active ? 10 : 1

    Drag.active: area.drag.active
    Drag.source: root
    Drag.hotSpot.x: width / 2
    Drag.hotSpot.y: height / 2

    ScreencopyView {
        id: preview
        anchors.fill: parent
        anchors.margins: 1
        // only capture while the overview is open
        captureSource: root.overview.open ? root.toplevel.wayland : null
        live: true
    }

    Column {
        anchors.centerIn: parent
        visible: !preview.hasContent
        spacing: 4

        IconImage {
            anchors.horizontalCenter: parent.horizontalCenter
            implicitSize: Math.max(12, Math.min(32, root.height * 0.5))
            source: Quickshell.iconPath(DesktopEntries.heuristicLookup(root.ipc?.class ?? "")?.icon ?? "", "application-x-executable")
        }
        StyledText {
            width: root.width - 8
            text: root.toplevel.title
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: Theme.textSecondary
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    MouseArea {
        id: area
        property bool dragged: false

        anchors.fill: parent
        hoverEnabled: true
        drag.target: root
        cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.PointingHandCursor

        // lift the whole tile above its siblings so the thumb isn't painted under later tiles
        drag.onActiveChanged: root.parent.z = drag.active ? 100 : 0

        onPressed: dragged = false
        onPositionChanged: if (drag.active) dragged = true
        onReleased: {
            if (!dragged) return
            root.Drag.drop()
            // snap back if it wasn't dropped on another workspace
            root.x = Qt.binding(() => root.rect.x)
            root.y = Qt.binding(() => root.rect.y)
        }
        onClicked: if (!dragged) root.overview.focusWindow(root.address)
    }
}
