import Quickshell.Services.Mpris
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import "../lib/media.js" as Media

// Album art + track + transport controls for the current MPRIS player. Hidden when none.
Rectangle {
    id: root
    readonly property var player: Media.pick(Mpris.players.values)

    visible: player !== null
    implicitWidth: 400
    implicitHeight: 84
    radius: Theme.radiusPopup
    color: Theme.base
    border.color: Theme.border
    border.width: 1

    RowLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            radius: 8
            color: Theme.elevated

            StyledText {
                anchors.centerIn: parent
                visible: art.status !== Image.Ready
                text: Icons.music
                color: Theme.gold
                font.pixelSize: 28
            }
            Image {
                id: art
                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize: Qt.size(128, 128)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
                text: root.player && root.player.trackTitle !== "" ? root.player.trackTitle : "Unknown title"
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                text: root.player ? (root.player.trackArtist || root.player.identity) : ""
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            RowLayout {
                spacing: 16
                Layout.topMargin: 4

                IconButton {
                    text: Icons.previous
                    enabled: root.player ? root.player.canGoPrevious : false
                    onClicked: root.player.previous()
                }
                IconButton {
                    text: root.player && root.player.isPlaying ? Icons.pause : Icons.play
                    baseColor: Theme.gold
                    onClicked: root.player.togglePlaying()
                }
                IconButton {
                    text: Icons.next
                    enabled: root.player ? root.player.canGoNext : false
                    onClicked: root.player.next()
                }
            }
        }
    }
}
