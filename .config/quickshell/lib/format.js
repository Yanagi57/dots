.pragma library
// Display helpers. null/undefined means "no reading" and renders as "--".

function temp(v) { return v == null ? "--" : Math.round(v) + "°" }

function percent(v) { return v == null ? "--" : Math.round(v) + "%" }

function gib(v) { return v == null ? "--" : v.toFixed(1) + "G" }

// Counts code points, so emoji and Nerd Font glyphs are never split.
// (Qt's JS engine doesn't iterate strings by code point, so Array.from won't do.)
function truncate(s, max) {
    const chars = []
    for (let i = 0; i < s.length; i += chars[chars.length - 1].length)
        chars.push(String.fromCodePoint(s.codePointAt(i)))
    return chars.length <= max ? s : chars.slice(0, max - 1).join("") + "…"
}

// Pick an entry from an ordered icon list using a 0..1 fraction (volume, battery).
function level(list, fraction) {
    const f = Number.isFinite(fraction) ? fraction : 0
    const i = Math.floor(Math.max(0, Math.min(1, f)) * list.length)
    return list[Math.min(i, list.length - 1)]
}

// Some APIs report 0..1, others 0..100; normalise to 0..100.
function toPercent(v) { return v == null ? null : (v <= 1 ? v * 100 : v) }
