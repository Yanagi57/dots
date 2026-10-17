import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.widgets
import "../lib/osd.js" as OsdLib

// Volume / mic-mute / brightness pill at the bottom centre, shown briefly on change.
// Volume and mic follow PipeWire directly; brightness is pushed by the brightness keys
// (`qs ipc call osd brightness`) because sysfs backlight files don't reliably notify.
PanelWindow {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property string icon: ""
    property real fraction: 0
    property string label: ""
    property bool showBar: true
    property bool shown: false
    property bool armed: false     // ignore the burst of changes at startup / reload

    function show(icon_, fraction_, label_, bar) {
        if (!armed) return
        icon = icon_
        fraction = fraction_
        label = label_
        showBar = bar
        if (!visible)
            screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
        shown = true
        visible = true
        hideTimer.restart()
    }

    function showVolume() {
        if (!sink || !sink.audio) return
        const s = OsdLib.volumeState(sink.audio.volume, sink.audio.muted)
        const icons = { muted: Icons.volumeMuted, low: Icons.volumeLow, mid: Icons.volumeMid, high: Icons.volumeHigh }
        show(icons[s.level], s.fraction, s.text, true)
    }

    function showMic() {
        if (!source || !source.audio) return
        const muted = source.audio.muted
        show(muted ? Icons.micOff : Icons.mic, 0, muted ? "mic muted" : "mic on", false)
    }

    visible: false
    color: "transparent"
    anchors.bottom: true
    margins.bottom: 64
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 280
    implicitHeight: 48
    mask: Region {}     // click-through
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"

    PwObjectTracker { objects: [root.sink, root.source] }

    Connections {
        target: root.sink ? root.sink.audio : null
        function onVolumesChanged() { root.showVolume() }
        function onMutedChanged() { root.showVolume() }
    }

    Connections {
        target: root.source ? root.source.audio : null
        function onMutedChanged() { root.showMic() }
    }

    IpcHandler {
        target: "osd"
        function brightness(): void { brightnessProc.running = true }
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = OsdLib.parseBrightnessctl(text)
                if (f !== null) root.show(Icons.brightness, f, Math.round(f * 100) + "%", true)
            }
        }
    }

    Timer { interval: 1500; running: true; onTriggered: root.armed = true }
    Timer { id: hideTimer; interval: 1500; onTriggered: root.shown = false }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.animFast
                onRunningChanged: if (!running && !root.shown) root.visible = false
            }
        }

        RowLayout {
            anchors { fill: parent; leftMargin: 18; rightMargin: 18 }
            spacing: 12

            StyledText { text: root.icon; color: Theme.gold; font.pixelSize: 18 }

            Rectangle {
                visible: root.showBar
                Layout.fillWidth: true
                implicitHeight: 6
                radius: 3
                color: Theme.border

                Rectangle {
                    width: parent.width * root.fraction
                    height: parent.height
                    radius: 3
                    color: Theme.gold
                    Behavior on width { NumberAnimation { duration: 80 } }
                }
            }

            StyledText {
                text: root.label
                horizontalAlignment: root.showBar ? Text.AlignRight : Text.AlignLeft
                Layout.preferredWidth: root.showBar ? 44 : -1
                Layout.fillWidth: !root.showBar
            }
        }
    }
}
