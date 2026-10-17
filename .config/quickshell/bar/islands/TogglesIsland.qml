import QtQuick
import qs.theme
import qs.services
import qs.widgets

Island {
    signal notificationsClicked()
    hoverable: false

    IconButton {
        text: PowerMode.icon(PowerMode.current)
        onClicked: PowerMode.cycle()
    }

    IconButton {
        text: Notifs.dnd ? Icons.bellDnd : Notifs.unread ? Icons.bell : Icons.bellIdle
        baseColor: Notifs.unread ? Theme.gold : Theme.textSecondary
        onClicked: m => m.button === Qt.RightButton ? (Notifs.dnd = !Notifs.dnd) : notificationsClicked()
    }

    IconButton {
        text: Caffeine.active ? Icons.caffeineOn : Icons.caffeineOff
        baseColor: Caffeine.active ? Theme.gold : Theme.textSecondary
        onClicked: Caffeine.active = !Caffeine.active
    }

    IconButton {
        text: Icons.shutdown
        onClicked: Panels.powerMenuRequested()
    }
}
