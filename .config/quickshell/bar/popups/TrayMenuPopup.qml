import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../../lib/tray.js" as Tray

// Themed tray menu (DBusMenu via QsMenuOpener). Submenus open in place with a Back row.
BarPopup {
    id: root
    name: "tray"

    required property var menu          // QsMenuHandle of the clicked tray item
    property var stack: []              // submenu entries drilled into

    readonly property var current: stack.length > 0 ? stack[stack.length - 1] : menu

    onOpenChanged: if (open) stack = []

    QsMenuOpener { id: opener; menu: root.current }

    ColumnLayout {
        width: 240
        spacing: 0

        MenuRow {
            visible: root.stack.length > 0
            label: "‹  Back"
            onActivated: root.stack = root.stack.slice(0, -1)
        }

        Repeater {
            model: opener.children ? opener.children.values : []

            Item {
                id: entryItem
                required property var modelData
                readonly property var entry: modelData

                Layout.fillWidth: true
                implicitHeight: entry.isSeparator ? 9 : row.implicitHeight

                Rectangle {
                    visible: entryItem.entry.isSeparator
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; margins: 6 }
                    height: 1
                    color: Theme.border
                }

                MenuRow {
                    id: row
                    visible: !entryItem.entry.isSeparator
                    width: parent.width
                    entry: entryItem.entry
                    label: Tray.stripMnemonic(entryItem.entry.text)
                    onActivated: {
                        if (entryItem.entry.hasChildren) {
                            root.stack = root.stack.concat([entryItem.entry])
                        } else {
                            entryItem.entry.triggered()
                            root.close()
                        }
                    }
                }
            }
        }
    }

    component MenuRow: Rectangle {
        id: menuRow
        property var entry: null
        property string label
        readonly property bool enabledEntry: entry === null || entry.enabled
        readonly property bool checkable: entry !== null && entry.buttonType !== QsMenuButtonType.None
        readonly property bool checked: entry !== null && entry.checkState === Qt.Checked
        signal activated()

        implicitHeight: 30
        radius: 6
        color: area.containsMouse && enabledEntry ? Theme.elevated : "transparent"

        RowLayout {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            spacing: 8

            StyledText {
                visible: menuRow.checkable
                text: menuRow.checked ? (menuRow.entry.buttonType === QsMenuButtonType.RadioButton ? Icons.radio : Icons.check) : ""
                color: Theme.gold
                Layout.preferredWidth: 12
            }
            IconImage {
                visible: menuRow.entry !== null && menuRow.entry.icon !== ""
                source: menuRow.entry ? menuRow.entry.icon : ""
                implicitSize: 16
            }
            StyledText {
                text: menuRow.label
                color: menuRow.enabledEntry ? Theme.textPrimary : Theme.textTertiary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            StyledText {
                visible: menuRow.entry !== null && menuRow.entry.hasChildren
                text: "›"
                color: Theme.textSecondary
            }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            enabled: menuRow.enabledEntry
            cursorShape: Qt.PointingHandCursor
            onClicked: menuRow.activated()
        }
    }
}
