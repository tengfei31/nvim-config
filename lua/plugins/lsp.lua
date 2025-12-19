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
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- "bashls",
                }
            })
            require("neodev").setup({})

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local servers = {
                sh = {},
                bashls = {
                    filetypes = { "sh", "bash", "zsh" },
                    settings = {
                        globPattern = "*@(.sh|.inc|.bash|.command|.zsh)",
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = {
                                version = "LuaJIT",
                            },
                            diagnostics = {
                                globals = { "vim" },
                            },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = {
                                enable = false,
                            },
                            format = {
                                enable = true, -- 关键：开启 LSP format
                            },
                        },
                    },
                },
                gopls = {},
                clangd = {},
                ts_ls = {},
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

            for name, opts in pairs(servers) do
                opts.capabilities = capabilities
                vim.lsp.config(name, opts)
                vim.lsp.enable(name)
            end

            vim.keymap.set("n", "gd", vim.lsp.buf.definition)
            vim.keymap.set("n", "gr", vim.lsp.buf.references)
            vim.keymap.set("n", "K", vim.lsp.buf.hover)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
        end
    }
}
