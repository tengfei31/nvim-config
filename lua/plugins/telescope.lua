return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_strategy = "horizontal",
                },
            })
            vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
            vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>")
        end,
    }
}
