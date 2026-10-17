import QtQuick
import QtTest
import "../lib/workspaces.js" as WS

TestCase {
    name: "Workspaces"

    function mon(n) { return { name: n } }

    function test_filter_and_sort() {
        const list = [
            { id: 3, monitor: mon("A") },
            { id: -98, monitor: mon("A") },
            { id: 1, monitor: mon("A") },
            { id: 2, monitor: mon("B") },
        ]
        compare(WS.visible(list, "A").map(w => w.id), [1, 3, -98])
    }
    function test_no_monitor() {
        compare(WS.visible([{ id: 1, monitor: null }], "A"), [])
    }
}
