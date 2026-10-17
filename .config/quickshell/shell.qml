import Quickshell
import QtQuick
import qs.bar

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
}
