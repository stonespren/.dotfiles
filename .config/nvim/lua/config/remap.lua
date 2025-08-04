-- Reload everything
vim.keymap.set("n", "<leader><leader>r", function()
	vim.cmd("source $HOME/.config/nvim/init.lua")
	vim.cmd("Lazy reload")
end, { desc = "Reload config and lazy plugins" })

-- Yanks into the system clipboard register
local function safe_yank_motion()
	local ok = pcall(vim.cmd, 'normal! "+y')
	if not ok then
		vim.cmd("write !wl-copy")
	end
end

local function safe_yank_line()
	local ok = pcall(vim.cmd, 'normal! "+Y')
	if not ok then
		vim.cmd("write !wl-copy")
	end
end

vim.keymap.set(
	{ "n", "v" },
	"<leader>y",
	safe_yank_motion,
	{ noremap = true, silent = true, desc = "Yank to clipboard (with fallback)" }
)
vim.keymap.set(
	"n",
	"<leader>Y",
	safe_yank_line,
	{ noremap = true, silent = true, desc = "Yank line to clipboard (with fallback)" }
)

-- Pastes without overwriting the default register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Deletes without overwriting the default register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Navigate Diagnostic messages
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnositc message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnositc message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<Esc>", "<Esc>:nohlsearch<CR>", { noremap = true, silent = true })
