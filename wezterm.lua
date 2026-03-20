-- ~/.wezterm.lua
local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

-- ===== Appearance =====
config.color_scheme = "Catppuccin Frappe"
config.font_size = 13.0
config.cursor_blink_rate = 1000
config.cursor_blink_ease_out = "EaseInOut"
config.cursor_blink_ease_in = "EaseInOut"
config.window_decorations = "RESIZE"
config.audible_bell = "Disabled"
config.enable_scroll_bar = false
config.scrollback_lines = 5000
config.enable_kitty_keyboard = true
config.set_environment_variables = { TERM = "xterm-256color" }

-- Hide WezTerm's tab bar — tmux handles all of that
config.enable_tab_bar = false

-- ===== Keybindings =====
-- Minimal — tmux handles splits, panes, windows, sessions, and copy mode
config.keys = {
	-- Quick clear (WezTerm level, mirrors tmux C-g binding)
	{
		key = "g",
		mods = "CTRL",
		action = act.Multiple({
			act.SendKey({ key = "c", mods = "CTRL" }),
			act.SendKey({ key = "l", mods = "CTRL" }),
			act.ClearScrollback("ScrollbackAndViewport"),
		}),
	},

	-- Ctrl+Enter → CSI-u sequence for apps that need it (e.g. Harlequin)
	{ key = "Enter", mods = "CTRL", action = act.SendString("\x1b[13;5u") },
}

return config
