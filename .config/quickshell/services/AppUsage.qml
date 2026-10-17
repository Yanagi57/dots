pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import "../lib/frecency.js" as Frecency

// App launch history for frecency ranking, persisted in the Quickshell state dir.
// A missing or corrupt file just means an empty history.
Singleton {
    id: root
    property var usage: ({})

    function boost(key) { return Frecency.boost(usage, key, Date.now()) }

    function record(key) {
        usage = Frecency.record(usage, key, Date.now())
        file.setText(JSON.stringify(usage))
    }

    FileView {
        id: file
        path: Quickshell.statePath("app-usage.json")
        blockLoading: true
        printErrors: false
        onLoaded: {
            try { root.usage = JSON.parse(text()) || {} } catch (e) { root.usage = {} }
        }
    }
}
