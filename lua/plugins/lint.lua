-- lua/plugins/lint.lua
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

            -- 手动格式化命令（快捷键 <leader>cf 在 core/keymaps.lua）
            vim.api.nvim_create_user_command("Format", function()
                vim.lsp.buf.format({ async = true })
            end, { desc = "Format current buffer with LSP" })
        end,
    },
}
