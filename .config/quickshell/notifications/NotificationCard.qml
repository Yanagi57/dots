import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import "../lib/notifs.js" as NotifLib

// One notification, used by the popup stack (popup: true) and the history list.
// Popup: auto-hides after its timeout (restarted while hovered); ✕ hides the popup only.
// History: shows age; ✕ dismisses. Click runs the default action if there is one.
Rectangle {
    id: root
    required property var notif
    property bool popup: false
    property real now: Date.now()

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property var defaultAction: notif.actions.find(a => a.identifier === "default") ?? null
    readonly property var buttons: notif.actions.filter(a => a.identifier !== "default")
    readonly property string iconSource: NotifLib.iconUrl(notif.image, notif.appIcon)
        || (notif.appIcon !== "" ? Quickshell.iconPath(notif.appIcon, true) : "")

    implicitWidth: 400
    implicitHeight: content.implicitHeight + 2 * Theme.padding
    radius: Theme.radiusPopup
    color: Theme.surface
    border.color: Theme.border
    border.width: 1

    Rectangle {
        visible: root.critical
        width: 3
        radius: 2
        color: Theme.error
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 6 }
    }

    HoverHandler { id: hover }

    Timer {
        interval: Notifs.timeoutFor(root.notif)
        running: root.popup && interval > 0 && !hover.hovered
        onTriggered: Notifs.hidePopup(root.notif)
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: {
            if (root.defaultAction) root.defaultAction.invoke()
            else if (root.popup) Notifs.hidePopup(root.notif)
        }
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: Theme.padding; leftMargin: Theme.padding + 4 }
        spacing: 10

        IconImage {
            Layout.alignment: Qt.AlignTop
            visible: root.iconSource !== ""
            source: root.iconSource
            implicitSize: 36
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: root.notif.summary
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                StyledText {
                    visible: !root.popup
                    text: NotifLib.ago(Notifs.arrivals[root.notif.id] ?? root.now, root.now)
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                }
                IconButton {
                    text: Icons.close
                    onClicked: root.popup ? Notifs.hidePopup(root.notif) : root.notif.dismiss()
                }
            }

            StyledText {
                visible: text !== ""
                text: root.notif.body
                textFormat: Text.StyledText
                wrapMode: Text.Wrap
                maximumLineCount: 3
                elide: Text.ElideRight
                color: Theme.textSecondary
                linkColor: Theme.teal
                Layout.fillWidth: true
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                visible: root.buttons.length > 0
                spacing: 6
                Layout.fillWidth: true
                Layout.topMargin: 4

                Repeater {
                    model: root.buttons
                    ToggleChip {
                        required property var modelData
                        text: modelData.text
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }
}
