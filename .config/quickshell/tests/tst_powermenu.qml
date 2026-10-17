import QtQuick
import QtTest
import "../lib/powermenu.js" as PM

TestCase {
    name: "PowerMenu"

    function test_actions() {
        compare(PM.actions.map(a => a.id), ["lock", "logout", "suspend", "hibernate", "reboot", "shutdown"])
        compare(PM.actions.map(a => a.key).join(""), "louhrs")
    }
    function test_indexForKey() {
        compare(PM.indexForKey("l"), 0)
        compare(PM.indexForKey("S"), 5)
        compare(PM.indexForKey("x"), -1)
        compare(PM.indexForKey(""), -1)
    }
    function test_labelParts() {
        compare(PM.labelParts(PM.actions[0]), { before: "", key: "L", after: "ock" })
        compare(PM.labelParts(PM.actions[1]), { before: "L", key: "o", after: "gout" })
        compare(PM.labelParts(PM.actions[2]), { before: "S", key: "u", after: "spend" })
    }
}
