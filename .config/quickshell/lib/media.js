.pragma library

// Which MPRIS player the bar shows: a playing one first, else the first real one.
function pick(players) {
    const real = players.filter(p => p.dbusName.indexOf("playerctld") === -1)
    return real.find(p => p.isPlaying) || real[0] || null
}

// Icons key for a player ("spotify" | "firefox" | "play").
function iconKey(player) {
    const id = ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase()
    if (id.indexOf("spotify") !== -1) return "spotify"
    if (id.indexOf("firefox") !== -1) return "firefox"
    return "play"
}
