pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick
import "../lib/hypr.js" as Hypr

// Hyprland actions via `hyprctl dispatch <lua>` (see lib/hypr.js for why Lua).
Singleton {
    function dispatch(expr) { if (expr !== "") Quickshell.execDetached(["hyprctl", "dispatch", expr]) }

    // When an overlay with keyboard focus closes, Hyprland refocuses the window that had
    // focus before it, switching workspace if needed. A focus dispatch sent before that
    // happens gets undone, so overlays queue their action until Hyprland reports the close.
    property string pendingLayer: ""
    property var pendingAction: null

    function afterLayerClosed(namespace, action) {
        pendingLayer = namespace
        pendingAction = action
        fallback.restart()
    }

    function runPending() {
        const action = pendingAction
        pendingLayer = ""
        pendingAction = null
        fallback.stop()
        if (action) action()
    }

    // in case the closelayer event never arrives
    Timer { id: fallback; interval: 500; onTriggered: runPending() }

    Connections {
        target: Hyprland
        function onRawEvent(e) {
            if (e.name === "closelayer" && e.data === pendingLayer) runPending()
        }
    }

    function focusWorkspace(ws) { dispatch(Hypr.focusWorkspace(ws)) }
    function focusWindow(address) { dispatch(Hypr.focusWindow(address)) }
    function moveWindow(address, id) { dispatch(Hypr.moveWindow(address, id)) }
}
