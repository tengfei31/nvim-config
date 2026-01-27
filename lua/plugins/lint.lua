-- lua/plugins/formatter.lua
return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost", "InsertLeave" },
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                php = {}, -- { "phpstan" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                python = { "flake8" },
                sh = { "shellcheck" },
                lua = { "luacheck" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function()
                    lint.try_lint()
                end,
            })

            -- 命令：手动格式化当前 buffer
            vim.api.nvim_create_user_command("Format", function(opts)
                vim.lsp.buf.format({ async = false })
            end, { desc = "Format current buffer with LSP/null-ls" })

            -- 快捷键（可放到 core/keymaps.lua）
            vim.keymap.set("n", "<leader>F", function()
                vim.cmd("Format")
            end, { desc = "Format buffer" })
        end,
    },
}
