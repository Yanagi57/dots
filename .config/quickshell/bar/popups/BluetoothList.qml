import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../../lib/net.js" as NetLib
import "../../lib/format.js" as Format

// Paired and nearby Bluetooth devices. Click: connect / disconnect, or pair (then trust +
// connect). Discovers while `active`.
ColumnLayout {
    id: root
    property bool active: false
    property var pairingDev: null    // the device the user asked to pair

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter ? NetLib.sortDevices(adapter.devices.values) : []

    function activate(d) {
        if (d.connected) d.disconnect()
        else if (d.paired) d.connect()
        else {
            pairingDev = d
            d.pair()
        }
    }

    Connections {
        target: root.pairingDev
        function onPairedChanged() {
            const d = root.pairingDev
            if (!d.paired) return
            root.pairingDev = null
            d.trusted = true
            d.connect()
        }
    }

    spacing: 2

    Binding {
        target: root.adapter
        property: "discovering"
        value: root.active
        when: root.adapter !== null && root.adapter.enabled
    }

    StyledText {
        visible: root.devices.length === 0
        text: root.adapter && root.adapter.enabled ? "Searching…" : "Bluetooth is off"
        color: Theme.textTertiary
        font.pixelSize: Theme.fontSizeSmall
    }

    Repeater {
        // ScriptModel keeps rows alive across updates instead of rebuilding them all
        model: ScriptModel { values: root.devices }

        Rectangle {
            id: row
            required property var modelData
            readonly property var dev: modelData
            readonly property string status: dev.pairing ? "Pairing…"
                : dev.state === BluetoothDeviceState.Connecting ? "Connecting…"
                : dev.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                : dev.connected ? "Connected"
                : dev.paired ? "Paired"
                : "Pair"

            Layout.fillWidth: true
            implicitHeight: 34
            radius: 8
            color: area.containsMouse ? Theme.elevated : "transparent"

            RowLayout {
                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                spacing: 8

                StyledText { text: Icons.bluetooth; color: row.dev.connected ? Theme.gold : Theme.textSecondary }
                StyledText {
                    text: row.dev.name
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                StyledText {
                    visible: row.dev.connected && row.dev.batteryAvailable
                    text: Format.percent(Format.toPercent(row.dev.battery))
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                }
                StyledText {
                    text: row.status
                    color: row.status === "Pair" ? Theme.teal : Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.activate(row.dev)
            }
        }
    }
}
