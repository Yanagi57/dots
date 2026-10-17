.pragma library
// Lua expressions for `hyprctl dispatch` (Hyprland 0.56+ with a Lua config takes hl.dsp.* calls,
// not the old "workspace 2" syntax). Inputs are validated so nothing can break out of the
// expression; invalid input yields "" (the caller then skips the dispatch).

const RELATIVE = /^[mer][+-]\d+$/

function workspaceLiteral(ws) {
    if (Number.isInteger(ws)) return String(ws)
    if (typeof ws === "string" && RELATIVE.test(ws)) return '"' + ws + '"'
    return null
}

function addressLiteral(address) {
    const hex = address.startsWith("0x") ? address.slice(2) : address
    return /^[0-9a-fA-F]+$/.test(hex) ? '"address:0x' + hex + '"' : null
}

// ws: workspace id (integer) or relative selector like "m+1" / "e-1"
function focusWorkspace(ws) {
    const w = workspaceLiteral(ws)
    return w === null ? "" : "hl.dsp.focus({ workspace = " + w + " })"
}

function focusWindow(address) {
    const a = addressLiteral(address)
    return a === null ? "" : "hl.dsp.focus({ window = " + a + " })"
}

// Move a window to workspace `id` without following it.
function moveWindow(address, id) {
    const a = addressLiteral(address), w = workspaceLiteral(id)
    return a === null || w === null ? "" : "hl.dsp.window.move({ workspace = " + w + ", window = " + a + ", follow = false })"
}
