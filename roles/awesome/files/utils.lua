local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local utils = {}

-- Set the wallpaper for a given screen
function utils.set_wallpaper(screen)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(screen)
        end
        gears.wallpaper.maximized(wallpaper, screen, true)
    end
end

-- Show or hide the titlebar on a given client
function utils.show_titlebar(client, show)
    if show then
        if client.titlebar == nil then
            client:emit_signal("request::titlebars", "rules", {})
        end
        awful.titlebar.show(client)
    else
        awful.titlebar.hide(client)
    end
end

return utils
