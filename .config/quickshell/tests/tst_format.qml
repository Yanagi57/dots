import QtQuick
import QtTest
import "../lib/format.js" as Format

TestCase {
    name: "Format"

    function test_temp() {
        compare(Format.temp(47.375), "47°")
        compare(Format.temp(null), "--")
    }
    function test_percent() {
        compare(Format.percent(8.4), "8%")
        compare(Format.percent(undefined), "--")
    }
    function test_gib() {
        compare(Format.gib(3.456), "3.5G")
        compare(Format.gib(null), "--")
    }
    function test_truncate() {
        compare(Format.truncate("abc", 30), "abc")
        compare(Format.truncate("abcdef", 4), "abc…")
        compare(Format.truncate("ab\u{1F3B5}\u{1F3B5}x", 4), "ab\u{1F3B5}…")
    }
    function test_level() {
        const l = ["a", "b", "c"]
        compare(Format.level(l, 0), "a")
        compare(Format.level(l, 0.5), "b")
        compare(Format.level(l, 1), "c")
        compare(Format.level(l, 1.5), "c")
        compare(Format.level(l, NaN), "a")
        compare(Format.level(l, undefined), "a")
    }
    function test_duration() {
        compare(Format.duration(0), "0:00")
        compare(Format.duration(65.9), "1:05")
        compare(Format.duration(3725), "1:02:05")
        compare(Format.duration(-3), "0:00")
    }
    function test_toPercent() {
        compare(Format.toPercent(0.62), 62)
        compare(Format.toPercent(62), 62)
        compare(Format.toPercent(null), null)
    }
}
