local awful = require("awful")
local defaults = require("defaults")
local gears = require("gears")

-- Set up module table
local keys = {}

-- Use windows key as mod key
local modkey = "Mod4"

-- Spawn terminal
local spawn_terminal = awful.key(
    {modkey},
    "Return",
    function () awful.spawn(defaults.terminal) end,
    {description = "spawn a terminal", group = "launcher"}
)

local awesome_bindings = gears.table.join(
    awful.key(
        {modkey, "Control"},
        "r",
        awesome.restart,
        {description = "restart awesome", group = "awesome"}
    ),
    awful.key(
        {modkey, "Control"},
        "q",
        awesome.quit,
        {description = "quit awesome", group = "awesome"}
    )
)

-- Bindings for navigating between workspaces (tags)
local workspace_navigation = gears.table.join(
    awful.key(
        {modkey, "Control"},
        "Left",
        awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key(
        {modkey, "Control"},
        "Right",
        awful.tag.viewnext,
        {description = "view next", group = "tag"}
    )
)

-- Workspace navigation with numbers
for i = 1, 9 do
    workspace_navigation = gears.table.join(
        workspace_navigation,
        awful.key(
            {modkey},
            "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #" .. i, group = "tag"}
        )
    )
end

-- Move client focus in direction
local function move_focus(direction)
    awful.client.focus.bydirection(direction)
end

-- Bindings for navigating between windows (clients)
local window_navigation = gears.table.join(
    awful.key(
        {modkey},
        "Right",
        move_focus("right"),
        {description = "focus right", group = "client"}
    ),
    awful.key(
        {modkey},
        "Left",
        move_focus("left"),
        {description = "focus left", group = "client"}
    ),
    awful.key(
        {modkey},
        "Up",
        move_focus("up"),
        {description = "focus left", group = "client"}
    ),
    awful.key(
        {modkey},
        "Down",
        move_focus("down"),
        {description = "focus left", group = "client"}
    )
)

-- Swap client in direction
local function swap_client(direction)
    awful.client.swap.bydirection(direction)
end

-- Bindings for positioning windows
local window_positioning = gears.table.join(
    awful.key(
        {modkey, "Shift"},
        "Right",
        swap_client("right"),
        {description = "Swap current window with window to the right", group = "client"}
    ),
    awful.key(
        {modkey, "Shift"},
        "Left",
        swap_client("left"),
        {description = "Swap current window with window to the left", group = "client"}
    ),
    awful.key(
        {modkey, "Shift"},
        "Up",
        swap_client("up"),
        {description = "Swap current window with window above", group = "client"}
    ),
    awful.key(
        {modkey, "Shift"},
        "Down",
        swap_client("down"),
        {description = "Swap current window with window below", group = "client"}
    )
)

for i = 1, 9 do
    -- Move client to tag.
    window_positioning = gears.table.join(
        window_positioning,
        awful.key(
            {modkey, "Shift"},
            "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #" .. i, group = "tag"}
        )
    )
end

-- for i = 1, 9 do
--     -- Toggle tag display.
--     awful.key(
--         {modkey, "Control"},
--         "#" .. i + 9,
--         function()
--             local screen = awful.screen.focused()
--             local tag = screen.tags[i]
--             if tag then
--                 awful.tag.viewtoggle(tag)
--             end
--         end,
--         {description = "toggle tag #" .. i, group = "tag"}
--     )
-- end

-- Client specific keys
local clientkeys = gears.table.join(
    -- Toggle fullscreen
    awful.key(
        {modkey},
        "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}
    ),
    -- Close current window
    awful.key(
        {modkey, "Shift"},
        "c",
        function(c)
            c:kill()
        end,
        {description = "close", group = "client"}
    ),
    -- Toggle floating layout
    awful.key(
        {modkey, "Control"},
        "space",
        awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}
    )
)

keys.global = gears.table.join(
    awesome_bindings,
    spawn_terminal,
    workspace_navigation,
    window_navigation,
    window_positioning
)

keys.client = clientkeys

return keys
