import Quickshell
import QtQuick
import qs.theme
import qs.widgets

Island {
    SystemClock { id: clock; precision: SystemClock.Minutes }

    StyledText { text: Icons.clock; color: Theme.gold }
    StyledText {
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Theme.gold
        font.bold: true
    }
}
