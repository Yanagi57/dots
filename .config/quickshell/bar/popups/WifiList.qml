import Quickshell.Networking
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import "../../lib/net.js" as NetLib
import "../../lib/format.js" as Format

// Nearby Wi-Fi networks. Click: connect (known/open), disconnect (connected), or ask for a
// password inline (new secured network). Scans while `active`.
ColumnLayout {
    id: root
    property bool active: false
    property string passwordFor: ""     // network name awaiting a password
    property string failedFor: ""       // network name whose last attempt failed

    readonly property var device: Net.wifiDevice
    readonly property var networks: device ? NetLib.sortNetworks(device.networks.values, 8) : []

    function activate(net, secured) {
        failedFor = ""
        if (net.connected) net.disconnect()
        else if (net.known || !secured) net.connect()
        else passwordFor = passwordFor === net.name ? "" : net.name
    }

    spacing: 2

    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.active
        when: root.device !== null
    }

    StyledText {
        visible: root.networks.length === 0
        text: Networking.wifiEnabled ? "Scanning…" : "Wi-Fi is off"
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
        model: root.networks

        ColumnLayout {
            id: row
            required property var modelData
            readonly property var net: modelData
            readonly property bool secured: net.security !== WifiSecurityType.Open && net.security !== WifiSecurityType.Owe
            readonly property string status: net.stateChanging ? "Connecting…"
                : root.failedFor === net.name ? "Failed"
                : net.connected ? "Connected"
                : ""

            Layout.fillWidth: true
            spacing: 4

            Connections {
                target: row.net
                function onConnectionFailed() { root.failedFor = row.net.name }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 34
                radius: 8
                color: area.containsMouse ? Theme.elevated : "transparent"

                RowLayout {
                    anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                    spacing: 8

                    StyledText { text: Icons.wifi; color: row.net.connected ? Theme.gold : Theme.textSecondary }
                    StyledText {
                        text: row.net.name
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    StyledText {
                        visible: row.status !== ""
                        text: row.status
                        color: row.status === "Failed" ? Theme.error : Theme.textTertiary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    StyledText {
                        visible: row.secured
                        text: Icons.lock
                        color: Theme.textTertiary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                    StyledText {
                        text: Format.percent(Format.toPercent(row.net.signalStrength))
                        color: Theme.textTertiary
                        font.pixelSize: Theme.fontSizeSmall
                    }
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activate(row.net, row.secured)
                }
            }

            TextField {
                id: psk
                visible: root.passwordFor === row.net.name
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password for " + row.net.name
                color: Theme.textPrimary
                placeholderTextColor: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                leftPadding: 10
                background: Rectangle {
                    implicitHeight: 32
                    radius: 8
                    color: Theme.base
                    border.color: psk.activeFocus ? Theme.goldDim : Theme.border
                    border.width: 1
                }
                onVisibleChanged: if (visible) forceActiveFocus()
                onAccepted: {
                    row.net.connectWithPsk(text)
                    root.passwordFor = ""
                    text = ""
                }
                Keys.onEscapePressed: e => {
                    root.passwordFor = ""
                    text = ""
                    e.accepted = true
                }
            }
        }
    }
}
