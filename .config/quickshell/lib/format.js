.pragma library
// Display helpers. null/undefined means "no reading" and renders as "--".

function temp(v) { return v == null ? "--" : Math.round(v) + "°" }

function percent(v) { return v == null ? "--" : Math.round(v) + "%" }

function gib(v) { return v == null ? "--" : v.toFixed(1) + "G" }

function truncate(s, max) { return s.length <= max ? s : s.slice(0, max - 1) + "…" }

// Pick an entry from an ordered icon list using a 0..1 fraction (volume, battery).
function level(list, fraction) {
    const i = Math.floor(Math.max(0, Math.min(1, fraction)) * list.length)
    return list[Math.min(i, list.length - 1)]
}

// Some APIs report 0..1, others 0..100; normalise to 0..100.
function toPercent(v) { return v == null ? null : (v <= 1 ? v * 100 : v) }
