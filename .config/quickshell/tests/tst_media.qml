import QtQuick
import QtTest
import "../lib/media.js" as Media

TestCase {
    name: "Media"

    function p(name, playing, entry) {
        return { dbusName: "org.mpris.MediaPlayer2." + name, isPlaying: playing, desktopEntry: entry || "", identity: name }
    }

    function test_pick_prefers_playing() {
        const a = p("firefox", false), b = p("spotify", true)
        compare(Media.pick([a, b]), b)
    }
    function test_pick_ignores_playerctld() {
        const ctl = p("playerctld", true), a = p("mpv", false)
        compare(Media.pick([ctl, a]), a)
        compare(Media.pick([ctl]), null)
        compare(Media.pick([]), null)
    }
    function test_iconKey() {
        compare(Media.iconKey(p("spotify", true, "spotify")), "spotify")
        compare(Media.iconKey(p("Mozilla Firefox", true, "firefox")), "firefox")
        compare(Media.iconKey(p("mpv", true)), "play")
    }
}
