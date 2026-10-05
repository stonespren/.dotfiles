vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.5" },
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files)
vim.keymap.set("n", "<leader>pg", builtin.git_files)
vim.keymap.set("n", "<leader>ps", builtin.live_grep)
