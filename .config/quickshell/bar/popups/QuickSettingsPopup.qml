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

            Slider {
                id: volume
                Layout.preferredWidth: 220
                from: 0
                to: 1
                value: root.audio ? root.audio.volume : 0
                onMoved: if (root.audio) root.audio.volume = value

                background: Rectangle {
                    x: volume.leftPadding
                    y: volume.topPadding + volume.availableHeight / 2 - height / 2
                    width: volume.availableWidth
                    height: 4
                    radius: 2
                    color: Theme.border

                    Rectangle {
                        width: volume.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: Theme.gold
                    }
                }

                handle: Rectangle {
                    x: volume.leftPadding + volume.visualPosition * (volume.availableWidth - width)
                    y: volume.topPadding + volume.availableHeight / 2 - height / 2
                    width: 14
                    height: 14
                    radius: 7
                    color: volume.pressed ? Theme.goldDim : Theme.gold
                }
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
