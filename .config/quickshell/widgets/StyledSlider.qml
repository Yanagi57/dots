import QtQuick
import QtQuick.Controls.Basic
import qs.theme

// Thin gold slider (volume, seek). Handle hides when disabled.
Slider {
    id: control

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: Theme.border

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: control.enabled ? Theme.gold : Theme.goldDim
        }
    }

    handle: Rectangle {
        visible: control.enabled
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 14
        height: 14
        radius: 7
        color: control.pressed ? Theme.goldDim : Theme.gold
    }
}
