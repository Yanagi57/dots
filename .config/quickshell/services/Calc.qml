pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Debounced qalc. Set `expression`; ~150 ms after it stops changing, `result` is set and
// `resultFor` names the expression it belongs to (consumers should check it matches).
// Runs never overlap: a change during a run queues one rerun, so late output can't
// overwrite a newer answer. Failed runs (non-zero exit) publish nothing.
Singleton {
    id: root
    property string expression: ""
    property string result: ""
    property string resultFor: ""

    property string runExpr: ""
    property string runOut: ""
    property int runCode: -1
    property int runParts: 0      // stdout finished + process exited
    property bool rerun: false

    function start() {
        if (proc.running) {
            rerun = true
            return
        }
        runExpr = expression
        runParts = 0
        proc.exec(["qalc", "-t", runExpr])
    }

    function partDone() {
        if (++runParts < 2) return
        if (runCode === 0 && runOut !== "" && runExpr === expression) {
            result = runOut
            resultFor = runExpr
        }
        if (rerun) {
            rerun = false
            Qt.callLater(start)
        }
    }

    onExpressionChanged: {
        if (expression === "") {
            debounce.stop()
            result = ""
            resultFor = ""
            return
        }
        debounce.restart()
    }

    Timer {
        id: debounce
        interval: 150
        onTriggered: root.start()
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                root.runOut = text.trim()
                root.partDone()
            }
        }
        onExited: code => {
            root.runCode = code
            root.partDone()
        }
    }
}
