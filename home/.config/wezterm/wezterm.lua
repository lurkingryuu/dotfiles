local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- rose-pine-moon's bundled palette maps ANSI white/bright-white to the same
-- hex as `foreground` (#e0def4). Apps that fill a highlight box with ANSI
-- white (e.g. Claude Code's "new content" highlight) end up drawing
-- foreground-colored text on a foreground-colored background - invisible.
-- Override just the white slots with a distinct Rose Pine tone (highlightHigh)
-- so highlight boxes stay legible; everything else about the theme is unchanged.
local scheme = wezterm.color.get_builtin_schemes()["rose-pine-moon"]
scheme.ansi[8] = "#56526e"
scheme.brights[8] = "#56526e"
config.colors = scheme
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

return config
