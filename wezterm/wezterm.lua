local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

local config = wezterm.config_builder()

local myPluginConfig = { enable = true, location = 'right' }
local nvim = wezterm.plugin.require 'https://github.com/mrjones2014/smart-splits.nvim'
nvim.apply_to_config(config, myPluginConfig)

-- local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
-- bar.apply_to_config(config)

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
    local process = pane.foreground_process_name or ''
    local cwd_uri = pane.current_working_dir
    local cwd = ''
    if cwd_uri then
        cwd = cwd_uri.file_path or ''
    end

    local proc = process:match("([^/]+)$") or process
    local dir = cwd:gsub('(.*[/\\])', '')

    local title = proc
    if dir ~= '' then
        title = dir .. ' · ' .. proc
    end

    local ws = ''
    if tab.window_id then
        local win = mux.get_window(tab.window_id)
        if win then
            ws = win:get_workspace()
        end
    end

    return {
        { Text = tab.tab_index + 1 .. ': ' .. title .. ' ' },
    }
end)

wezterm.on('update-right-status', function(window, pane)
    local scroll = pane:get_dimensions().active_line
    local total = pane:get_dimensions().scrollback_rows
    window:set_right_status(wezterm.format({
        { Text = string.format(" Pos: %d/%d ", scroll, total) },
    }))
end)

wezterm.on('update-status', function(window, pane)
    -- 获取当前面板的维度信息
    local dims = pane:get_dimensions()
    local status = ""

    -- active_line 是当前视口的第一行
    -- scrollback_rows 是整个缓冲区的行数
    -- viewport_rows 是当前窗口能显示的行数

    if dims.active_line == 0 then
        status = " TOP "
    elseif dims.active_line + dims.viewport_rows >= dims.scrollback_rows then
        status = " BOT "
    elseif dims.active_line + dims.viewport_rows < dims.scrollback_rows then
        -- 计算百分比
        local percent = math.floor(dims.active_line / (dims.scrollback_rows - dims.viewport_rows) * 100)
        status = string.format(" %d%% ", percent)
    else
        -- 回到最底部时显示时间或为空
        status = wezterm.strftime(" %H:%M:%S ")
    end

    window:set_right_status(wezterm.format({
        { Foreground = { Color = '#89b4fa' } }, -- 经典的淡蓝色，符合 macOS 审美
        { Background = { Color = '#1e1e2e' } },
        { Attribute = { Italic = true } },
        { Text = status },
    }))
end)

config.initial_cols = 140
config.initial_rows = 40
config.font_size = 14
config.adjust_window_size_when_changing_font_size = false
config.font = wezterm.font_with_fallback {
    -- "JetBrains Mono Nerd Font",
    "JetBrains Mono",
    "PingFang SC",
}
-- config.font = wezterm.font_with_fallback {
--   { family = "JetBrains Mono Nerd Font", weight = "Regular" },
--   { family = "JetBrains Mono", weight = "Regular" },
--   { family = "PingFang SC", weight = "Regular" },
-- }
-- config.color_scheme = 'Batman'
config.enable_tab_bar = true
config.enable_scroll_bar = true -- 开启滚动条
-- 4. 如果你使用的是 fancy tab bar，可以调整它的渲染
config.use_fancy_tab_bar = true
config.scrollback_lines = 100000
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false
-- config.macos_option_as_alt = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 10
config.use_ime = true
-- config.allow_square_glyphs_to_overflow_width = false

config.colors = {
    -- 自定义滚动条颜色
    scrollbar_thumb = '#585b70', -- 滚动滑块的颜色
    -- 如果你想让背景也有一点颜色（通常默认是透明或背景色）
    -- scroll_bar_bg = '#1e1e2e',
}

-- 如果你觉得默认的滚动条太占地方，可以配合窗口内边距调整
config.window_padding = {
    left = '1cell',
    right = '7pt', -- 给右侧留出一点空隙，防止滚动条紧贴边缘
    top = 0,
    bottom = 0,
}

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
    { key = 'a', mods = 'CMD',  action = act.CopyMode 'MoveToStartOfLine' },
    { key = 'e', mods = 'CMD',  action = act.CopyMode 'MoveToEndOfLineContent' },
    { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },

}

-- config.key_tables = {
--     search_mode = {
--         { key = 'a', mods = 'CMD',  action = act.CopyMode 'MoveToStartOfLine' },
--         { key = 'e', mods = 'CMD',  action = act.CopyMode 'MoveToEndOfLineContent' },
--         { key = 'u', mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
--     },
-- }

-- local helpers = require 'helpers'
-- helpers.apply_to_config(config)


return config
