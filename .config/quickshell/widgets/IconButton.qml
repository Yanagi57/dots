import QtQuick
import qs.theme

// Clickable glyph that turns gold on hover.
StyledText {
    id: root
    property color baseColor: Theme.textSecondary
    signal clicked(var mouse)

    color: area.containsMouse ? Theme.gold : baseColor

    MouseArea {
        id: area
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => root.clicked(m)
    }
}
