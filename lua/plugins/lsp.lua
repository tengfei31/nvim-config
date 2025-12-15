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
                phpactor = {
                    cmd = { 'phpactor', 'language-server' },
                    filetypes = { 'php' },
                    root_markers = { '.git', 'composer.json', '.phpactor.json', '.phpactor.yml' },
                    workspace_required = true,
                    init_options = {
                        ["language_server_phpstan.enabled"] = false,
                        ["language_server_psalm.enabled"] = false,
                    },
                },
                rust_analyzer = {},
            }
            -- vim.lsp.enable('phpactor')

            local make = vim.lsp.config.make

            for name, opts in ipairs(servers) do
                vim.lsp.enable(name)
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

