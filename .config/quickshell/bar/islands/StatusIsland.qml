import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import QtQuick
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

// Volume, Bluetooth, network, battery. Click opens quick settings (wired in Bar).
Island {
    id: root
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var battery: UPower.displayDevice
    readonly property var batteryPct: Format.toPercent(battery.percentage)

    // audio properties are only valid on tracked nodes
    PwObjectTracker { objects: [root.sink] }

    Metric {
        ok: root.audio !== null
        icon: !root.audio || root.audio.muted ? Icons.volumeMuted
            : Format.level([Icons.volumeLow, Icons.volumeMid, Icons.volumeHigh], root.audio.volume)
        text: !root.audio ? "--" : root.audio.muted ? "muted" : Format.percent(root.audio.volume * 100)
    }

    Metric {
        visible: root.adapter !== null
        icon: root.adapter && root.adapter.enabled ? Icons.bluetooth : Icons.bluetoothOff
        text: !root.adapter || !root.adapter.enabled ? "off"
            : String(root.adapter.devices.values.filter(d => d.connected).length)
    }

    Metric {
        ok: Net.kind !== "none"
        icon: Net.kind === "wired" ? Icons.ethernet : Net.kind === "wifi" ? Icons.wifi : Icons.wifiOff
        text: Net.kind === "wifi" ? Format.percent(Net.strength) : ""
    }

    Metric {
        visible: root.battery.isLaptopBattery
        accent: root.batteryPct <= 15 ? Theme.error : root.batteryPct <= 30 ? Theme.warning : Theme.textSecondary
        icon: root.battery.state === UPowerDeviceState.Charging ? Icons.batteryCharging
            : root.battery.state === UPowerDeviceState.FullyCharged ? Icons.batteryPlugged
            : Format.level(Icons.battery, root.batteryPct / 100)
        text: Format.percent(root.batteryPct)
    }
}
