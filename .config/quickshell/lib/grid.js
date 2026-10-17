.pragma library

// Grid navigation without wrapping. Returns the old index if the move leaves the grid.
function move(index, dx, dy, columns, count) {
    const rows = Math.ceil(count / columns)
    const col = Math.max(0, Math.min(columns - 1, index % columns + dx))
    const row = Math.max(0, Math.min(rows - 1, Math.floor(index / columns) + dy))
    const next = row * columns + col
    return next < count ? next : index
}
