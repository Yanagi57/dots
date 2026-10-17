.pragma library

// Query text → { mode: "apps" | "calc" | "emoji", term }
function parseQuery(text) {
    if (text.startsWith("=")) return { mode: "calc", term: text.slice(1).trim() }
    if (text.startsWith(":")) return { mode: "emoji", term: text.slice(1).trim() }
    return { mode: "apps", term: text.trim() }
}

// Text to prefill when opening the launcher in a mode.
function prefixFor(mode) { return mode === "calc" ? "=" : mode === "emoji" ? ":" : "" }

// emoji.txt ("<emoji> <description words…>" per line) → [{ emoji, description }]
function parseEmoji(text) {
    const out = []
    for (const line of text.split("\n")) {
        const i = line.indexOf(" ")
        if (i <= 0) continue
        out.push({ emoji: line.slice(0, i), description: line.slice(i + 1).trim() })
    }
    return out
}

// Entries whose description contains every word of `term` (case-insensitive); at most `limit`.
function filterEmoji(entries, term, limit) {
    const words = term.toLowerCase().split(/\s+/).filter(w => w !== "")
    const out = []
    for (const e of entries) {
        const d = e.description.toLowerCase()
        if (words.every(w => d.indexOf(w) !== -1)) {
            out.push(e)
            if (out.length >= limit) break
        }
    }
    return out
}
