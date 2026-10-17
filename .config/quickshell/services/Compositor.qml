pragma Singleton
import Quickshell
import QtQuick
import "../lib/hypr.js" as Hypr

// Hyprland actions via `hyprctl dispatch <lua>` (see lib/hypr.js for why Lua).
Singleton {
    function dispatch(expr) { if (expr !== "") Quickshell.execDetached(["hyprctl", "dispatch", expr]) }

    function focusWorkspace(ws) { dispatch(Hypr.focusWorkspace(ws)) }
    function focusWindow(address) { dispatch(Hypr.focusWindow(address)) }
    function moveWindow(address, id) { dispatch(Hypr.moveWindow(address, id)) }
}
