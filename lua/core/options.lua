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

o.wrap = false

o.splitbelow = true
o.splitright = true
o.mouse = "a"

o.clipboard = "unnamedplus"

o.statusline = "%f %{fnamemodify(getcwd(), ':t')}"

vim.g.format_on_save = true


