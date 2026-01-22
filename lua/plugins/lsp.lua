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
                    "rust_analyzer",
                    "phpactor",
                    -- "ts_ls",
                    "clangd",
                    "lua_ls",
                    "gopls",
                }
            })
            require("neodev").setup({})

            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.general = capabilities.general or {}
            capabilities.general.positionEncodings = { "utf-16" }

            local servers = {
                -- sh = {},
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
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--completion-style=detailed",
                        "--header-insertion=iwyu",
                        "--fallback-style=LLVM",
                        "--log=error",
                    },
                    on_attach = function(client)
                        -- client.server_capabilities.semanticTokensProvider = nil
                    end,
                },
                -- ts_ls = {},
                -- pyright = {},
                -- intelephense = {},
                phpactor = {
                    cmd = { 'phpactor', 'language-server' },
                    filetypes = { 'php' },
                    settings = {
                        phpactor = {
                            language_server_phpstan = {
                                enabled = false,
                            },
                            language_server_psalm = {
                                enabled = false,
                            },
                        },
                    },
                },
                rust_analyzer = {
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                -- allFeatures = false,
                                loadOutDirsFromCheck = true,
                            },
                            rustc = {
                                source = "discover",
                            },
                            procMacro = {
                                enable = true,
                            },
                            inlayHints = {
                                enable = true,

                                parameterHints = {
                                    enable = true,
                                },

                                typeHints = {
                                    enable = true,
                                },

                                chainingHints = {
                                    enable = true,
                                },

                                lifetimeElisionHints = {
                                    enable = "skip_trivial",
                                },
                            },
                        },
                    },
                    on_attach = function(client, bufnr)
                        if client.server_capabilities.inlayHintProvider then
                            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                    end,
                },
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

            vim.lsp.set_log_level("error")
            vim.lsp.inlay_hint.enable(true)

            vim.diagnostic.config({
                virtual_text = {
                    prefix = "●",
                    spacing = 4,
                },
                signs = true,
                underline = true,
                update_in_insert = false,
                severity_sort = true,
            })
        end
    }
}
