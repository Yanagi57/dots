import QtQuick
import QtTest
import "../lib/fuzzy.js" as Fuzzy

TestCase {
    name: "Fuzzy"

    function test_empty() { compare(Fuzzy.score("", "Firefox"), 0) }
    function test_noMatch() { compare(Fuzzy.score("xyz", "Firefox"), -1) }
    function test_subsequence() { verify(Fuzzy.score("ff", "Firefox") > 0) }
    function test_prefixBeatsMiddle() {
        verify(Fuzzy.score("fire", "Firefox") > Fuzzy.score("fire", "Campfire"))
    }
    function test_wordStarts() {
        verify(Fuzzy.score("vc", "VS Code") > Fuzzy.score("vc", "Vacation"))
    }
    function test_caseInsensitive() {
        compare(Fuzzy.score("FIRE", "firefox"), Fuzzy.score("fire", "firefox"))
    }
}
