local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- map("n", "<leader>f", ":Telescope find_files<CR>")
-- map("n", "<leader>f", function()
--     require("conform").format()
-- end, { desc = "Format buffer" })
map("n", "<leader>g", ":Telescope live_grep<CR>")
-- map("n", "<leader>e", ":Telescope buffers<CR>")
map("n", "<leader>t", ":Telescope help_tags<CR>")

map("n", "<leader>q", ":q<CR>")
map("n", "<leader>w", ":w<CR>")

-- 保存
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<cr>i", { desc = "Save" })

-- macOS GUI 才支持 Command
map("n", "<D-s>", "<cmd>w<cr>", { desc = "Save (Cmd+s)" })
map("i", "<D-s>", "<Esc><cmd>w<cr>i", { desc = "Save (Cmd+s)" })
map("n", "<leader>F", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format Buffer" })

-- macOS
if vim.fn.has("mac") == 1 then
    map({ "n", "v" }, "<D-c>", '"+y')
    map({ "n", "v" }, "<D-v>", '"+p')
    map("i", "<D-v>", '<C-r>+')
end

-- 左右键在行首/行尾自动跨行
-- map({ "n", "v" }, "<Left>",  "g<Left>")
-- map({ "n", "v" }, "<Right>", "g<Right>")

-- 普通模式下 Ctrl + / 注释当前行
map("n", "<leader>_", "gcc", { remap = true, desc = "Comment line" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Comment line" })
-- 可视模式下 Ctrl + / 注释选中区域
map("v", "<leader>_", "gc", { remap = true, desc = "Comment selection" })
map("v", "<leader>/", "gc", { remap = true, desc = "Comment selection" })

-- 适配 WezTerm/iTerm2 的单词跳跃
-- 正常情况下，Meta+f 是 w (word), Meta+b 是 b (back)
-- 普通 / 可视模式
map({ "n", "v" }, "<M-b>", "b", { desc = "Prev word" })
map({ "n", "v" }, "<M-f>", "w", { desc = "Next word" })

-- 插入模式（不退出 insert）
map("i", "<M-b>", "<C-o>b", { desc = "Prev word (insert)" })
map("i", "<M-f>", "<C-o>w", { desc = "Next word (insert)" })

