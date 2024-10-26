-- options that saved my life
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.cmd("set nohlsearch")
--vim.cmd("set number") -- uncomment if you like this
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- add your plugins here
		{
			"sainnhe/gruvbox-material",
			lazy = false,
			priority = 1000,
			config = function()
				-- Optionally configure and load the colorscheme
				-- directly inside the plugin declaration.
				vim.g.gruvbox_material_enable_italic = true
				vim.g.gruvbox_material_background = "soft"
				vim.cmd.colorscheme("gruvbox-material")
			end,
		},

		-- init.lua:
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			-- or                              , branch = '0.1.x',
			dependencies = { "nvim-lua/plenary.nvim" },
		},
		{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		{
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v3.x",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
				-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
			},
		},
		-- lsp stuff / completion stuff
		{
			"williamboman/mason.nvim",
			config = function()
				require("mason").setup()
			end,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			config = function()
				require("mason-lspconfig").setup({
					ensure_installed = { "lua_ls", "gopls" },
				})
			end,
		},

		{
			"neovim/nvim-lspconfig",
			config = function()
				local capabilities = require("cmp_nvim_lsp").default_capabilities()
				local lspconfig = require("lspconfig")
				lspconfig.lua_ls.setup({
					capabilities = capabilites,
				})
				lspconfig.gopls.setup({
					capabilities = capabilities,
				})

				vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
				vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
			end,
		},

		{
			"nvimtools/none-ls.nvim",
			config = function()
				local null_ls = require("null-ls")
				null_ls.setup({
					sources = {
						null_ls.builtins.formatting.stylua,
						null_ls.builtins.formatting.gofumpt,
						null_ls.builtins.formatting.golines,
						null_ls.builtins.formatting.goimports,
					},
				})

				vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, {})
			end,
		},
		{
			"hrsh7th/cmp-nvim-lsp",
		},
		{
			"L3MON4D3/LuaSnip",
			dependencies = {
				"saadparwaiz1/cmp_luasnip",
				"rafamadriz/friendly-snippets",
			},
		},

		{
			"hrsh7th/nvim-cmp",
			config = function()
				local cmp = require("cmp")
				require("luasnip.loaders.from_vscode").lazy_load()
				cmp.setup({
					snippet = {
						-- REQUIRED - you must specify a snippet engine
						expand = function(args)
							--vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
							require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
						end,
					},
					window = {
						--completion = cmp.config.window.bordered(),
						documentation = cmp.config.window.bordered(),
					},
					mapping = cmp.mapping.preset.insert({
						["<C-b>"] = cmp.mapping.scroll_docs(-4),
						["<C-f>"] = cmp.mapping.scroll_docs(4),
						["<C-Space>"] = cmp.mapping.complete(),
						["<C-e>"] = cmp.mapping.abort(),
						["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					}),
					sources = cmp.config.sources({
						{ name = "nvim_lsp" },
						{ name = "luasnip" }, -- For luasnip users.
					}, {
						{ name = "buffer" },
					}),
				})
			end,
		},
		-- end
		{
			"nvim-tree/nvim-web-devicons",
		},

		-- [[
		-------------------------------------------------
		--| A | B | C                             X | Y | Z |
		------------------------------------------------- ]]
		{
			"nvim-lualine/lualine.nvim",
			config = function()
				require("lualine").setup({
					option = {
						theme = "gruvbox-material",
					},
					sections = {
						lualine_a = { "mode" },
						lualine_b = { "branch", "diff", "diagnostics" },
						lualine_c = { "filename" },
						lualine_x = { "encoding" },
						lualine_y = { "progress" },
						lualine_z = { "location" },
					},
				})
			end,
		},
	},

	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = { enabled = false },
})
local config = require("nvim-treesitter.configs")
config.setup({
	ensure_installed = { "lua", "go" },
	highlight = { enable = true },
	indent = { enable = true },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-p>", builtin.find_files, {})
vim.keymap.set("n", "<leader>e", ":Neotree filesystem reveal right<CR>", {})
vim.cmd("au ColorScheme * hi Comment cterm=italic gui=italic")
