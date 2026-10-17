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
    function test_move() {
        compare(PM.move(0, 1, 0, 3, 6), 1)
        compare(PM.move(2, 1, 0, 3, 6), 2)
        compare(PM.move(0, 0, 1, 3, 6), 3)
        compare(PM.move(4, 0, 1, 3, 6), 4)
        compare(PM.move(0, -1, 0, 3, 6), 0)
        compare(PM.move(3, 0, -1, 3, 6), 0)
    }
}
