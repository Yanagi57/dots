import QtQuick
import QtQuick.Layouts
import qs.theme

// Icon + value. Greys out when `ok` is false (no reading).
RowLayout {
    id: root
    property string icon
    property string text
    property bool ok: true
    property color accent: Theme.textSecondary

    spacing: 4

    StyledText {
        text: root.icon
        color: root.ok ? root.accent : Theme.textTertiary
    }
    StyledText {
        visible: root.text !== ""
        text: root.text
        color: root.ok ? Theme.textPrimary : Theme.textTertiary
    }
}
