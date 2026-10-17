import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import qs.notifications

BarPopup {
    id: root
    name: "notifications"

    // also on close, so anything that arrived while it was open counts as seen
    onOpenChanged: Notifs.markRead()

    SystemClock { id: clock; precision: SystemClock.Minutes }

    ColumnLayout {
        width: 420
        spacing: Theme.spacing

        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: "Notifications"
                color: Theme.gold
                font.bold: true
                Layout.fillWidth: true
            }
            ToggleChip {
                text: Icons.bellDnd + "  DND"
                checked: Notifs.dnd
                onClicked: Notifs.dnd = !Notifs.dnd
            }
        }

        StyledText {
            visible: Notifs.list.length === 0
            text: "No notifications"
            color: Theme.textTertiary
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 12
            Layout.bottomMargin: 12
        }

        ListView {
            visible: Notifs.list.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, 480)
            clip: true
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            model: ScriptModel { values: Notifs.list }

            delegate: NotificationCard {
                required property var modelData
                notif: modelData
                now: clock.date.getTime()
                width: ListView.view.width
            }
        }

        ToggleChip {
            visible: Notifs.list.length > 0
            text: "Clear all"
            Layout.alignment: Qt.AlignRight
            onClicked: Notifs.clearAll()
        }
    }
}
