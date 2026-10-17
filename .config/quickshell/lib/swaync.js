.pragma library

// One line of `swaync-client -swb` → { unread, dnd }, or null if unparsable.
function parseStatus(line) {
    let o
    try { o = JSON.parse(line) } catch (e) { return null }
    if (!o || typeof o.alt !== "string") return null
    return { unread: o.alt.endsWith("notification"), dnd: o.alt.indexOf("dnd") !== -1 }
}
