//@ pragma IconTheme Adwaita
// tray menus (SystemTrayItem.display) are native Qt menus and need a QApplication
//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.bar
import qs.launcher
import qs.powermenu
import qs.notifications
import qs.osd
import qs.overview
import qs.switcher
import qs.lock

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
    Switcher {}
    Lock {}
}
