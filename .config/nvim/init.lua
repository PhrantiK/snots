local opt = vim.opt
local g = vim.g
vim.cmd("colorscheme habamax")

-- ┏━┓┳━┓┏┓┓o┏━┓┏┓┓┓━┓
-- ┃ ┃┃━┛ ┃ ┃┃ ┃┃┃┃┗━┓
-- ┛━┛┇   ┇ ┇┛━┛┇┗┛━━┛

opt.termguicolors = true
opt.ruler = false
opt.ignorecase = true
opt.splitbelow = true
opt.splitright = true
opt.cul = true
opt.mouse = "a"
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.updatetime = 250 -- update interval for gitsigns
opt.timeoutlen = 400
opt.clipboard = "unnamedplus"
opt.scrolloff = 3
opt.lazyredraw = true
opt.undofile = true
opt.grepprg = "rg --vimgrep"
opt.incsearch = true -- Makes search act like search in modern browsers
opt.scrolloff = 4 -- Lines of context
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop        = 2
opt.smartindent = true
opt.shortmess:append("asI") --disable intro
opt.fillchars = { eob = " " }
opt.foldlevelstart = 3
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldmethod = "marker"

g.loaded_fancy_comment = 1

local disabled_built_ins = {
	"netrw",
	"netrwPlugin",
	"netrwSettings",
	"netrwFileHandlers",
	"gzip",
	"zip",
	"zipPlugin",
	"tar",
	"tarPlugin",
	"getscript",
	"getscriptPlugin",
	"vimball",
	"vimballPlugin",
	"2html_plugin",
	"logipat",
	"rrhelper",
	"spellfile_plugin",
	"matchit",
}

for _, plugin in pairs(disabled_built_ins) do
	vim.g["loaded_" .. plugin] = 1
end

-- ┳━┓┳ ┓┏┓┓┏━┓┏┓┓o┏━┓┏┓┓┓━┓
-- ┣━ ┃ ┃┃┃┃┃   ┃ ┃┃ ┃┃┃┃┗━┓
-- ┇  ┇━┛┇┗┛┗━┛ ┇ ┇┛━┛┇┗┛━━┛

function cmd(name, command, desc)
	vim.api.nvim_create_user_command(name, command, desc)
end

function navi(wincmd, direction)
    local prev_winnr = vim.fn.winnr()
    vim.cmd("wincmd " .. wincmd)

    if prev_winnr == vim.fn.winnr() then
        local direction_map = {
            left = "-L",
            bottom = "-D",
            top = "-U",
            right = "-R"
        }

        local dir_flag = direction_map[direction]

        local pane_at_direction = vim.fn.system('tmux display-message -p "#{pane_at_' .. direction .. '}"'):gsub("\n", "")

        if pane_at_direction == "0" then
            vim.fn.system("tmux select-pane " .. dir_flag)
        end
    end
end

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set(mode, lhs, rhs, options)
end

-- ┳━┓o┏┓┓┳━┓o┏┓┓┏━┓┓━┓
-- ┃━┃┃┃┃┃┃ ┃┃┃┃┃┃ ┳┗━┓
-- ┇━┛┇┇┗┛┇━┛┇┇┗┛┇━┛━━┛

opts = {}

--Remap space as leader key
map("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = " "
g.maplocalleader = " "

-- Telescope bindings
map("n", "<Leader>gt", ":Telescope git_status <CR>", opts)
map("n", "<Leader>cm", ":Telescope git_commits <CR>", opts)
map("n", "<Leader>ff", ":Telescope find_files <CR>", opts)
map("n", "<Leader>fb", ":Telescope current_buffer_fuzzy_find <CR>", opts)
map("n", "<Leader>th", ":Telescope colorscheme <CR>", opts)
map("n", "<Leader>fd", ":Telescope find_files find_command=fd,--hidden <CR>", opts)
map("n", "<Leader>fw", ":Telescope live_grep<CR>", opts)
map("n", "<Leader><space>", ":Telescope buffers<CR>", opts)
map("n", "<Leader>fh", ":Telescope help_tags<CR>", opts)
map("n", "<Leader>fo", ":Telescope oldfiles<CR>", opts)

-- toggle buffer
-- -- buffers
map("n", "<c-n>", ":bn<cr>", opts)
map("n", "<c-p>", ":bp<cr>", opts)
map("n", "<c-x>", ":bd<cr>", opts)
map("n", "<Tab>", ":b#<CR>", opts)

-- Exit terminal with esc
map("t", "<Esc>", "<C-\\><C-n>", opts)

--Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Navigation - Tmux & Vim
map("n", "<C-h>", ":lua navi('h', 'left')<CR>", { silent = true })
map("n", "<C-k>", ":lua navi('k', 'top')<CR>", { silent = true })
map("n", "<C-l>", ":lua navi('l', 'right')<CR>", { silent = true })
map("n", "<C-j>", ":lua navi('j', 'bottom')<CR>", { silent = true })

-- keep visual selection when (de)indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Turn off search matches with double-<Esc>
map("n", "<Esc><Esc>", "<Esc>:nohlsearch<CR>", { silent = true })

-- Don't copy the replaced text after pasting in visual mode
map("v", "p", '"_dP', opts)

-- Map <leader>o & <leader>O to newline without insert mode
map("n", "<leader>o", ':<C-u>call append(line("."), repeat([""], v:count1))<CR>', { silent = true })

map("n", "<leader>O", ':<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>', { silent = true })

-- move blocks
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- focus highlight searches
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)

-- ┳  ┳━┓┏━┓┓ ┳
-- ┃  ┃━┫┏━┛┗┏┛
-- ┇━┛┛ ┇┗━┛ ┇

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim" -- Lazy bootstrap starts here
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- ┳━┓┳  ┳ ┓┏━┓o┏┓┓┓━┓
-- ┃━┛┃  ┃ ┃┃ ┳┃┃┃┃┗━┓
-- ┇  ┇━┛┇━┛┇━┛┇┇┗┛━━┛

require("lazy").setup({
	{ "Fymyte/mbsync.vim", ft = { "mbsync" } },
	{ "lewis6991/gitsigns.nvim", config = true, event = "VeryLazy" },
	{ "windwp/nvim-autopairs", config = true, event = "VeryLazy" },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		config = function()
			require("ibl").setup({
				scope = {
					show_start = false,
				},
				indent = {
					char = "│",
					tab_char = "┊",
					smart_indent_cap = true,
				},
				whitespace = {
					remove_blankline_trail = true,
				},
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		event = "VeryLazy",
		tag = "0.1.4",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local telescope = require("telescope")
			telescope.setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
					file_ignore_patterns = { "^.git/" },
					mappings = {
						i = {
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
							["<esc>"] = "close",
						},
					},
					prompt_prefix = " ",
					selection_caret = " ",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.87,
						height = 0.80,
						preview_cutoff = 120,
					},
					set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				},
				extensions = {
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					},
				},
			}, telescope.load_extension("fzf"))
		end,
	},

	-- treeshitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "lua", "vim", "query", "dockerfile", "yaml" },
				sync_install = false,
				auto_install = true,
				indent = {
					enable = true,
				},
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			vim.o.showmode = false
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = 'auto',
				},
				sections = {
					lualine_c = { { "filename", path = 2 } },
				},
			})
		end,
	},
})

-- ┳━┓┳ ┓┏┓┓┏━┓┏━┓┏━┓┏┏┓┏┏┓┳━┓┏┓┓┳━┓┓━┓
-- ┃━┫┃ ┃ ┃ ┃ ┃┃  ┃ ┃┃┃┃┃┃┃┃━┫┃┃┃┃ ┃┗━┓
-- ┛ ┇┇━┛ ┇ ┛━┛┗━┛┛━┛┛ ┇┛ ┇┛ ┇┇┗┛┇━┛━━┛

-- remove trailing white space
cmd("Nows", "%s/\\s\\+$//e", { desc = "remove trailing whitespace" })

-- remove blank lines
cmd("Nobl", "g/^\\s*$/d", { desc = "remove blank lines" })

-- make current buffer executable
cmd("Chmodx", "!chmod a+x %", { desc = "make current buffer executable" })

-- fix syntax highlighting
cmd("FixSyntax", "syntax sync fromstart", { desc = "reload syntax highlighting" })

-- vertical term
cmd("T", ":vs | :set nu! | :term", { desc = "vertical terminal" })

local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 100 })
	end,
})

autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

autocmd("BufEnter", {
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
	desc = "Disable New Line Comment",
})

-- close some filetypes with <q>
autocmd("FileType", {
	pattern = {
		"qf",
		"help",
		"notify",
		"lspinfo",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"PlenaryTestPopup",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		map("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

autocmd("FileType", {
	pattern = { "man" },
	callback = function()
		vim.o.showcmd = false
		vim.o.laststatus = 0
	end,
})
