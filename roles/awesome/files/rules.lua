local awful = require("awful")
local beautiful = require("beautiful")

local rules = {}

function rules.create(clientkeys)
    return {
        -- All clients will match this rule.
        {
            rule = {},
            properties = {
                border_width = beautiful.border_width,
                border_color = beautiful.border_normal,
                focus = awful.client.focus.filter,
                raise = true,
                keys = clientkeys,
                screen = awful.screen.preferred,
                placement = awful.placement.no_overlap + awful.placement.no_offscreen
            }
        },
        -- Add titlebars to normal clients and dialogs
        {
            rule_any = {type = {"normal", "dialog"}},
            properties = {titlebars_enabled = true}
        }
    }
end

return rules
