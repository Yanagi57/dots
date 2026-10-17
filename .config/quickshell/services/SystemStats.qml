pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/parse.js" as Parse
import "../lib/history.js" as History

// CPU usage and memory from procfs.
Singleton {
    id: root

    readonly property int historyLength: 30   // 60 s at 2 s

    property var cpuUsage: null
    property var memUsedGiB: null
    property var cpuHistory: []
    property var memHistory: []

    property var lastCpuTimes: null

    FileView { id: statFile; path: "/proc/stat"; blockLoading: true }
    FileView { id: memFile; path: "/proc/meminfo"; blockLoading: true }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload()
            memFile.reload()
            const times = Parse.parseCpuTimes(statFile.text())
            root.cpuUsage = Parse.cpuUsage(root.lastCpuTimes, times)
            root.lastCpuTimes = times
            root.memUsedGiB = Parse.parseMemUsedGiB(memFile.text())
            root.cpuHistory = History.push(root.cpuHistory, root.cpuUsage, root.historyLength)
            root.memHistory = History.push(root.memHistory, root.memUsedGiB, root.historyLength)
        }
    }
}
