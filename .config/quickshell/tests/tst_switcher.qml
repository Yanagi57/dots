import QtQuick
import QtTest
import "../lib/switcher.js" as Sw

TestCase {
    name: "Switcher"

    readonly property var clients: [
        { address: "0xa", class: "firefox", title: "YouTube", focusHistoryID: 2 },
        { address: "0xb", class: "kitty", title: "zsh", focusHistoryID: 0 },
        { address: "0xc", class: "firefox", title: "Docs", focusHistoryID: 1 },
        { address: "0xd", class: "discord", title: "chat", focusHistoryID: 3 },
        { address: "0xe", class: "", title: "ghost", focusHistoryID: 4 },
    ]

    function test_groupApps() {
        compare(Sw.groupApps(clients), [
            { cls: "kitty", address: "0xb", title: "zsh", count: 1 },
            { cls: "firefox", address: "0xc", title: "Docs", count: 2 },
            { cls: "discord", address: "0xd", title: "chat", count: 1 },
        ])
        compare(Sw.groupApps([]), [])
    }
    function test_step() {
        compare(Sw.step(0, 1, 3), 1)
        compare(Sw.step(2, 1, 3), 0)
        compare(Sw.step(0, -1, 3), 2)
        compare(Sw.step(0, 1, 0), 0)
    }
    function test_initialIndex() {
        compare(Sw.initialIndex(3), 1)
        compare(Sw.initialIndex(1), 0)
        compare(Sw.initialIndex(0), 0)
    }
}
