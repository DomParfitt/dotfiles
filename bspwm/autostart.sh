#!/usr/bin/env bash

# Keybindings daemon
sxhkd &

# Map super to super+shift+space
xcape -e 'Super_L=Super_L|a' &

# Compositor
compton -b

# Status Bar
# polybar top &