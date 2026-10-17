import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets

// One launcher result. modelData: { kind, title, subtitle, icon, payload }.
// Apps show a theme icon; calc/emoji show `icon` as a glyph.
Rectangle {
    id: root
    required property var modelData
    property bool selected: false
    signal activated()

    implicitHeight: 44
    radius: 8
    color: selected ? Theme.elevated : area.containsMouse ? Theme.base : "transparent"

    Rectangle {
        visible: root.selected
        width: 3
        height: parent.height - 16
        radius: 2
        anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
        color: Theme.gold
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 14; rightMargin: 10 }
        spacing: 10

        IconImage {
            visible: root.modelData.kind === "app"
            source: visible ? Quickshell.iconPath(root.modelData.icon, "application-x-executable") : ""
            implicitSize: 24
        }
        StyledText {
            visible: root.modelData.kind !== "app"
            text: root.modelData.icon
            color: Theme.gold
            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
            Layout.preferredWidth: 24
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true

            StyledText {
                text: root.modelData.title
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                visible: text !== ""
                text: root.modelData.subtitle
                color: Theme.textTertiary
                font.pixelSize: Theme.fontSizeSmall
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
