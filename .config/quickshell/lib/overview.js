.pragma library

// Hyprland window rect (global logical px) → rect inside a workspace tile for its monitor.
function thumbRect(at, size, monitor, scale) {
    return {
        x: (at[0] - monitor.x) * scale,
        y: (at[1] - monitor.y) * scale,
        width: size[0] * scale,
        height: size[1] * scale,
    }
}

// Number key → workspace id ("1".."9" → 1..9, "0" → 10), or -1.
function workspaceForKey(text) {
    if (text.length !== 1 || text < "0" || text > "9") return -1
    return text === "0" ? 10 : Number(text)
}

// hyprctl wants "address:0x…"; Quickshell may give the address with or without the prefix.
function hyprAddress(address) { return address.startsWith("0x") ? address : "0x" + address }
