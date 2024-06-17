return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	keys = { { "<leader>pv", "<CMD>Oil<CR>" } },
	opts = {
		view_options = {
			show_hidden = true
		},
	},
}
