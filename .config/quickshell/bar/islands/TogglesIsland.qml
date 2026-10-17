import QtQuick
import qs.theme
import qs.services
import qs.widgets

Island {
    hoverable: false

    IconButton {
        text: PowerMode.icon(PowerMode.current)
        onClicked: PowerMode.cycle()
    }

    IconButton {
        text: NotifBridge.dnd ? Icons.bellDnd : NotifBridge.unread ? Icons.bell : Icons.bellIdle
        baseColor: NotifBridge.unread ? Theme.gold : Theme.textSecondary
        onClicked: m => m.button === Qt.RightButton ? NotifBridge.toggleDnd() : NotifBridge.toggleCenter()
    }

    IconButton {
        text: Caffeine.active ? Icons.caffeineOn : Icons.caffeineOff
        baseColor: Caffeine.active ? Theme.gold : Theme.textSecondary
        onClicked: Caffeine.active = !Caffeine.active
    }
}
