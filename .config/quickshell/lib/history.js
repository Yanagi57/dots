.pragma library

// Append and keep the last `max` items. Returns a new array so QML bindings notice.
function push(arr, value, max) {
    const out = arr.concat([value])
    return out.length > max ? out.slice(out.length - max) : out
}

// Map samples to sparkline coordinates. Newest sample sits at the right edge;
// x spacing is fixed by `capacity` so the line grows in from the right. nulls are skipped.
function points(values, width, height, capacity) {
    const pad = 2
    const nums = values.filter(v => v != null)
    if (nums.length === 0) return []
    const min = Math.min.apply(null, nums)
    const max = Math.max.apply(null, nums)
    const step = capacity > 1 ? width / (capacity - 1) : 0
    const out = []
    values.forEach((v, i) => {
        if (v == null) return
        const x = width - (values.length - 1 - i) * step
        const y = max === min ? height / 2 : pad + (1 - (v - min) / (max - min)) * (height - 2 * pad)
        out.push({ x: x, y: y })
    })
    return out
}
