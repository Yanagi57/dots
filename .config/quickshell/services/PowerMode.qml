pragma Singleton
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import qs.theme

// power-profiles-daemon via UPower's PowerProfiles.
Singleton {
    readonly property var available: PowerProfiles.hasPerformanceProfile
        ? [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
        : [PowerProfile.PowerSaver, PowerProfile.Balanced]
    readonly property int current: PowerProfiles.profile

    function name(p) {
        return p === PowerProfile.PowerSaver ? "power-saver" : p === PowerProfile.Performance ? "performance" : "balanced"
    }
    function icon(p) {
        return p === PowerProfile.PowerSaver ? Icons.powerSaver : p === PowerProfile.Performance ? Icons.performance : Icons.balanced
    }
    function set(p) { PowerProfiles.profile = p }
    function cycle() {
        const i = available.indexOf(current)
        set(available[(i + 1) % available.length])
    }
}
