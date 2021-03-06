local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

-- Create a titlebar for a given window
local function titlebar(client)
    -- buttons for the titlebar
    local buttons =
        gears.table.join(
        awful.button(
            {},
            1,
            function()
                client:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.move(client)
            end
        ),
        awful.button(
            {},
            3,
            function()
                client:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.resize(client)
            end
        )
    )

    awful.titlebar(client):setup {
        {
            -- Left
            awful.titlebar.widget.iconwidget(client),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        {
            -- Middle
            {
                -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(client)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        {
            -- Right
            awful.titlebar.widget.maximizedbutton(client),
            awful.titlebar.widget.closebutton(client),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end

return titlebar
