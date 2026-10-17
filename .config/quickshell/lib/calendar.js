.pragma library

// 42 cells (6 weeks, Monday first) for a month (0-based). Each: { day, inMonth, isToday }.
function monthGrid(year, month, today) {
    const offset = (new Date(year, month, 1).getDay() + 6) % 7
    const cells = []
    for (let i = 0; i < 42; i++) {
        const d = new Date(year, month, 1 - offset + i)
        cells.push({
            day: d.getDate(),
            inMonth: d.getMonth() === month,
            isToday: d.getFullYear() === today.getFullYear()
                && d.getMonth() === today.getMonth()
                && d.getDate() === today.getDate(),
        })
    }
    return cells
}

function addMonths(year, month, delta) {
    const d = new Date(year, month + delta, 1)
    return { year: d.getFullYear(), month: d.getMonth() }
}
