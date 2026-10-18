import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Effects
import qs.theme
import qs.widgets

// Left click: activate (or menu for menu-only items). Right click: menu (TrayMenuPopup, via Bar).
Island {
    id: root
    signal menuRequested(var item, Item anchor)

    hoverable: false
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items.values

        delegate: Image {
            id: trayIcon
            required property var modelData

            source: modelData.icon
            sourceSize: Qt.size(16, 16)

            // symbolic icons are drawn dark grey; tint them to fit the bar
            layer.enabled: modelData.icon.indexOf("symbolic") !== -1
            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: Theme.textSecondary
                brightness: 1
            }

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
                    if (item.hasMenu) root.menuRequested(item, trayIcon)
                }
            }
        }
    }
}
