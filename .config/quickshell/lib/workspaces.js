.pragma library

// Workspaces on one monitor: normal ones by id, special ones (negative id) last.
function visible(list, monitorName) {
    return list
        .filter(w => w.monitor && w.monitor.name === monitorName)
        .sort((a, b) => {
            const sa = a.id < 0, sb = b.id < 0
            if (sa !== sb) return sa ? 1 : -1
            return a.id - b.id
        })
}
