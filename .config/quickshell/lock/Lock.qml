import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import QtQuick
import "../lib/lock.js" as LockLib

// Session lock. Locked via `qs ipc call lock lock`, which hypridle's lock_cmd runs (idle,
// before sleep, `loginctl lock-session` from Super+Shift+[ and the power menu). If Quickshell
// isn't running, lock_cmd falls back to hyprlock, so the screen never stays unlocked.
// Unlock uses the PAM "hyprlock" config (auth include login), same as hyprlock.
//
// Crash recovery: if Quickshell dies while locked, Hyprland shows its "lock dead" screen.
// misc.allow_session_lock_restore is on, so switch to a TTY (Ctrl+Alt+F2) and run
//     hyprctl --instance 0 dispatch 'hl.dsp.exec_cmd("qs -d")'
// then return (Ctrl+Alt+F1): the new instance takes over the lock; unlock normally.
Scope {
    id: root

    property string password: ""     // shared by every monitor's surface
    property string message: ""      // shown under the field (errors)
    property bool busy: false        // PAM is checking

    function lock() {
        if (sessionLock.locked) return
        password = ""
        message = ""
        sessionLock.locked = true
    }

    function submit() {
        if (busy || password === "") return
        busy = true
        message = ""
        pam.start()
    }

    function resultName(r) {
        return r === PamResult.Success ? "Success"
             : r === PamResult.Failed ? "Failed"
             : r === PamResult.MaxTries ? "MaxTries"
             : "Error"
    }

    WlSessionLock {
        id: sessionLock
        locked: false

        LockSurface { lockState: root }
    }

    PamContext {
        id: pam
        config: "hyprlock"

        onResponseRequiredChanged: if (responseRequired) respond(root.password)

        onCompleted: result => {
            root.busy = false
            root.password = ""
            if (result === PamResult.Success) sessionLock.locked = false
            else root.message = LockLib.resultMessage(root.resultName(result))
        }

        onError: () => {
            root.busy = false
            root.password = ""
            root.message = LockLib.resultMessage("Error")
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock() }
    }
}
