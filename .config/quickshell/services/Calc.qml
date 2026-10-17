pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Debounced qalc. Set `expression`; `result` follows ~150 ms after it stops changing.
// "" = no result (empty expression or qalc failed).
Singleton {
    id: root
    property string expression: ""
    property string result: ""

    onExpressionChanged: {
        if (expression === "") {
            debounce.stop()
            result = ""
            return
        }
        debounce.restart()
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: proc.exec(["qalc", "-t", root.expression])
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: root.result = text.trim()
        }
        onExited: code => { if (code !== 0) root.result = "" }
    }
}
