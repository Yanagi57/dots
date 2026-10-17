import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../../lib/media.js" as Media
import "../../lib/format.js" as Format

// Album art, transport controls and a seek bar for the current player.
BarPopup {
    id: root
    name: "media"

    readonly property var player: Media.pick(Mpris.players.values)
    readonly property bool hasLength: player !== null && player.lengthSupported && player.length > 0

    // MPRIS doesn't push position updates; re-read it every second while visible and playing
    Timer {
        interval: 1000
        repeat: true
        running: root.open && root.player !== null && root.player.isPlaying && !seek.pressed
        onTriggered: root.player.positionChanged()
    }

    ColumnLayout {
        width: 400
        spacing: Theme.spacing

        StyledText {
            visible: root.player === null
            text: "Nothing playing"
            color: Theme.textTertiary
        }

        MediaCard { Layout.fillWidth: true }

        RowLayout {
            visible: root.hasLength
            Layout.fillWidth: true
            spacing: Theme.spacing

            StyledText {
                text: Format.duration(root.player ? root.player.position : 0)
                color: Theme.textTertiary
                font.pixelSize: Theme.fontSizeSmall
                Layout.preferredWidth: 48
            }
            StyledSlider {
                id: seek
                Layout.fillWidth: true
                from: 0
                to: root.hasLength ? root.player.length : 1
                value: root.player ? root.player.position : 0
                enabled: root.hasLength && root.player.canSeek
                // seek once on release, not on every mouse move
                live: false
                onPressedChanged: if (!pressed) root.player.position = valueAt(position)
            }
            StyledText {
                text: Format.duration(root.hasLength ? root.player.length : 0)
                color: Theme.textTertiary
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 48
            }
        }
    }
}
