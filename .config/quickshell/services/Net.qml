pragma Singleton
import Quickshell
import Quickshell.Networking
import QtQuick
import "../lib/format.js" as Format

// What the bar needs from Networking: wired > wifi > none.
Singleton {
    readonly property var devices: Networking.devices.values
    readonly property var wired: devices.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wifiNetwork: wifiDevice ? (wifiDevice.networks.values.find(n => n.connected) ?? null) : null

    readonly property string kind: wired ? "wired" : wifiNetwork ? "wifi" : "none"
    readonly property var strength: wifiNetwork ? Format.toPercent(wifiNetwork.signalStrength) : null
    readonly property string ssid: wifiNetwork ? wifiNetwork.name : ""
}
