import Quickshell
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
// password (new WPA/SAE network). Enterprise networks need the full settings app. Scans while
// `active`. The password field lives outside the rows so scan updates can't wipe it.
ColumnLayout {
    id: root
    property bool active: false
    property var passwordNet: null      // network awaiting a password
    property string failedFor: ""       // network name whose last attempt failed
    property string settingsFor: ""     // enterprise network the user clicked

    readonly property var device: Net.wifiDevice
    readonly property var networks: device ? NetLib.sortNetworks(device.networks.values, 8) : []

    function usesPsk(net) {
        return net.security === WifiSecurityType.Wpa2Psk || net.security === WifiSecurityType.WpaPsk
            || net.security === WifiSecurityType.Sae
    }
    function isOpen(net) { return net.security === WifiSecurityType.Open || net.security === WifiSecurityType.Owe }

    function activate(net) {
        failedFor = ""
        settingsFor = ""
        if (net.connected) net.disconnect()
        else if (net.known || isOpen(net)) net.connect()
        else if (usesPsk(net)) passwordNet = passwordNet === net ? null : net
        else settingsFor = net.name
    }

    function submitPassword(text) {
        if (passwordNet && text !== "") passwordNet.connectWithPsk(text)
        passwordNet = null
    }

    spacing: 2

    Binding {
        target: root.device
        property: "scannerEnabled"
        value: root.active
        when: root.device !== null
    }

    Connections {
        target: root.passwordNet
        function onConnectionFailed() { root.failedFor = root.passwordNet ? root.passwordNet.name : "" }
    }

    StyledText {
        visible: root.networks.length === 0
        text: Networking.wifiEnabled ? "Scanning…" : "Wi-Fi is off"
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
        // ScriptModel keeps rows alive across scan updates instead of rebuilding them all
        model: ScriptModel { values: root.networks }

        Rectangle {
            id: row
            required property var modelData
            readonly property var net: modelData
            readonly property string status: net.stateChanging ? "Connecting…"
                : root.failedFor === net.name ? "Failed"
                : root.settingsFor === net.name ? "Use network settings"
                : net.connected ? "Connected"
                : ""

            Layout.fillWidth: true
            implicitHeight: 34
            radius: 8
            color: area.containsMouse || root.passwordNet === net ? Theme.elevated : "transparent"

            Connections {
                target: row.net
                function onConnectionFailed() { root.failedFor = row.net.name }
            }

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
                    visible: !root.isOpen(row.net)
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
                onClicked: root.activate(row.net)
            }
        }
    }

    TextField {
        id: psk
        visible: root.passwordNet !== null
        Layout.fillWidth: true
        Layout.topMargin: 4
        echoMode: TextInput.Password
        placeholderText: root.passwordNet ? "Password for " + root.passwordNet.name : ""
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
        onVisibleChanged: {
            text = ""
            if (visible) forceActiveFocus()
        }
        onAccepted: root.submitPassword(text)
        Keys.onEscapePressed: e => {
            root.passwordNet = null
            e.accepted = true
        }
    }
}
