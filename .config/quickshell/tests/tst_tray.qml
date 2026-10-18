import QtQuick
import QtTest
import "../lib/tray.js" as Tray

TestCase {
    name: "Tray"

    function test_stripMnemonic() {
        compare(Tray.stripMnemonic("_Library"), "Library")
        compare(Tray.stripMnemonic("E_xit Steam"), "Exit Steam")
        compare(Tray.stripMnemonic("snake__case"), "snake_case")
        compare(Tray.stripMnemonic("Plain"), "Plain")
        compare(Tray.stripMnemonic(""), "")
    }
}
