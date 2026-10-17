import QtQuick
import QtTest
import "../lib/lock.js" as LockLib

TestCase {
    name: "Lock"

    function test_resultMessage() {
        compare(LockLib.resultMessage("Success"), "")
        compare(LockLib.resultMessage("Failed"), "Incorrect password")
        compare(LockLib.resultMessage("MaxTries"), "Too many attempts, try again later")
        compare(LockLib.resultMessage("Error"), "Authentication error")
        compare(LockLib.resultMessage("???"), "Authentication error")
    }
    function test_backspace() {
        compare(LockLib.backspace("abc"), "ab")
        compare(LockLib.backspace("a\u{1F511}"), "a")
        compare(LockLib.backspace(""), "")
    }
}
