import QtQuick
import QtTest
import "../lib/parse.js" as Parse

TestCase {
    name: "Parse"

    readonly property string sensorsJson: '{"k10temp-pci-00c3":{"Adapter":"PCI adapter","Tctl":{"temp1_input":47.375}},'
        + '"nvme-pci-0200":{"Adapter":"PCI adapter","Composite":{"temp1_input":39.85,"temp1_max":80.85}}}'

    function test_sensors() {
        compare(Parse.parseSensors(sensorsJson), { cpu: 47.375, nvme: 39.85 })
    }
    function test_sensors_garbage() {
        compare(Parse.parseSensors("not json"), { cpu: null, nvme: null })
        compare(Parse.parseSensors("{}"), { cpu: null, nvme: null })
    }
    function test_nvidia() {
        compare(Parse.parseNvidia("34, 0\n"), { temp: 34, util: 0 })
        compare(Parse.parseNvidia(""), { temp: null, util: null })
        compare(Parse.parseNvidia("[N/A], 5"), { temp: null, util: 5 })
    }
    function test_cpuTimes() {
        compare(Parse.parseCpuTimes("cpu  100 0 50 800 50 0 0 0 0 0\ncpu0 1 2 3 4\n"), { idle: 850, total: 1000 })
        compare(Parse.parseCpuTimes("nope"), null)
    }
    function test_cpuUsage() {
        compare(Parse.cpuUsage({ idle: 850, total: 1000 }, { idle: 900, total: 1100 }), 50)
        compare(Parse.cpuUsage(null, { idle: 1, total: 2 }), null)
        compare(Parse.cpuUsage({ idle: 1, total: 2 }, { idle: 1, total: 2 }), null)
    }
    function test_memUsed() {
        compare(Parse.parseMemUsedGiB("MemTotal:  4194304 kB\nMemFree: 1 kB\nMemAvailable:  1048576 kB\n"), 3)
        compare(Parse.parseMemUsedGiB("MemTotal: 1 kB\n"), null)
    }
}
