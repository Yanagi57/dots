.pragma library

// Wi-Fi networks for the list: drop hidden (nameless) ones, keep the strongest entry per
// name, connected first, then by signal strength. At most `max`.
function sortNetworks(list, max) {
    const best = {}
    for (const n of list) {
        if (!n.name) continue
        const b = best[n.name]
        if (!b || n.connected || (!b.connected && n.signalStrength > b.signalStrength)) best[n.name] = n
    }
    return Object.keys(best).map(k => best[k])
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
        .slice(0, max)
}

// Bluetooth devices: nameless ones dropped; connected, then paired, then by name.
function sortDevices(list) {
    return list.filter(d => d.name)
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
}
