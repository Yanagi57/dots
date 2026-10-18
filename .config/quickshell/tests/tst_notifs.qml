import QtQuick
import QtTest
import "../lib/notifs.js" as N

TestCase {
    name: "Notifs"

    function test_timeoutFor() {
        compare(N.timeoutFor("critical", 5000), 0)
        compare(N.timeoutFor("low", 0), 4000)
        compare(N.timeoutFor("normal", -1), 8000)
        compare(N.timeoutFor("normal", 3000), 3000)
        compare(N.timeoutFor("low", 3000), 3000)
    }
    function test_ago() {
        compare(N.ago(0, 30000), "now")
        compare(N.ago(0, 5 * 60000), "5m")
        compare(N.ago(0, 3 * 3600000), "3h")
        compare(N.ago(0, 2 * 86400000), "2d")
        compare(N.ago(5000, 0), "now")
    }
    function test_stripImages() {
        compare(N.stripImages('hi <img src="http://t.example/p.gif"> there'), "hi  there")
        compare(N.stripImages('<b>a</b><IMG SRC=x/>b'), "<b>a</b>b")
        compare(N.stripImages("plain"), "plain")
    }
    function test_iconUrl() {
        compare(N.iconUrl("image://qsimage/1", "firefox"), "image://qsimage/1")
        compare(N.iconUrl("", "/usr/share/x.png"), "file:///usr/share/x.png")
        compare(N.iconUrl("", "file:///a.png"), "file:///a.png")
        compare(N.iconUrl("", "firefox"), "")
        compare(N.iconUrl("", ""), "")
        // Quickshell wraps the image-path hint as an icon lookup, even for file paths
        compare(N.iconUrl("image://icon//home/u/shot.png", ""), "file:///home/u/shot.png")
        compare(N.iconUrl("image://icon/file:///home/u/shot.png", ""), "file:///home/u/shot.png")
        compare(N.iconUrl("image://icon/dialog-information", ""), "image://icon/dialog-information")
    }
}
