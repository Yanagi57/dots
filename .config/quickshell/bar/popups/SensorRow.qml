import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets

RowLayout {
    id: root
    property string label
    property string value
    property bool ok: true
    property var history: []
    property int capacity: 12
    property color lineColor: Theme.teal

    spacing: Theme.spacing

    StyledText { text: root.label; color: Theme.textSecondary; Layout.preferredWidth: 80 }
    Sparkline {
        values: root.history
        capacity: root.capacity
        lineColor: root.lineColor
        Layout.preferredWidth: 140
        Layout.preferredHeight: 24
    }
    StyledText {
        text: root.value
        color: root.ok ? Theme.textPrimary : Theme.textTertiary
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 48
    }
}
