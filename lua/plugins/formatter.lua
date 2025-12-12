-- lua/plugins/formatter.lua
return {
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })

      -- 配置 sources，根据需要启/停
      null_ls.setup({
        debug = false,
        sources = {
          -- 通用
          formatting.prettier.with({
            filetypes = { "javascript", "typescript", "json", "yaml", "markdown", "html", "css", "scss" },
          }),
          -- PHP
          formatting.phpcsfixer.with({
            command = "php-cs-fixer", -- or "phpcbf" if you prefer
            filetypes = { "php" },
          }),
          -- Go
          formatting.gofmt,
          formatting.gofumpt,
          -- Rust
          formatting.rustfmt,
          -- C/C++
          formatting.clang_format,
          -- Python
          formatting.black,
          formatting.isort,
          -- shell
          formatting.shfmt,
        },

        -- 选择是否在保存时自动格式化
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            -- 先移除已有的自动命令，避免重复
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            -- 默认不开启自动保存格式化；你可以在 options.lua 中暴露开关
            local format_on_save = vim.g.format_on_save
            if format_on_save == nil then
              format_on_save = false
            end

            if format_on_save then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = augroup,
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ bufnr = bufnr })
                end,
              })
            end
          end
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

