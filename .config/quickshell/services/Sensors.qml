pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/parse.js" as Parse
import "../lib/history.js" as History

// Temperatures and GPU load. null = no reading (command failed or unparsable).
Singleton {
    id: root

    readonly property int historyLength: 12   // 60 s at 5 s

    property var cpuTemp: null
    property var nvmeTemp: null
    property var gpuTemp: null
    property var gpuUtil: null

    property var cpuTempHistory: []
    property var nvmeTempHistory: []
    property var gpuTempHistory: []
    property var gpuUtilHistory: []

    Process {
        id: sensorsProc
        command: ["sensors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = Parse.parseSensors(text)
                root.cpuTemp = r.cpu
                root.nvmeTemp = r.nvme
                root.cpuTempHistory = History.push(root.cpuTempHistory, r.cpu, root.historyLength)
                root.nvmeTempHistory = History.push(root.nvmeTempHistory, r.nvme, root.historyLength)
            }
        }
        // no exit-code check: sensors exits non-zero when any unrelated chip (iwlwifi)
        // fails to read, while still printing valid JSON for the chips we want
    }

    Process {
        id: nvidiaProc
        command: ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const r = Parse.parseNvidia(text)
                root.gpuTemp = r.temp
                root.gpuUtil = r.util
                root.gpuTempHistory = History.push(root.gpuTempHistory, r.temp, root.historyLength)
                root.gpuUtilHistory = History.push(root.gpuUtilHistory, r.util, root.historyLength)
            }
        }
        onExited: code => { if (code !== 0) { root.gpuTemp = null; root.gpuUtil = null } }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sensorsProc.running = true
            nvidiaProc.running = true
        }
    }
}
