import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../../lib/calendar.js" as Cal

BarPopup {
    id: root
    name: "calendar"

    property int viewYear: clock.date.getFullYear()
    property int viewMonth: clock.date.getMonth()

    function shift(delta) {
        const m = Cal.addMonths(viewYear, viewMonth, delta)
        viewYear = m.year
        viewMonth = m.month
    }

    // jump back to today whenever it opens
    onOpenChanged: if (open) {
        viewYear = clock.date.getFullYear()
        viewMonth = clock.date.getMonth()
    }

    SystemClock { id: clock; precision: SystemClock.Hours }

    ColumnLayout {
        spacing: Theme.spacing

        WheelHandler { onWheel: e => root.shift(e.angleDelta.y > 0 ? -1 : 1) }

        StyledText {
            text: Qt.formatDate(clock.date, "dddd, d MMMM yyyy")
            color: Theme.gold
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            IconButton { text: "‹"; onClicked: root.shift(-1) }
            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1), "MMMM yyyy")
            }
            IconButton { text: "›"; onClicked: root.shift(1) }
        }

        GridLayout {
            columns: 7
            columnSpacing: 4
            rowSpacing: 4

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                StyledText {
                    required property string modelData
                    text: modelData
                    color: Theme.textTertiary
                    font.pixelSize: Theme.fontSizeSmall
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 28
                }
            }

            Repeater {
                model: Cal.monthGrid(root.viewYear, root.viewMonth, clock.date)
                Rectangle {
                    required property var modelData
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 24
                    radius: 6
                    color: modelData.isToday ? Theme.gold : "transparent"

                    StyledText {
                        anchors.centerIn: parent
                        text: parent.modelData.day
                        color: parent.modelData.isToday ? Theme.base
                             : parent.modelData.inMonth ? Theme.textPrimary
                             : Theme.textTertiary
                    }
                }
            }
        }
    }
}
