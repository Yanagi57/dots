import QtQuick
import QtTest
import "../lib/hypr.js" as Hypr

TestCase {
    name: "Hypr"

    function test_focusWorkspace() {
        compare(Hypr.focusWorkspace(3), 'hl.dsp.focus({ workspace = 3 })')
        compare(Hypr.focusWorkspace("m+1"), 'hl.dsp.focus({ workspace = "m+1" })')
    }
    function test_focusWindow() {
        compare(Hypr.focusWindow("55bdc0f35470"), 'hl.dsp.focus({ window = "address:0x55bdc0f35470" })')
    }
    function test_moveWindow() {
        compare(Hypr.moveWindow("0xabc", 4), 'hl.dsp.window.move({ workspace = 4, window = "address:0xabc", follow = false })')
    }
    function test_rejectsUnsafe() {
        compare(Hypr.focusWindow('x" }) hl.dsp.exit() --'), "")
        compare(Hypr.focusWorkspace('1" }) hl.dsp.exit() --'), "")
        compare(Hypr.moveWindow("abc", "2; x"), "")
    }
}
