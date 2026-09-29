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
    local dir = cwd:gsub('(.*[/\\])', ''):gsub('(.*[/\\])', '')

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

-- get_dimensions 不提供当前滚动视口位置；显示光标在缓冲区中的行号
-- 只保留一个状态回调，避免重复覆盖右侧状态栏
wezterm.on('update-status', function(window, pane)
    local dims = pane:get_dimensions()
    local cursor = pane:get_cursor_position()
    local total = dims.scrollback_rows
    local row = math.max(1, math.min(total, cursor.y - dims.scrollback_top + 1))

    window:set_right_status(wezterm.format({
        { Foreground = { Color = '#89b4fa' } },
        { Background = { Color = '#1e1e2e' } },
        { Attribute = { Italic = true } },
        { Text = string.format(" Cursor: %d/%d ", row, total) },
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

-- 全选当前面板及滚动历史，保留选区，等待用户复制或按 Esc 退出
local select_all = wezterm.action_callback(function(window, pane)
    -- 按顺序执行，确保进入复制模式后再扩展选区
    for _, action in ipairs {
        act.ActivateCopyMode,
        act.CopyMode 'ClearSelectionMode',
        act.CopyMode 'MoveToScrollbackTop',
        act.CopyMode 'MoveToStartOfLine',
        act.CopyMode { SetSelectionMode = 'Line' },
        act.CopyMode 'MoveToScrollbackBottom',
    } do
        window:perform_action(action, pane)
    end
end)

config.keys = {
    -- 系统剪贴板：macOS 使用 Cmd，Windows 使用 Ctrl+Shift
    { key = 'c', mods = 'SUPER', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'SUPER', action = act.PasteFrom 'Clipboard' },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
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
    { key = 'a', mods = 'CMD', action = select_all },
    {
        key = 'a',
        mods = wezterm.target_triple:find('windows') and 'CTRL' or 'CTRL|SHIFT',
        action = select_all,
    },
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

-- Windows：有选区时右键复制并取消选区，无选区时右键粘贴
-- 程序捕获鼠标时，按住 Shift 使用终端的选择和右键操作
if wezterm.target_triple:find('windows') then
    config.mouse_bindings = config.mouse_bindings or {}
    table.insert(config.mouse_bindings, {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local selection = window:get_selection_text_for_pane(pane)
            if selection ~= '' then
                window:perform_action(act.CopyTo 'Clipboard', pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act.PasteFrom 'Clipboard', pane)
            end
        end),
    })
end

return config
