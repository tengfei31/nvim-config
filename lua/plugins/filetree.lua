return {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
        require("neo-tree").setup({})
        vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
    end
}

