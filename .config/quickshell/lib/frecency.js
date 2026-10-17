.pragma library

const DAY_MS = 86400000
const HALF_LIFE_DAYS = 14

// New usage map with `key` launched at `now` (ms). Does not mutate `usage`.
function record(usage, key, now) {
    const out = Object.assign({}, usage)
    const prev = usage[key]
    out[key] = { count: (prev ? prev.count : 0) + 1, last: now }
    return out
}

// log2(1 + count), halved for every 14 days since the last launch. 0 if never launched.
function boost(usage, key, now) {
    const u = usage[key]
    if (!u) return 0
    const ageDays = Math.max(0, now - u.last) / DAY_MS
    return Math.log2(1 + u.count) * Math.pow(0.5, ageDays / HALF_LIFE_DAYS)
}
