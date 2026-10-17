pragma Singleton
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../lib/notifs.js" as NotifLib

// Notification daemon + state.
// History = the server's tracked notifications (newest first in `list`).
// Popups are a separate list so hiding a popup keeps the history entry.
Singleton {
    id: root

    // survive config reloads, like the server's history (keepOnReload)
    property alias dnd: persist.dnd
    property alias arrivals: persist.arrivals   // notification id → arrival time (ms), for "5m"
    property bool unread: false
    property var popups: []          // Notification objects, newest first, max 5

    readonly property var list: server.trackedNotifications.values.slice().reverse()
    // dismissed notifications drop out of `list` (and become null refs)
    readonly property var visiblePopups: popups.filter(n => n && list.indexOf(n) !== -1)

    function urgencyName(u) {
        return u === NotificationUrgency.Critical ? "critical" : u === NotificationUrgency.Low ? "low" : "normal"
    }
    // expireTimeout arrives in ms, as sent (verified: notify-send -t 3000 → 3000)
    function timeoutFor(n) { return NotifLib.timeoutFor(urgencyName(n.urgency), n.expireTimeout) }
    function hidePopup(n) { popups = popups.filter(p => p !== n) }
    function clearAll() { for (const n of list) n.dismiss() }
    function markRead() { unread = false }

    PersistentProperties {
        id: persist
        reloadableId: "notifs"
        property bool dnd: false
        property var arrivals: ({})
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        imageSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true
            const a = Object.assign({}, root.arrivals)
            a[n.id] = Date.now()
            root.arrivals = a
            root.unread = true
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n].concat(root.visiblePopups).slice(0, 5)
        }
    }
}
