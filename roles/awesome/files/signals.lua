local awful = require("awful")
local beautiful = require("beautiful")
-- local theme = require("theme")
local utils = require("utils")

-- Signal function to execute when a new client appears.
client.connect_signal(
    "manage",
    function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        if not awesome.startup then
            awful.client.setslave(c)
        end

        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end

        -- If the tag layout is set to floating, also set the client to floating
        local floating_tag = c.first_tag.layout == awful.layout.suit.floating
        if floating_tag then
            c.floating = true
        end

        utils.show_titlebar(c, c.floating)
    end
)

-- Show titlebar when a window becomes floating
client.connect_signal(
    "property::floating",
    function(c)
        utils.show_titlebar(c, c.floating)
    end
)

-- When a workspace layout changes to floating set all windows as floating
-- and show their titlebars
tag.connect_signal(
    "property::layout",
    function(t)
        local floating = t.layout == awful.layout.suit.floating
        for _, c in pairs(t:clients()) do
            c.floating = floating
            utils.show_titlebar(c, floating)
        end
    end
)

-- Create a titlebar for a window when requested
local create_titlebar = require("widgets.titlebar")
client.connect_signal("request::titlebars", create_titlebar)

-- Focus window with mouse
client.connect_signal(
    "mouse::enter",
    function(c)
        c:emit_signal("request::activate", "mouse_enter", {raise = false})
    end
)

-- Set window border colors based on focus
client.connect_signal(
    "focus",
    function(c)
        c.border_color = beautiful.border_focus
    end
)
client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", utils.set_wallpaper)
