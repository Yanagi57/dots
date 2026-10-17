.pragma library

// `hyprctl clients -j` entries → one entry per app (window class), most recently used first.
// Each app points at its most recently focused window. Class-less windows are skipped.
function groupApps(clients) {
    const byClass = {}
    for (const c of clients) {
        if (!c.class) continue
        const g = byClass[c.class]
        if (!g) byClass[c.class] = { best: c, count: 1 }
        else {
            g.count++
            if (c.focusHistoryID < g.best.focusHistoryID) g.best = c
        }
    }
    return Object.keys(byClass)
        .map(k => byClass[k])
        .sort((a, b) => a.best.focusHistoryID - b.best.focusHistoryID)
        .map(g => ({ cls: g.best.class, address: g.best.address, title: g.best.title, count: g.count }))
}

// Wrapping step through n entries.
function step(index, delta, n) { return n > 0 ? ((index + delta) % n + n) % n : 0 }

// Start on the previous app (Mac behaviour), or the only one.
function initialIndex(n) { return n > 1 ? 1 : 0 }
