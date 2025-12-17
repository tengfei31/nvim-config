return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	opts = {
		format_on_save = {
			timeout_ms = 3000,
			lsp_fallback = true,
		},
		formatters_by_ft = {
			lua = { "stylua" },
			php = { "php_cs_fixer" },
			go = { "gofmt" },
			javascript = { "prettier" },
			typescript = { "prettier" },
			python = { "black" },
			json = { "prettier" },
			yaml = { "prettier" },
			sh = { "shfmt" },
		},
	},
	config = function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*.lua",
			callback = function()
				require("conform").format({ async = false })
			end,
		})
	end,
}
