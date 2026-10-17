import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.bar.islands

PanelWindow {
    id: panel
    required property ShellScreen modelData

    // Name of the open popup ("" = none). Owned here so only one is open at a time.
    property string openPopup: ""
    function toggle(name) { openPopup = openPopup === name ? "" : name }

    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: Theme.barHeight
    color: "transparent"

    RowLayout {
        id: leftGroup
        anchors { left: parent.left; leftMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing

        WorkspacesIsland { screenName: panel.screen.name }
        MediaIsland {}
    }

    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: Theme.spacing
    }

    RowLayout {
        id: rightGroup
        anchors { right: parent.right; rightMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing
    }
}
