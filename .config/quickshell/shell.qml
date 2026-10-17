//@ pragma IconTheme Adwaita
import Quickshell
import QtQuick
import qs.bar
import qs.launcher
import qs.powermenu
import qs.notifications
import qs.osd
import qs.overview

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Launcher {}
    PowerMenu {}
    NotificationPopups {}
    Osd {}
    Overview {}
}
