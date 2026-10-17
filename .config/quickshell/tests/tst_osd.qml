import QtQuick
import QtTest
import "../lib/osd.js" as OsdLib

TestCase {
    name: "Osd"

    function test_volumeState() {
        compare(OsdLib.volumeState(0.5, false), { level: "mid", fraction: 0.5, text: "50%" })
        compare(OsdLib.volumeState(0.2, false), { level: "low", fraction: 0.2, text: "20%" })
        compare(OsdLib.volumeState(0.9, false), { level: "high", fraction: 0.9, text: "90%" })
        compare(OsdLib.volumeState(1.2, false), { level: "high", fraction: 1, text: "120%" })
        compare(OsdLib.volumeState(0.5, true), { level: "muted", fraction: 0.5, text: "muted" })
        compare(OsdLib.volumeState(0, false), { level: "muted", fraction: 0, text: "0%" })
    }
    function test_parseBrightnessctl() {
        compare(OsdLib.parseBrightnessctl("intel_backlight,backlight,12000,50%,24000\n"), 0.5)
        compare(OsdLib.parseBrightnessctl("enp8s0-2::lan,leds,0,0%,255"), null)
        compare(OsdLib.parseBrightnessctl(""), null)
    }
}
