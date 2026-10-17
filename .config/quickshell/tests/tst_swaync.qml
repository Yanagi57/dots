import QtQuick
import QtTest
import "../lib/swaync.js" as SwayncParse

TestCase {
    name: "Swaync"

    function test_states() {
        compare(SwayncParse.parseStatus('{"text":"1","alt":"notification","class":["notification"]}'), { unread: true, dnd: false })
        compare(SwayncParse.parseStatus('{"text":"0","alt":"none"}'), { unread: false, dnd: false })
        compare(SwayncParse.parseStatus('{"alt":"dnd-notification"}'), { unread: true, dnd: true })
        compare(SwayncParse.parseStatus('{"alt":"dnd-none"}'), { unread: false, dnd: true })
        compare(SwayncParse.parseStatus('{"alt":"inhibited-notification"}'), { unread: true, dnd: false })
    }
    function test_bad() {
        compare(SwayncParse.parseStatus("garbage"), null)
        compare(SwayncParse.parseStatus('{"text":"x"}'), null)
    }
}
