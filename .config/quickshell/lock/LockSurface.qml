import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../lib/lock.js" as LockLib

// Lock screen for one monitor: blurred wallpaper, clock, date, password pill.
WlSessionLockSurface {
    id: root
    required property var lockState

    // same image hyprland.lua hands to awww
    readonly property string wallpaper: "file://" + Quickshell.env("HOME") + "/.config/backgrounds/khaled-ali-unsplash.jpg"

    color: Theme.base

    Image {
        id: wall
        anchors.fill: parent
        source: root.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        sourceSize: Qt.size(root.width / 2, root.height / 2)
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: wall
        visible: wall.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        brightness: -0.35
    }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    ColumnLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.22
        spacing: 4

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: 110
            font.bold: true
        }
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(clock.date, "dddd, d MMMM")
            color: Theme.textSecondary
            font.pixelSize: 24
        }
    }

    Rectangle {
        id: field
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 120 }
        width: 300
        height: 44
        radius: 22
        color: Qt.alpha(Theme.surface, 0.85)
        border.width: 2
        border.color: root.lockState.message !== "" ? Theme.error
                    : root.lockState.password !== "" ? Theme.gold
                    : Theme.border
        Behavior on border.color { ColorAnimation { duration: Theme.animFast } }

        StyledText {
            anchors.centerIn: parent
            visible: root.lockState.password === "" || root.lockState.busy
            text: root.lockState.busy ? "Checking…" : "Password"
            color: Theme.textTertiary
        }

        Row {
            anchors.centerIn: parent
            visible: !root.lockState.busy
            spacing: 8

            Repeater {
                model: Math.min(root.lockState.password.length, 24)
                Rectangle { width: 8; height: 8; radius: 4; color: Theme.gold }
            }
        }
    }

    StyledText {
        anchors { horizontalCenter: parent.horizontalCenter; top: field.bottom; topMargin: 12 }
        text: root.lockState.message
        color: Theme.error
    }

    Item {
        id: input
        anchors.fill: parent
        focus: true
        Component.onCompleted: forceActiveFocus()

        Keys.onPressed: e => {
            const st = root.lockState
            if (st.busy) {
                e.accepted = true
                return
            }
            if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) st.submit()
            else if (e.key === Qt.Key_Escape) st.password = ""
            else if (e.key === Qt.Key_Backspace)
                st.password = (e.modifiers & Qt.ControlModifier) ? "" : LockLib.backspace(st.password)
            else if (e.text.length > 0 && e.text.charCodeAt(0) >= 32) {
                st.password += e.text
                st.message = ""
            }
            else return
            e.accepted = true
        }
    }
}
