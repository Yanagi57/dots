import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.bar.islands
import qs.bar.popups

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

    IdleInhibitor {
        window: panel
        enabled: Caffeine.active
    }

    RowLayout {
        id: leftGroup
        anchors { left: parent.left; leftMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing

        WorkspacesIsland { screenName: panel.screen.name }
        MediaIsland { id: mediaIsland; onPopupRequested: panel.toggle("media") }
    }

    RowLayout {
        id: centerGroup
        anchors.centerIn: parent
        spacing: Theme.spacing

        ClockIsland { id: clockIsland; onClicked: panel.toggle("calendar") }
    }

    RowLayout {
        id: rightGroup
        anchors { right: parent.right; rightMargin: Theme.spacing; verticalCenter: parent.verticalCenter }
        spacing: Theme.spacing

        SystemIsland { id: systemIsland; onClicked: panel.toggle("sensors") }
        StatusIsland { id: statusIsland; onClicked: panel.toggle("quick") }
        TogglesIsland { id: togglesIsland; onNotificationsClicked: panel.toggle("notifications") }
        TrayIsland { bar: panel }
    }

    MediaPopup { bar: panel; anchorItem: mediaIsland }
    CalendarPopup { bar: panel; anchorItem: clockIsland }
    SensorsPopup { bar: panel; anchorItem: systemIsland }
    QuickSettingsPopup { bar: panel; anchorItem: statusIsland }
    NotificationCenterPopup { bar: panel; anchorItem: togglesIsland }
}
