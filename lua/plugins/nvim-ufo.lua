return {
  "kevinhwang91/nvim-ufo",
  dependencies = "kevinhwang91/promise-async",
  config = function()
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
    require("ufo").setup()
  end,
}
