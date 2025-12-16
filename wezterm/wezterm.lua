local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

local myPluginConfig = { enable = true, location = 'right' }
local nvim = wezterm.plugin.require 'https://github.com/mrjones2014/smart-splits.nvim'
nvim.apply_to_config(config, myPluginConfig)

local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(config)

local cmd_sender = wezterm.plugin.require("https://github.com/aureolebigben/wezterm-cmd-sender")
cmd_sender.apply_to_config(config)

local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local sessions = wezterm.plugin.require("https://github.com/abidibo/wezterm-sessions")
sessions.apply_to_config(config)

local sessionizer = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer.wezterm"
sessionizer.apply_to_config(config)
local history = wezterm.plugin.require "https://github.com/mikkasendke/sessionizer-history"
history.apply_to_config(config)

wezterm.on('format-tab-title', function(tab)
  local pane = tab.active_pane
  local ws = tab.window.workspace
  local process = pane.foreground_process_name or ''
  local cwd = pane.current_working_dir or ''

  local proc = process:match("([^/]+)$") or process
  local dir = cwd:gsub('(.*[/\\])', '')

  local title = proc
  if dir ~= '' then
    title = dir .. ' · ' .. proc
  end

  return {
    { Text = ' [' .. ws .. '] ' .. tab.tab_index + 1 .. ': ' .. title .. ' ' },
  }
end)

config.initial_cols = 140
config.initial_rows = 40
config.font_size = 14
-- config.color_scheme = 'Batman'
config.enable_tab_bar = true
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
-- config.macos_option_as_alt = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 10

config.keys = {
    {
      key = 'LeftArrow',
      mods = 'OPT',
      action = wezterm.action.SendKey { key = 'b', mods = 'META' },
    },
    {
      key = 'RightArrow',
      mods = 'OPT',
      action = wezterm.action.SendKey { key = 'f', mods = 'META' },
    },
    { -- 重命名tab
      key = 'r',
      mods = 'CMD|SHIFT',
      action = wezterm.action.PromptInputLine {
        description = 'Rename Tab',
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:active_tab():set_title(line)
          end
        end),
      },
    },
    -- 创建 / 切换 workspace
    {
      key = "w",
      mods = "CMD|SHIFT",
      action = act.PromptInputLine {
        description = "Enter workspace name",
        action = wezterm.action_callback(function(window, pane, line)
          if line then
            window:perform_action(act.SwitchToWorkspace {
              name = line,
            }, pane)
          end
        end),
      },
    },
    -- 下一个 workspace
    { key = "]", mods = "CMD", action = act.SwitchWorkspaceRelative(1) },
    { key = "[", mods = "CMD", action = act.SwitchWorkspaceRelative(-1) },
    {
        key = "m",
        mods = "CMD|SHIFT",
        action = act.PromptInputLine {
            description = "Move tab to workspace",
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:perform_action(
                        act.MoveTabToWorkspace { workspace = line },
                        pane
                    )
                end
            end),
        },
    },
}

-- local helpers = require 'helpers'
-- helpers.apply_to_config(config)


return config
