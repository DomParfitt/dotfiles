local defaults = {}

defaults.terminal = "alacritty"
defaults.editor = os.getenv("EDITOR") or "vim"

return defaults
