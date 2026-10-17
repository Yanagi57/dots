import QtQuick
import qs.theme
import "../lib/history.js" as History

Canvas {
    id: root
    property var values: []
    property int capacity: 12
    property color lineColor: Theme.teal

    implicitWidth: 140
    implicitHeight: 24

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const pts = History.points(values, width, height, capacity)
        if (pts.length < 2) return
        ctx.strokeStyle = lineColor
        ctx.lineWidth = 1.5
        ctx.beginPath()
        pts.forEach((p, i) => i === 0 ? ctx.moveTo(p.x, p.y) : ctx.lineTo(p.x, p.y))
        ctx.stroke()
    }
}
