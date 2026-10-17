import QtQuick
import QtTest
import "../lib/frecency.js" as Frecency

TestCase {
    name: "Frecency"

    readonly property real day: 86400000

    function test_record() {
        const a = Frecency.record({}, "kitty", 100)
        compare(a, { kitty: { count: 1, last: 100 } })
        const b = Frecency.record(a, "kitty", 200)
        compare(b, { kitty: { count: 2, last: 200 } })
        compare(a, { kitty: { count: 1, last: 100 } })
    }
    function test_boost_none() { compare(Frecency.boost({}, "kitty", 0), 0) }
    function test_boost_counts() {
        fuzzyCompare(Frecency.boost({ k: { count: 1, last: 0 } }, "k", 0), 1, 1e-9)
        fuzzyCompare(Frecency.boost({ k: { count: 3, last: 0 } }, "k", 0), 2, 1e-9)
    }
    function test_boost_decay() {
        fuzzyCompare(Frecency.boost({ k: { count: 1, last: 0 } }, "k", 14 * day), 0.5, 1e-9)
    }
}
