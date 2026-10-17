pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/swaync.js" as SwayncParse

// Temporary bridge to swaync; replaced by the Quickshell notification server in sub-project 4.
Singleton {
    id: root
    property bool unread: false
    property bool dnd: false

    function toggleCenter() { Quickshell.execDetached(["swaync-client", "-t", "-sw"]) }
    function toggleDnd() { Quickshell.execDetached(["swaync-client", "-d", "-sw"]) }

    Process {
        id: watcher
        command: ["swaync-client", "-swb"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                const s = SwayncParse.parseStatus(line)
                if (s) { root.unread = s.unread; root.dnd = s.dnd }
            }
        }
        // swaync restarts or isn't up yet: try again shortly
        onRunningChanged: if (!running) restart.start()
    }

    Timer { id: restart; interval: 3000; onTriggered: watcher.running = true }
}
