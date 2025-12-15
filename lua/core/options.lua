local o = vim.opt

o.number = true
o.relativenumber = true
o.cursorline = true
o.termguicolors = true

o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4

o.smartindent = true

o.ignorecase = true
o.smartcase = true

-- 启用自动换行（显示层面，不改文件内容）
o.wrap = true
o.whichwrap:append("b,s,<,>,[,]")

-- 让 wrap 后的行有缩进，避免视觉混乱
o.linebreak = true
o.breakindent = true

o.hidden = true      -- 切 buffer 不丢位置
o.scrolloff = 4     -- 光标上下保留行，体验更人性

o.splitbelow = true
o.splitright = true
o.mouse = "a"

o.clipboard = "unnamedplus"

o.statusline = "%f %{fnamemodify(getcwd(), ':t')}"

vim.g.format_on_save = true

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})


