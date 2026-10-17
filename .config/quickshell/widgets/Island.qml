import QtQuick
import QtQuick.Layouts
import qs.theme

// Rounded pill holding a row of children. Children with their own MouseArea
// (declared later, so on top) take clicks first; everything else hits the island.
Rectangle {
    id: root
    default property alias content: row.data
    property bool hoverable: true
    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: row.implicitWidth + Theme.padding * 2
    implicitHeight: Theme.islandHeight
    radius: Theme.radius
    color: area.containsMouse && hoverable ? Theme.elevated : Theme.surface
    border.color: Theme.border
    border.width: 1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: m => root.clicked(m)
        onWheel: w => root.wheel(w)
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacing
    }
}
