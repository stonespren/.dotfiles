-- Build hook (:TSUpdate) lives in config/pack.lua
vim.pack.add({ "https://github.com/nvim-treesitter/nvim-treesitter" })

local parsers = { "c", "lua", "vim", "javascript", "typescript", "tsx" }

-- nvim-treesitter (main branch) needs the tree-sitter CLI to build parsers
require("plugins.mason").ensure_installed({ "tree-sitter-cli" }, function()
	require("nvim-treesitter").install(parsers)
end)

-- Highlighting and indentation for any filetype that has a parser installed
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("local_treesitter", { clear = true }),
	callback = function(ev)
		if pcall(vim.treesitter.start, ev.buf) then
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
