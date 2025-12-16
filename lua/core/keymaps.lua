local map = vim.keymap.set

vim.g.mapleader = " "

-- map("n", "<leader>f", ":Telescope find_files<CR>")
map("n", "<leader>f", function()
    require("conform").format()
end, { desc = "Format buffer" })
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

-- 左右键在行首/行尾自动跨行
-- map({ "n", "v" }, "<Left>",  "g<Left>")
-- map({ "n", "v" }, "<Right>", "g<Right>")















