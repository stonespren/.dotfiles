return {
	"marko-cerovac/material.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		vim.cmd([[colorscheme material]])
		vim.g.material_style = "palenight"
	end,
}
