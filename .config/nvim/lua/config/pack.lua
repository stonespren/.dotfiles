-- Plugins are managed by the built-in vim.pack (Neovim 0.12+).
-- Lockfile: nvim-pack-lock.json in this directory.

-- Build hooks. Must be registered before the first vim.pack.add() so they also
-- run on initial install.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("local_pack_hooks", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end

		if name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
end, { nargs = "*", desc = "Update plugins (all, or the ones named)" })

vim.api.nvim_create_user_command("PackClean", function()
	local inactive = vim.iter(vim.pack.get())
		:filter(function(p)
			return not p.active
		end)
		:map(function(p)
			return p.spec.name
		end)
		:totable()
	if #inactive == 0 then
		vim.notify("No unused plugins")
		return
	end
	vim.pack.del(inactive)
end, { desc = "Delete plugins no longer added in the config" })

for _, name in ipairs({
	"theme",
	"mason",
	"sleuth",
	"fugitive",
	"instant",
	"surround",
	"vim-tmux-navigator",
	"vim-visual-multi",
	"comment",
	"treesitter",
	"todo-comments",
	"telescope",
	"oil",
	"lsp",
}) do
	require("plugins." .. name)
end
