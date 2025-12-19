return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require('gitsigns').setup({
            current_line_blame = true, -- 核心配置：启用虚拟文本显示提交信息
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 选项：'eol' (行尾), 'overlay', 'right_align'
                delay = 100,           -- 光标停顿多久后显示 (毫秒)
            },
            current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d %H:%m> - <summary>',
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns
                -- 快捷键查看详细 blame 弹窗
                vim.keymap.set('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "查看详细Git记录" })
                -- 在你的颜色配置中
                vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', {
                    fg = '#5c6370', -- 设置为暗灰色
                    italic = true -- 设置为斜体
                })
            end,
        })
    end
}
