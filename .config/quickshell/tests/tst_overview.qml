import QtQuick
import QtTest
import "../lib/overview.js" as Ov
import "../lib/grid.js" as Grid

TestCase {
    name: "Overview"

    function test_thumbRect() {
        compare(Ov.thumbRect([6, 72], [1908, 1002], { x: 0, y: 0 }, 0.5), { x: 3, y: 36, width: 954, height: 501 })
        compare(Ov.thumbRect([1926, 72], [100, 50], { x: 1920, y: 0 }, 0.5), { x: 3, y: 36, width: 50, height: 25 })
    }
    function test_workspaceForKey() {
        compare(Ov.workspaceForKey("1"), 1)
        compare(Ov.workspaceForKey("9"), 9)
        compare(Ov.workspaceForKey("0"), 10)
        compare(Ov.workspaceForKey("a"), -1)
        compare(Ov.workspaceForKey(""), -1)
    }
    function test_hyprAddress() {
        compare(Ov.hyprAddress("55bdc0f35470"), "0x55bdc0f35470")
        compare(Ov.hyprAddress("0x55bdc0f35470"), "0x55bdc0f35470")
    }
    function test_gridMove() {
        compare(Grid.move(0, 1, 0, 5, 10), 1)
        compare(Grid.move(4, 1, 0, 5, 10), 4)
        compare(Grid.move(2, 0, 1, 5, 10), 7)
        compare(Grid.move(7, 0, 1, 5, 10), 7)
    }
}
