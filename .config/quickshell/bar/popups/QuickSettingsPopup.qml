import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

BarPopup {
    id: root
    name: "quick"

    property bool wifiOpen: false
    property bool bluetoothOpen: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property var adapter: Bluetooth.defaultAdapter

    function launch(cmd) {
        Quickshell.execDetached(cmd)
        close()
    }

    PwObjectTracker { objects: [root.sink] }

    ColumnLayout {
        spacing: 10

        // Volume
        RowLayout {
            spacing: Theme.spacing

            IconButton {
                text: root.audio && root.audio.muted ? Icons.volumeMuted : Icons.volumeHigh
                baseColor: Theme.gold
                onClicked: if (root.audio) root.audio.muted = !root.audio.muted
            }

            StyledSlider {
                Layout.preferredWidth: 220
                from: 0
                to: 1
                value: root.audio ? root.audio.volume : 0
                onMoved: if (root.audio) root.audio.volume = value
            }

            StyledText {
                text: root.audio ? Format.percent(root.audio.volume * 100) : "--"
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 40
            }
        }

        // Radios
        RowLayout {
            spacing: Theme.spacing
            ToggleChip {
                visible: root.adapter !== null
                text: Icons.bluetooth + "  Bluetooth"
                checked: root.adapter ? root.adapter.enabled : false
                onClicked: root.adapter.enabled = !root.adapter.enabled
            }
            ToggleChip {
                visible: Net.wifiDevice !== null
                text: Icons.wifi + "  Wi-Fi"
                checked: Networking.wifiEnabled
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
        }

        // Wi-Fi networks
        RowLayout {
            visible: Net.wifiDevice !== null
            Layout.fillWidth: true
            StyledText {
                text: "Wi-Fi networks"
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                Layout.fillWidth: true
            }
            IconButton {
                text: root.wifiOpen ? Icons.chevronUp : Icons.chevronDown
                onClicked: root.wifiOpen = !root.wifiOpen
            }
        }
        WifiList {
            visible: root.wifiOpen && Net.wifiDevice !== null
            active: visible && root.open
            Layout.fillWidth: true
            Layout.preferredWidth: 360
        }

        // Bluetooth devices
        RowLayout {
            visible: root.adapter !== null
            Layout.fillWidth: true
            StyledText {
                text: "Bluetooth devices"
                color: Theme.textSecondary
                font.pixelSize: Theme.fontSizeSmall
                Layout.fillWidth: true
            }
            IconButton {
                text: root.bluetoothOpen ? Icons.chevronUp : Icons.chevronDown
                onClicked: root.bluetoothOpen = !root.bluetoothOpen
            }
        }
        BluetoothList {
            visible: root.bluetoothOpen && root.adapter !== null
            active: visible && root.open
            Layout.fillWidth: true
            Layout.preferredWidth: 360
        }

        // Power profile
        StyledText { text: "Power profile"; color: Theme.textSecondary; font.pixelSize: Theme.fontSizeSmall }
        RowLayout {
            spacing: Theme.spacing
            Repeater {
                model: PowerMode.available
                ToggleChip {
                    required property int modelData
                    text: PowerMode.icon(modelData) + "  " + PowerMode.name(modelData)
                    checked: PowerMode.current === modelData
                    onClicked: PowerMode.set(modelData)
                }
            }
        }

        // Full settings apps
        RowLayout {
            spacing: Theme.spacing
            ToggleChip { text: "Sound"; onClicked: root.launch(["pavucontrol"]) }
            ToggleChip { text: "Bluetooth"; onClicked: root.launch(["blueman-manager"]) }
            ToggleChip { text: "Network"; onClicked: root.launch(["nm-connection-editor"]) }
        }
    }
}
