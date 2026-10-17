//@ pragma IconTheme Adwaita
import Quickshell
import QtQuick
import qs.bar
import qs.launcher

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Launcher {}
}
