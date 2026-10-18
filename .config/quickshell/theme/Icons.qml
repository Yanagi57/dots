pragma Singleton
import Quickshell
import QtQuick

// Nerd Font glyphs, by codepoint so the source stays readable.
Singleton {
    function g(cp) { return String.fromCodePoint(cp) }

    readonly property string clock: g(0xF017)
    readonly property string cpuTemp: g(0xF2DB)
    readonly property string cpu: g(0xF2DB)
    readonly property string gpu: g(0xF11B)
    readonly property string nvme: g(0xF0A0)
    readonly property string memory: g(0xF035B)

    readonly property string volumeLow: g(0xF026)
    readonly property string volumeMid: g(0xF027)
    readonly property string volumeHigh: g(0xF028)
    readonly property string volumeMuted: g(0xF0581)

    readonly property string bluetooth: g(0xF294)
    readonly property string bluetoothOff: g(0xF00B2)
    readonly property string wifi: g(0xF1EB)
    readonly property string wifiOff: g(0xF092E)
    readonly property string ethernet: g(0xF0200)

    readonly property string batteryCharging: g(0xF0084)
    readonly property string batteryPlugged: g(0xF06A5)
    // empty → full
    readonly property var battery: [g(0xF007A), g(0xF007B), g(0xF007C), g(0xF007D), g(0xF007E),
                                    g(0xF007F), g(0xF0080), g(0xF0081), g(0xF0082), g(0xF0079)]

    readonly property string bell: g(0xF009A)       // unread
    readonly property string bellIdle: g(0xF009C)   // nothing new
    readonly property string bellDnd: g(0xF009B)

    readonly property string caffeineOn: g(0xF0F4)
    readonly property string caffeineOff: g(0xF2FE)

    readonly property string powerSaver: g(0xF0F86)
    readonly property string balanced: g(0xF0F85)
    readonly property string performance: g(0xF140B)

    // power menu (looked up as Icons[action.id]) + bar button
    readonly property string lock: g(0xF033E)
    readonly property string logout: g(0xF0343)
    readonly property string suspend: g(0xF0904)
    readonly property string hibernate: g(0xF0717)
    readonly property string reboot: g(0xF0709)
    readonly property string shutdown: g(0xF0425)

    readonly property string play: "▶"
    readonly property string pause: g(0xF04C)
    readonly property string spotify: g(0xF1BC)
    readonly property string firefox: g(0xF0239)
    readonly property string close: "✕"
    readonly property string previous: g(0xF04AE)
    readonly property string next: g(0xF04AD)
    readonly property string music: g(0xF075A)
    readonly property string mic: g(0xF036C)
    readonly property string micOff: g(0xF036D)
    readonly property string brightness: g(0xF00DF)
    readonly property string chevronDown: g(0xF0140)
    readonly property string chevronUp: g(0xF0143)
    readonly property string check: "\u2713"
    readonly property string radio: "\u25CF"
}
