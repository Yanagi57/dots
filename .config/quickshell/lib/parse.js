.pragma library
// Parsers for command / procfs output. Every function returns null for missing or bad data.

// `sensors -j` → { cpu, nvme } in °C
function parseSensors(text) {
    let data
    try { data = JSON.parse(text) } catch (e) { return { cpu: null, nvme: null } }
    return {
        cpu: readInput(data, "k10temp-pci-00c3", "Tctl"),
        nvme: readInput(data, "nvme-pci-0200", "Composite"),
    }
}

function readInput(data, chip, label) {
    const entry = data && data[chip] && data[chip][label]
    if (!entry) return null
    for (const key in entry)
        if (key.endsWith("_input")) return entry[key]
    return null
}

// `nvidia-smi --query-gpu=temperature.gpu,utilization.gpu --format=csv,noheader,nounits` → { temp, util }
function parseNvidia(text) {
    const parts = text.trim().split(",").map(s => s.trim())
    const num = s => (s !== undefined && /^\d+(\.\d+)?$/.test(s)) ? Number(s) : null
    return { temp: num(parts[0]), util: num(parts[1]) }
}

// First line of /proc/stat → { idle, total } jiffies
function parseCpuTimes(text) {
    const line = text.split("\n")[0]
    if (!line.startsWith("cpu ")) return null
    const v = line.trim().split(/\s+/).slice(1).map(Number)
    if (v.length < 4 || v.some(isNaN)) return null
    return { idle: v[3] + (v[4] || 0), total: v.reduce((a, b) => a + b, 0) }
}

// Two /proc/stat samples → usage 0..100
function cpuUsage(prev, cur) {
    if (!prev || !cur) return null
    const dt = cur.total - prev.total
    if (dt <= 0) return null
    return Math.round(100 * (1 - (cur.idle - prev.idle) / dt))
}

// /proc/meminfo → used GiB (MemTotal - MemAvailable, same as Waybar)
function parseMemUsedGiB(text) {
    const kb = key => {
        const m = text.match(new RegExp("^" + key + ":\\s+(\\d+)", "m"))
        return m ? Number(m[1]) : null
    }
    const total = kb("MemTotal"), avail = kb("MemAvailable")
    if (total === null || avail === null) return null
    return (total - avail) / 1048576
}
