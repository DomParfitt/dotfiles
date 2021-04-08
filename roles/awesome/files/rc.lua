-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local gears = require("gears")
local keys = require("keybindings")
local naughty = require("naughty")
local rules = require("rules")
require("signals")
local utils = require("utils")

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors
        }
    )
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function(err)
            -- Make sure we don't go into an endless error loop
            if in_error then
                return
            end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end

-- Set theme
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/onedark.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating
}

-- Set up screens
local create_bar = require("widgets.top_bar")
awful.screen.connect_for_each_screen(
    function(s)
        -- Set the wallpaper
        utils.set_wallpaper(s)

        -- Set the tags
        awful.tag({"I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"}, s, awful.layout.layouts[1])

        -- Create the top bar
        create_bar(s)
    end
)

-- Keybindings
root.keys(keys.global)

-- Rules
awful.rules.rules = rules.create(keys.client)
