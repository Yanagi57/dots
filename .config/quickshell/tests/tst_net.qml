import QtQuick
import QtTest
import "../lib/net.js" as Net

TestCase {
    name: "Net"

    function test_sortNetworks() {
        const list = [
            { name: "cafe", signalStrength: 0.4, connected: false },
            { name: "home", signalStrength: 0.6, connected: true },
            { name: "", signalStrength: 0.9, connected: false },
            { name: "cafe", signalStrength: 0.8, connected: false },
            { name: "neighbour", signalStrength: 0.7, connected: false },
        ]
        compare(Net.sortNetworks(list, 8).map(n => n.name + ":" + n.signalStrength), ["home:0.6", "cafe:0.8", "neighbour:0.7"])
        compare(Net.sortNetworks(list, 2).length, 2)
    }
    function test_sortDevices() {
        const list = [
            { name: "Speaker", connected: false, paired: true },
            { name: "", connected: false, paired: false },
            { name: "Buds", connected: true, paired: true },
            { name: "Phone", connected: false, paired: false },
            { name: "Aaa", connected: false, paired: true },
        ]
        compare(Net.sortDevices(list).map(d => d.name), ["Buds", "Aaa", "Speaker", "Phone"])
    }
}
