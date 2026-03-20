-- ~/.wezterm.lua
local wezterm = require("wezterm")
local act = wezterm.action
local is_windows = wezterm.target_triple:find("windows") ~= nil

local config = wezterm.config_builder()

-- ===== Appearance (shared) =====
config.color_scheme = "Catppuccin Frappe"
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 13.0
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }
config.audible_bell = "Disabled"
config.enable_scroll_bar = false
config.scrollback_lines = 5000
config.animation_fps = 60
config.max_fps = 120

-- ===== Windows =====
if is_windows then
	config.default_prog = { "wsl.exe", "--distribution", "Ubuntu", "--exec", "/bin/zsh" }

	config.default_cursor_style = "BlinkingBlock"
	config.cursor_blink_rate = 500

	config.window_background_opacity = 1.0
	config.initial_cols = 220
	config.initial_rows = 50

	config.enable_tab_bar = true
	config.use_fancy_tab_bar = true
	config.hide_tab_bar_if_only_one_tab = true
	config.tab_bar_at_bottom = false

	config.launch_menu = {
		{ label = "WSL Ubuntu (zsh)", args = { "wsl.exe", "--distribution", "Ubuntu", "--exec", "/bin/zsh" } },
		{ label = "PowerShell 7", args = { "pwsh.exe" } },
		{ label = "Windows PowerShell", args = { "powershell.exe" } },
		{ label = "CMD", args = { "cmd.exe" } },
	}

	config.keys = {
		{ key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
		{ key = "RightArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
		{ key = "LeftArrow", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
		{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
		{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	}

-- ===== Unix / macOS =====
else
	config.cursor_blink_rate = 1000
	config.cursor_blink_ease_in = "EaseInOut"
	config.cursor_blink_ease_out = "EaseInOut"

	config.window_decorations = "RESIZE"
	config.enable_kitty_keyboard = true
	config.set_environment_variables = { TERM = "xterm-256color" }

	-- tmux handles splits, panes, windows, sessions, and copy mode
	config.enable_tab_bar = false

	config.keys = {
		-- Quick clear (mirrors tmux C-g binding)
		{
			key = "g",
			mods = "CTRL",
			action = act.Multiple({
				act.SendKey({ key = "c", mods = "CTRL" }),
				act.SendKey({ key = "l", mods = "CTRL" }),
				act.ClearScrollback("ScrollbackAndViewport"),
			}),
		},
	}
end

return config
