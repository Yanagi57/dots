import QtQuick
import QtTest
import "../lib/launcher.js" as L

TestCase {
    name: "Launcher"

    readonly property var sample: [
        { emoji: "😀", description: "grinning face smile" },
        { emoji: "🔥", description: "fire hot flame" },
    ]

    function test_parseQuery() {
        compare(L.parseQuery("=2+2"), { mode: "calc", term: "2+2" })
        compare(L.parseQuery(": fire"), { mode: "emoji", term: "fire" })
        compare(L.parseQuery("fire"), { mode: "apps", term: "fire" })
        compare(L.parseQuery(""), { mode: "apps", term: "" })
    }
    function test_prefixFor() {
        compare(L.prefixFor("calc"), "=")
        compare(L.prefixFor("emoji"), ":")
        compare(L.prefixFor("apps"), "")
    }
    function test_parseEmoji() {
        compare(L.parseEmoji("😀 grinning face smile\n\n🔥 fire hot flame\n"), sample)
    }
    function test_filterEmoji() {
        compare(L.filterEmoji(sample, "fire", 10), [sample[1]])
        compare(L.filterEmoji(sample, "face SMILE", 10), [sample[0]])
        compare(L.filterEmoji(sample, "", 10), sample)
        compare(L.filterEmoji(sample, "", 1), [sample[0]])
        compare(L.filterEmoji(sample, "nope", 10), [])
    }
}
