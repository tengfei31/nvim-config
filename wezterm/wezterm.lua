local wezterm = require 'wezterm'
local act = wezterm.action
local is_windows = wezterm.target_triple:find('windows') ~= nil
local is_macos = wezterm.target_triple:find('darwin') ~= nil
local primary = is_macos and 'CMD' or 'CTRL|SHIFT'
local secondary = is_macos and 'CMD|SHIFT' or 'CTRL|ALT'

-- 使用普通表累积插件快捷键，避免 config_builder 的表字段读取副本丢失插入操作。
local config = {}

-- 插件下载或加载失败时仍可使用基础终端；详细原因写入 WezTerm 日志。
local function apply_plugin(url, options)
    local ok, err = pcall(function()
        wezterm.plugin.require(url).apply_to_config(config, options)
    end)
    if not ok then
        wezterm.log_warn('Optional plugin failed: ' .. url .. ': ' .. tostring(err))
    end
end

apply_plugin('https://github.com/aureolebigben/wezterm-cmd-sender')
apply_plugin('https://github.com/abidibo/wezterm-sessions')
apply_plugin('https://github.com/mikkasendke/sessionizer.wezterm')
apply_plugin('https://github.com/mikkasendke/sessionizer-history')

apply_plugin('https://github.com/mrjones2014/smart-splits.nvim', {
    -- 避免占用 Shell 的 Ctrl+H/J/K/L；两端使用相同按键。
    modifiers = { move = 'ALT', resize = 'ALT|SHIFT' },
})

if is_windows then
    -- 用 where.exe 查找 PATH 中的 PowerShell 7，未安装时使用系统 PowerShell。
    local ok, stdout = wezterm.run_child_process { 'where.exe', 'pwsh.exe' }
    local pwsh = ok and stdout:match('[^\r\n]+') or nil
    config.default_prog = { pwsh or 'powershell.exe', '-NoLogo' }
    config.launch_menu = {
        { label = 'PowerShell', args = config.default_prog },
        { label = 'Windows PowerShell', args = { 'powershell.exe', '-NoLogo' } },
        { label = 'Command Prompt', args = { 'cmd.exe' } },
    }
    -- 已安装的 WSL 发行版由 WezTerm 的域发现机制加入启动菜单。
end

wezterm.on('format-tab-title', function(tab)
    local pane = tab.active_pane
    local process = pane.foreground_process_name or ''
    local cwd_uri = pane.current_working_dir
    local cwd = ''
    if cwd_uri then
        cwd = cwd_uri.file_path or ''
    end

    local proc = process:match("([^/\\]+)$") or process
    local dir = cwd:gsub('[/\\]+$', ''):match('([^/\\]+)$') or cwd

    local title = proc ~= '' and proc or pane.title
    if dir ~= '' then
        title = dir .. ' · ' .. title
    end

    if tab.tab_title and tab.tab_title ~= '' then
        title = tab.tab_title
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
    is_windows and "Microsoft YaHei" or "PingFang SC",
    is_windows and "Consolas" or "Menlo",
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
config.window_background_opacity = is_windows and 0.95 or 0.85
if is_macos then
    config.macos_window_background_blur = 10
end
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

local keys = {
    -- 系统剪贴板：macOS 使用 Cmd，Windows 使用 Ctrl+Shift
    { key = 'c', mods = primary, action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = primary, action = act.PasteFrom 'Clipboard' },
    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo 'Clipboard' },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { -- 重命名tab
        key = 'r',
        mods = secondary,
        action = wezterm.action.PromptInputLine {
            description = 'Rename Tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line and line:match('%S') then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },
    -- 创建 / 切换 workspace
    {
        key = "w",
        mods = secondary,
        action = act.PromptInputLine {
            description = "Enter workspace name",
            action = wezterm.action_callback(function(window, pane, line)
                if line and line:match('%S') then
                    window:perform_action(act.SwitchToWorkspace {
                        name = line,
                    }, pane)
                end
            end),
        },
    },
    -- 下一个 workspace
    { key = "]", mods = primary, action = act.SwitchWorkspaceRelative(1) },
    { key = "[", mods = primary, action = act.SwitchWorkspaceRelative(-1) },
    {
        key = "m",
        mods = secondary,
        action = act.PromptInputLine {
            description = "Move window (all tabs) to workspace",
            action = wezterm.action_callback(function(window, pane, line)
                if line and line:match('%S') then
                    window:mux_window():set_workspace(line)
                    window:perform_action(act.SwitchToWorkspace { name = line }, pane)
                end
            end),
        },
    },
    { key = 's', mods = secondary, action = act.EmitEvent 'load_session' },
    { key = 'a', mods = primary, action = select_all },
    { key = 't', mods = primary, action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = primary, action = act.CloseCurrentPane { confirm = true } },
    { key = 'f', mods = primary, action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'p', mods = primary, action = act.ShowLauncherArgs { flags = 'FUZZY|LAUNCH_MENU_ITEMS|DOMAINS|WORKSPACES' } },
    { key = 'd', mods = primary, action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'd', mods = secondary, action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = 'z', mods = secondary, action = act.TogglePaneZoomState },
    { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
    { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
}

-- Option+方向键仅在 macOS 转换；Windows 将 Ctrl+方向键原样交给 Shell。
if is_macos then
    table.insert(keys, { key = 'LeftArrow', mods = 'ALT', action = act.SendKey { key = 'b', mods = 'META' } })
    table.insert(keys, { key = 'RightArrow', mods = 'ALT', action = act.SendKey { key = 'f', mods = 'META' } })
end

-- 保留插件注册的快捷键；自定义按键在冲突时优先。
local merged = {}
local function merge_key(binding)
    for i, existing in ipairs(merged) do
        if existing.key == binding.key and existing.mods == binding.mods then
            merged[i] = binding
            return
        end
    end
    table.insert(merged, binding)
end
for _, binding in ipairs(config.keys or {}) do merge_key(binding) end
for _, binding in ipairs(keys) do merge_key(binding) end
config.keys = merged

-- local helpers = require 'helpers'
-- helpers.apply_to_config(config)

-- Windows：有选区时右键复制并取消选区，无选区时右键粘贴
-- 程序捕获鼠标时，按住 Shift 使用终端的选择和右键操作
if is_windows then
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
