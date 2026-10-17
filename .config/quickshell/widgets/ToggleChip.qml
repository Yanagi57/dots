import QtQuick
import qs.theme

// Rounded button; gold fill when checked.
Rectangle {
    id: root
    property string text
    property bool checked: false
    signal clicked()

    implicitWidth: label.implicitWidth + Theme.padding * 2
    implicitHeight: 28
    radius: 14
    color: checked ? Theme.gold : area.containsMouse ? Theme.elevated : Theme.base
    border.color: checked ? Theme.gold : Theme.border
    border.width: 1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.checked ? Theme.base : Theme.textPrimary
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
