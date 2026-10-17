.pragma library

// Power menu entries in grid order (3 columns). Icons are looked up as Icons[id].
const actions = [
    { id: "lock", label: "Lock", key: "l", command: ["loginctl", "lock-session"] },
    { id: "logout", label: "Logout", key: "o", command: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
    { id: "suspend", label: "Suspend", key: "u", command: ["systemctl", "suspend"] },
    { id: "hibernate", label: "Hibernate", key: "h", command: ["systemctl", "hibernate"] },
    { id: "reboot", label: "Reboot", key: "r", command: ["systemctl", "reboot"] },
    { id: "shutdown", label: "Shutdown", key: "s", command: ["systemctl", "poweroff"] },
]

// Typed character → action index, or -1.
function indexForKey(text) {
    const k = text.toLowerCase()
    return k === "" ? -1 : actions.findIndex(a => a.key === k)
}

// Split a label around its shortcut letter so the UI can highlight it: "Logout" → L|o|gout.
function labelParts(action) {
    const i = action.label.toLowerCase().indexOf(action.key)
    return {
        before: action.label.slice(0, i),
        key: action.label.charAt(i),
        after: action.label.slice(i + 1),
    }
}
