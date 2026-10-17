pragma Singleton
import Quickshell
import QtQuick

// Black & Gold palette (see CLAUDE.md). The only place hex colours may appear.
Singleton {
    // Backgrounds
    readonly property color base: "#222222"
    readonly property color surface: "#2A2A2A"
    readonly property color elevated: "#333333"
    readonly property color border: "#3D3D3D"

    // Accents
    readonly property color gold: "#FFD700"
    readonly property color goldDim: "#C9A800"
    readonly property color teal: "#4DD9C0"
    readonly property color tealDim: "#2AA38E"

    // Text
    readonly property color textPrimary: "#F5F5F5"
    readonly property color textSecondary: "#BBBBBB"
    readonly property color textTertiary: "#777777"

    // Semantic
    readonly property color error: "#FF5555"
    readonly property color warning: "#FFB86C"

    // Type
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11

    // Geometry
    readonly property int barHeight: 34
    readonly property int islandHeight: 26
    readonly property int radius: 13
    readonly property int radiusPopup: 12
    readonly property int spacing: 8
    readonly property int padding: 10

    // Motion
    readonly property int animFast: 150
}
