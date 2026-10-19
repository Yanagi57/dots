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
    if (image) {
        // Quickshell turns the image-path hint into an icon-theme lookup, even when it is a
        // file path (notify-send -i /path.png, e.g. hyprshot); load those as files instead
        const prefix = "image://icon/"
        if (image.startsWith(prefix)) {
            const inner = image.slice(prefix.length)
            if (inner.startsWith("/")) return "file://" + inner
            if (inner.startsWith("file://")) return inner
        }
        return image
    }
    if (appIcon.startsWith("/")) return "file://" + appIcon
    if (appIcon.indexOf("://") !== -1) return appIcon
    return ""
}

// Drop <img> tags from a body: Qt would fetch remote images (tracking pixels) and read local files.
function stripImages(body) { return body.replace(/<img\b[^>]*>/gi, "") }

// Local image files (screenshots etc.) are preview candidates; app-supplied image data
// and theme icons stay small.
function isPreview(url) { return url.startsWith("file://") }

// Square-ish images (chat avatars, album art) belong in the small icon slot even when
// sent as files; only other shapes (screenshots) get the large preview.
function isSquare(w, h) { return w > 0 && h > 0 && Math.abs(w - h) <= 0.05 * Math.max(w, h) }
