import QtQuick
import QtTest
import "../lib/calendar.js" as Cal

TestCase {
    name: "Calendar"

    function test_grid_oct_2026() {
        // 1 Oct 2026 is a Thursday → 3 leading days from September (Monday-first)
        const cells = Cal.monthGrid(2026, 9, new Date(2026, 9, 17))
        compare(cells.length, 42)
        compare(cells[0], { day: 28, inMonth: false, isToday: false })
        compare(cells[3], { day: 1, inMonth: true, isToday: false })
        compare(cells[19], { day: 17, inMonth: true, isToday: true })
        compare(cells.filter(c => c.isToday).length, 1)
    }
    function test_addMonths() {
        compare(Cal.addMonths(2026, 11, 1), { year: 2027, month: 0 })
        compare(Cal.addMonths(2026, 0, -1), { year: 2025, month: 11 })
    }
}
