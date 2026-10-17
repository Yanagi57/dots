import Quickshell.Services.Mpris
import QtQuick
import qs.theme
import qs.widgets
import "../../lib/media.js" as Media
import "../../lib/format.js" as Format

// Current track. Click: media popup (wired in Bar). Middle click: play/pause. Right click: next.
Island {
    id: root
    readonly property var player: Media.pick(Mpris.players.values)
    signal popupRequested()

    visible: player !== null && player.trackTitle !== ""
    onClicked: m => {
        if (m.button === Qt.MiddleButton) player.togglePlaying()
        else if (m.button === Qt.RightButton) player.next()
        else popupRequested()
    }

    StyledText {
        text: root.player && root.player.isPlaying ? Icons[Media.iconKey(root.player)] : Icons.pause
        color: Theme.gold
    }
    StyledText {
        text: root.player ? Format.truncate(root.player.trackTitle, 30) : ""
        font.italic: root.player !== null && !root.player.isPlaying
        color: Theme.textSecondary
    }
}
