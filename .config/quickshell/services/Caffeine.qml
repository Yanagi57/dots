pragma Singleton
import Quickshell
import QtQuick

// When active, every bar holds a Wayland idle inhibitor (hypridle respects it).
Singleton {
    property bool active: false
}
