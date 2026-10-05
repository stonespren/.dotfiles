vim.pack.add({
	-- Completion
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/saadparwaiz1/cmp_luasnip",
	"https://github.com/rafamadriz/friendly-snippets",
	-- LSP (mason itself is set up in plugins/mason.lua)
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	-- Formatting
	"https://github.com/stevearc/conform.nvim",
})

-- Completion
require("luasnip.loaders.from_vscode").lazy_load({
	include = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

local cmp = require("cmp")
cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-y>"] = cmp.mapping.confirm({ select = false }),
		["<C-e>"] = cmp.mapping.abort(),
		["<Up>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
		["<Down>"] = cmp.mapping.select_next_item({ behavior = "select" }),
		["<C-p>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_prev_item({ behavior = "insert" })
			else
				cmp.complete()
			end
		end),
		["<C-n>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.select_next_item({ behavior = "insert" })
			else
				cmp.complete()
			end
		end),
	},
	sources = {
		{ name = "luasnip", priority = 10 },
		{ name = "nvim_lsp", priority = 8 },
	},
	preselect = "item",
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
})

-- LSP: servers installed through mason are enabled automatically, using the
-- configs nvim-lspconfig ships in its lsp/ directory.
vim.lsp.config("*", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(),
})

require("mason-lspconfig").setup()

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("local_lsp_attach", { clear = true }),
	callback = function(ev)
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		-- K, [d, ]d and gr* (references, rename, actions...) are Neovim defaults
		map("n", "gd", vim.lsp.buf.definition, "Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
		map("n", "go", vim.lsp.buf.type_definition, "Go to type definition")
		map("n", "gs", vim.lsp.buf.signature_help, "Show function signature")
		map("n", "gl", vim.diagnostic.open_float, "Show diagnostic")
		map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
		map({ "n", "x" }, "<F3>", function()
			vim.lsp.buf.format({ async = true })
		end, "Format")
		map({ "n", "x" }, "<F4>", vim.lsp.buf.code_action, "Execute code action")
	end,
})

-- Formatting
require("conform").setup({
	format_on_save = { timeout_ms = 3000, lsp_fallback = true, quiet = true, stop_after_first = true },
	formatters_by_ft = {
		javascript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
		vue = { "prettierd", "prettier" },
		css = { "prettierd", "prettier" },
		scss = { "prettierd", "prettier" },
		html = { "prettierd", "prettier" },
		json = { "prettierd", "prettier" },
		jsonc = { "prettierd", "prettier" },
		yaml = { "prettierd", "prettier" },
		markdown = { "prettierd", "prettier" },
		graphql = { "prettierd", "prettier" },
		astro = { "prettier" },
		svelte = { "prettier" },
		go = { "gofumpt" },
		lua = { "stylua" },
	},
	formatters = {
		stylua = { inherit = true },
		prettier = { inherit = true },
		prettierd = { inherit = true },
		gofumpt = { inherit = true },
	},
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_fallback = true, quiet = true })
end)
