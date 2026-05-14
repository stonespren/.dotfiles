return {
	"JoosepAlviste/nvim-ts-context-commentstring",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("ts_context_commentstring").setup({ enable_autocmd = false })

		-- Hook into native Neovim 0.10+ gc/gcc commenting
		local get_option = vim.filetype.get_option
		vim.filetype.get_option = function(filetype, option)
			return option == "commentstring"
				and require("ts_context_commentstring.internal").calculate_commentstring()
				or get_option(filetype, option)
		end
	end,
}
