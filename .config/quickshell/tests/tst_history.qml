import QtQuick
import QtTest
import "../lib/history.js" as History

TestCase {
    name: "History"

    function test_push() {
        compare(History.push([1, 2], 3, 3), [1, 2, 3])
        compare(History.push([1, 2, 3], 4, 3), [2, 3, 4])
        const src = [1]
        History.push(src, 2, 3)
        compare(src, [1])
    }
    function test_points_empty() {
        compare(History.points([], 100, 20, 5), [])
        compare(History.points([null], 100, 20, 5), [])
    }
    function test_points_scaled() {
        compare(History.points([10, 20], 100, 20, 5), [{ x: 75, y: 18 }, { x: 100, y: 2 }])
    }
    function test_points_flat() {
        compare(History.points([5, 5], 100, 20, 5), [{ x: 75, y: 10 }, { x: 100, y: 10 }])
    }
    function test_points_skip_null() {
        compare(History.points([10, null, 20], 100, 20, 3), [{ x: 0, y: 18 }, { x: 100, y: 2 }])
    }
}
