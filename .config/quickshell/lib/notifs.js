.pragma library

// How long a popup stays up, in ms. 0 = until dismissed.
// urgency: "low" | "normal" | "critical"; appTimeoutMs: the app's request (<= 0 = none).
function timeoutFor(urgency, appTimeoutMs) {
    if (urgency === "critical") return 0
    if (appTimeoutMs > 0) return appTimeoutMs
    return urgency === "low" ? 4000 : 8000
}

// Compact age: "now", "5m", "3h", "2d".
function ago(thenMs, nowMs) {
    const s = Math.max(0, Math.floor((nowMs - thenMs) / 1000))
    if (s < 60) return "now"
    if (s < 3600) return Math.floor(s / 60) + "m"
    if (s < 86400) return Math.floor(s / 3600) + "h"
    return Math.floor(s / 86400) + "d"
}

// Image URL for a notification: its own image, else an app icon given as a path or URL.
// "" means: look `appIcon` up as an icon-theme name instead.
function iconUrl(image, appIcon) {
    if (image) return image
    if (appIcon.startsWith("/")) return "file://" + appIcon
    if (appIcon.indexOf("://") !== -1) return appIcon
    return ""
}
