.pragma library

// Subsequence fuzzy match, case-insensitive. Higher is better, -1 = no match,
// empty query = 0. Bonuses: consecutive chars, word starts, whole-prefix; shorter text wins ties.
function score(query, text) {
    const q = query.toLowerCase()
    const t = text.toLowerCase()
    if (q === "") return 0
    let s = 0
    let from = 0
    let prev = -2
    for (let qi = 0; qi < q.length; qi++) {
        const found = t.indexOf(q[qi], from)
        if (found === -1) return -1
        s += 1
        if (found === prev + 1) s += 5
        if (found === 0 || /[\s\-_.]/.test(t[found - 1])) s += 8
        prev = found
        from = found + 1
    }
    if (t.startsWith(q)) s += 20
    return s - (t.length - q.length) * 0.1
}
