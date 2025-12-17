return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "vim", "bash", "rust",
                    "cpp", "c", "go", "php",
                    "javascript", "typescript", "json"
                },
                highlight = { enable = true },
                indent = { enable = true },
                -- install_dir = vim.fn.stdpath('data') .. '/site',
            })
        end,
    }
}

