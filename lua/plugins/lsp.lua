return {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "folke/neodev.nvim",
        },
        config = function()
            require("mason").setup({})
            require("neodev").setup({})

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            -- local lspconfig = require("lspconfig")

            local servers = {
                lua_ls = {},
                gopls = {},
                clangd = {},
                tsserver = {},
                pyright = {},
                intelephense = {},
                rust_analyzer = {},
            }

            local make = vim.lsp.config.make

            for name, opts in ipairs(servers) do
                opts.capabilities = capabilities
                local config = make(name, opts)
                vim.lsp.start(config)
            end

            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gr", vim.lsp.buf.references)
            vim.keymap.set("n", "K", vim.lsp.buf.hover)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
        end
    }
}

