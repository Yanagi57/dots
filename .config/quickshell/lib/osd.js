.pragma library

// Volume change → what the OSD shows. fraction is clamped for the bar; text shows the real value.
function volumeState(volume, muted) {
    const fraction = Math.max(0, Math.min(1, volume))
    const level = muted || volume <= 0 ? "muted" : volume < 0.34 ? "low" : volume < 0.67 ? "mid" : "high"
    return { level: level, fraction: fraction, text: muted ? "muted" : Math.round(volume * 100) + "%" }
}

// `brightnessctl -m` ("device,class,current,percent,max") → 0..1, or null if not a backlight.
function parseBrightnessctl(text) {
    const p = text.trim().split(",")
    if (p.length < 5 || p[1] !== "backlight") return null
    const cur = Number(p[2]), max = Number(p[4])
    return max > 0 ? Math.max(0, Math.min(1, cur / max)) : null
}
