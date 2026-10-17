import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../lib/powermenu.js" as PM

// One power menu tile: big gold glyph, label with its shortcut letter in gold.
Rectangle {
    id: root
    required property var action
    property bool selected: false
    readonly property var parts: PM.labelParts(action)
    signal activated()
    signal hovered()

    implicitWidth: 170
    implicitHeight: 150
    radius: 12
    color: selected ? Theme.elevated : Theme.surface
    border.color: selected ? Theme.gold : Theme.border
    border.width: selected ? 1.5 : 1
    Behavior on color { ColorAnimation { duration: Theme.animFast } }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Icons[root.action.id]
            color: Theme.gold
            font.pixelSize: 40
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            textFormat: Text.StyledText
            text: root.parts.before + "<font color=\"" + Theme.gold + "\">" + root.parts.key + "</font>" + root.parts.after
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered()
        onClicked: root.activated()
    }
}
