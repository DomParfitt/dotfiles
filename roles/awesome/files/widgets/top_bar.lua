local awful = require("awful")
local beautiful = require("beautiful")
local defaults = require("defaults")
local gears = require("gears")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local wibox = require("wibox")

-- Create a textclock widget
local function clock()
    return wibox.widget.textclock()
end

-- Create a systray widget and ensure it is visible
local function systray()
    local systray = wibox.widget.systray()
    systray.visible = true
    return systray
end

-- Create the main menu
local function main_menu()
    -- Menu entry for Awesome related stuff
    local awesome_menu = {
        {
            "hotkeys",
            function()
                hotkeys_popup.show_help(nil, awful.screen.focused())
            end
        },
        {"manual", defaults.terminal .. " -e man awesome"},
        {"edit config", defaults.terminal .. " -e " .. defaults.editor .. " " .. awesome.conffile},
        {"restart", awesome.restart},
        {"quit", awesome.quit}
    }

    -- Main menu
    local main_menu =
        awful.menu(
        {
            items = {
                {"awesome", awesome_menu, beautiful.awesome_icon},
                {"open terminal", defaults.terminal}
            }
        }
    )

    menubar.utils.terminal = defaults.terminal -- Set the terminal for applications that require it

    -- Button to launch the main menu
    return awful.widget.launcher(
        {
            image = beautiful.awesome_icon,
            menu = main_menu
        }
    )
end

-- Create a taglist widget
local function taglist(screen)
    local buttons = gears.table.join(
        awful.button(
            {},
            1,
            function(t)
                t:view_only()
            end
        ),
        awful.button({}, 3, awful.tag.viewtoggle),
        awful.button(
            {},
            4,
            function(t)
                awful.tag.viewprev(t.screen)
            end
        ),
        awful.button(
            {},
            5,
            function(t)
                awful.tag.viewnext(t.screen)
            end
        )
    )

    return awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        buttons = buttons
    }
end

-- Create a selector for the layout
local function layout_selector(screen)
    local layoutbox = awful.widget.layoutbox(screen)
    layoutbox:buttons(
        gears.table.join(
            awful.button(
                {},
                1,
                function()
                    awful.layout.inc(1)
                end
            ),
            awful.button(
                {},
                3,
                function()
                    awful.layout.inc(-1)
                end
            )
        )
    )

    return layoutbox
end

local function bar(screen)
    local top_bar = awful.wibar({position = "top", screen = screen})
    top_bar:setup {
        layout = wibox.layout.align.horizontal,
        {
            -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            main_menu(),
            taglist(screen),
            awful.widget.prompt()
        },
        {
            -- Middle widgets
            layout = wibox.layout.align.horizontal,
            clock(),
        },
        {
            -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            systray(),
            layout_selector(screen)
        }
    }
    return top_bar
end

return bar
