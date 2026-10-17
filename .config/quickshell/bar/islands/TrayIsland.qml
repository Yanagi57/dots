import Quickshell.Services.SystemTray
import QtQuick
import qs.theme
import qs.widgets

// Left click: activate (or menu for menu-only items). Right click: menu.
Island {
    id: root
    required property var bar

    hoverable: false
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items.values

        delegate: Image {
            id: trayIcon
            required property var modelData

            source: modelData.icon
            sourceSize: Qt.size(16, 16)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: m => {
                    const item = trayIcon.modelData
                    if (m.button === Qt.LeftButton && !item.onlyMenu) {
                        item.activate()
                        return
                    }
                    if (!item.hasMenu) return
                    const p = trayIcon.mapToItem(null, 0, trayIcon.height + 6)
                    item.display(root.bar, p.x, p.y)
                }
            }
        }
    }
}
