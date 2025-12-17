return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				check_ts = true,
				fast_wrap = {},
				disable_filetype = { "TelescopePrompt", "vim" },
				enable_check_bracket_line = true,
			})
			-- `{` 自动换行
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")

			npairs.add_rules({
				Rule("{", "}", { "rust", "cpp", "c", "go", "php", "javascript", "typescript", "lua" })
					:with_pair(cond.before_regex("%S")) -- 前面有字符才触发
					:with_move(cond.none())
					:with_cr(function()
						return true
					end) -- 回车时自动换行
					:set_end_pair_length(1),
			})
		end,
	},
}
