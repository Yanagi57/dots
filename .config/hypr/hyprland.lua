-- ~/.config/hypr/hyprland.lua
-- Original conf preserved at hyprland.conf


------------------
---- MONITORS ----
------------------

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@144",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@120",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "wofi --show drun"
local browser     = "zen-browser"


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("waybar > ~/.cache/waybar.log 2>&1")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("awww-daemon & awww img $HOME/.config/backgrounds/khaled-ali-unsplash.jpg")
    hl.exec_cmd("fcitx5 --replace -d")
    hl.exec_cmd("nm-applet")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE",                 "10")
hl.env("HYPRCURSOR_SIZE",              "10")
hl.env("HYPRSHOT_DIR",                 "$HOME/screenshots")
hl.env("QT_IM_MODULE",                 "fcitx")
hl.env("SDL_IM_MODULE",                "fcitx")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "x11")
hl.env("LIBVA_DRIVER_NAME",            "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME",    "nvidia")
hl.env("NVD_BACKEND",                  "direct")
hl.env("LC_TIME",                      "en_GB.UTF-8")


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in         = 2,
        gaps_out        = 5,
        gaps_workspaces = 50,
        border_size     = 1,

        col = {
            active_border   = "rgb(384B55)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 8,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled           = true,
            size              = 10,
            passes            = 3,
            vibrancy          = 0.1696,
            new_optimizations = true,
            xray              = true,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default",  style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    misc = {
        force_default_wallpaper = 1,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,
        sensitivity  = 0,

        touchpad = {
            natural_scroll = true,
            tap_and_drag   = true,
        },

        numlock_by_default = true,
    },

    cursor = {
        no_hardware_cursors = true,
        no_break_fs_vrr     = true,
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + Return",            hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",                 hl.dsp.window.close())
hl.bind(mainMod .. " + B",                 hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + SHIFT + Backspace", hl.dsp.exit())
hl.bind(mainMod .. " + E",                 hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F",                 hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SHIFT + D",         hl.dsp.exec_cmd("hyprctl dispatch dpms off && sleep 1 && hyprctl dispatch dpms on"))
hl.bind(mainMod .. " + Space",             hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + C",                 hl.dsp.exec_cmd("wofi-calc"))
hl.bind(mainMod .. " + M",                 hl.dsp.exec_cmd("wofi-emoji"))
hl.bind(mainMod .. " + Tab",               hl.dsp.exec_cmd("hyprctl dispatch cyclenext"))
hl.bind(mainMod .. " + SHIFT + W",         hl.dsp.exec_cmd("pkill waybar; waybar"))

-- Dwindle
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit"))

-- Lock / logout
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.exec_cmd("wlogout --protocol layer-shell -T 300 -B 300 -L 430 -R 430"))

-- Screenshots
hl.bind("PRINT",         hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m window"))

-- Move focus (HJKL)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move windows (HJKL)
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.exec_cmd("hyprctl dispatch workspace e+1"))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.exec_cmd("hyprctl dispatch workspace e-1"))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume & brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 3%+"),                          { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 3%-"),                          { locked = true, repeating = true })

-- Lid switch
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("hyprctl dispatch dpms off"), { locked = true })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms on"),  { locked = true })

-- Media keys
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name         = "idle-inhibit-fullscreen",
    match        = { fullscreen = true },
    idle_inhibit = "fullscreen",
})

hl.window_rule({
    name  = "float-media-viewer",
    match = { title = "^Media viewer$" },
    float = true,
})

hl.window_rule({
    name  = "pip",
    match = { title = "^Picture-in-Picture$" },
    float   = true,
    no_blur = true,
    pin     = true,
})

hl.window_rule({
    name  = "float-cavalier",
    match = { title = "^Cavalier$" },
    float = true,
})
