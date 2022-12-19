local opt = vim.opt
local g = vim.g

local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end

-- ┳━┓┳  ┳ ┓┏━┓o┏┓┓┓━┓
-- ┃━┛┃  ┃ ┃┃ ┳┃┃┃┃┗━┓
-- ┇  ┇━┛┇━┛┇━┛┇┇┗┛━━┛

require("packer").startup(function(use)
  use { "wbthomason/packer.nvim" }
  use { "nvim-telescope/telescope.nvim", requires = { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
    { "jvgrootveld/telescope-zoxide", } }

  -- lsp crap
  use { "nvim-treesitter/nvim-treesitter" }
  use { "Fymyte/mbsync.vim", ft = { "mbsync" } }
  use { "norcalli/nvim-colorizer.lua" }
  use { "catppuccin/nvim", as = "catppuccin" }
  use { "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons" } }
  use { "lewis6991/gitsigns.nvim", requires = { "nvim-lua/plenary.nvim" } }
  use { "lukas-reineke/indent-blankline.nvim" }
  use { "terrortylor/nvim-comment" }
  use { "folke/todo-comments.nvim" }
  use { "windwp/nvim-autopairs" }
  use { "lewis6991/impatient.nvim" }
end)

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
  "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g["loaded_" .. plugin] = 1
end

-- ┳━┓┳ ┓┏┓┓┏━┓┏┓┓o┏━┓┏┓┓┓━┓
-- ┣━ ┃ ┃┃┃┃┃   ┃ ┃┃ ┃┃┃┃┗━┓
-- ┇  ┇━┛┇┗┛┗━┛ ┇ ┇┛━┛┇┗┛━━┛

function trim_trailing_whitespaces()
  if not vim.o.binary and vim.o.filetype ~= 'diff' then
    local current_view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(current_view)
  end
end

function navi(wincmd, direction)
  local previous_winnr = vim.fn.winnr()
  vim.cmd("wincmd " .. wincmd)

  if previous_winnr == vim.fn.winnr() then
    vim.fn.system('tmux-yabai.sh ' .. direction)
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

opt = {}

--Remap space as leader key
map('', '<Space>', '<Nop>', { noremap = true, silent = true })
g.mapleader = ' '
g.maplocalleader = ' '

-- Telescope bindings
map("n", "<Leader>gt", ":Telescope git_status <CR>", opt)
map("n", "<Leader>cm", ":Telescope git_commits <CR>", opt)
map("n", "<Leader>ff", ":Telescope find_files <CR>", opt)
map("n", "<Leader>fb", ":Telescope current_buffer_fuzzy_find <CR>", opt)
map("n", "<Leader>th", ":Telescope colorscheme <CR>", opt)
map("n", "<Leader>fd", ":Telescope find_files find_command=fd,--hidden <CR>", opt)
map("n", "<Leader>cd", ":Telescope zoxide list <CR>", opt)
map("n", "<Leader>fw", ":Telescope live_grep<CR>", opt)
map("n", "<Leader><space>", ":Telescope buffers<CR>", opt)
map("n", "<Leader>fh", ":Telescope help_tags<CR>", opt)
map("n", "<Leader>fo", ":Telescope oldfiles<CR>", opt)
map("n", "<Leader>tt", ":TodoTelescope<CR>", opt)

-- toggle buffer
map("n", "<Tab>", ":b#<CR>", opt)

-- Exit terminal with esc
map("t", "<Esc>", "<C-\\><C-n>", opt)

--Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- Navigation - Tmux & Vim & Yabai
map("n", "<C-h>", ":lua navi('h', 'west')<CR>", { silent = true })
map("n", "<C-k>", ":lua navi('k', 'north')<CR>", { silent = true })
map("n", "<C-l>", ":lua navi('l', 'east')<CR>", { silent = true })
map("n", "<C-j>", ":lua navi('j', 'south')<CR>", { silent = true })

-- keep visual selection when (de)indenting
map("v", "<", "<gv", opt)
map("v", ">", ">gv", opt)

-- Turn off search matches with double-<Esc>
map('n', '<Esc><Esc>', '<Esc>:nohlsearch<CR>', { silent = true })

-- Don't copy the replaced text after pasting in visual mode
map("v", "p", '"_dP', opt)

-- COPY EVERYTHING --
map("n", "<C-a>", " : %y+<CR>", opt)

-- Map <leader>o & <leader>O to newline without insert mode
map('n', '<leader>o',
  ':<C-u>call append(line("."), repeat([""], v:count1))<CR>',
  { silent = true })

map('n', '<leader>O',
  ':<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>',
  { silent = true })

-- ┳━┓┳  ┳ ┓┏━┓o┏┓┓  ┓━┓┳━┓┏┓┓┳ ┓┳━┓
-- ┃━┛┃  ┃ ┃┃ ┳┃┃┃┃  ┗━┓┣━  ┃ ┃ ┃┃━┛
-- ┇  ┇━┛┇━┛┇━┛┇┇┗┛  ━━┛┻━┛ ┇ ┇━┛┇

local catppuccin = require("catppuccin")
catppuccin.setup({
  flavour = "frappe",
  integrations = {
    gitgutter = true,
    gitsigns = true,
    telescope = true,
    indent_blankline = {
      enabled = true,
      colored_indent_levels = false,
    },
  }
})

vim.cmd [[colorscheme catppuccin]]

-- blankline
require("indent_blankline").setup {
  char = "│",
  buftype_exclude = { "terminal", "nofile", },
  filetype_exclude = { "help", "packer", "markdown", "mail", },
  show_trailing_blankline_indent = false,
}

require('impatient')

require('lualine').setup {
  options = {
    theme = 'catppuccin'
  }
}

-- pretty pretty pretty good
require('colorizer').setup()

-- gcc yo
require('nvim_comment').setup()
require("todo-comments").setup()

require('gitsigns').setup {
  signs = {
    add          = { hl = 'GitSignsAdd', text = '│', numhl = 'GitSignsAddNr', linehl = 'GitSignsAddLn' },
    change       = { hl = 'GitSignsChange', text = '│', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
    delete       = { hl = 'GitSignsDelete', text = '_', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    topdelete    = { hl = 'GitSignsDelete', text = '‾', numhl = 'GitSignsDeleteNr', linehl = 'GitSignsDeleteLn' },
    changedelete = { hl = 'GitSignsChange', text = '~', numhl = 'GitSignsChangeNr', linehl = 'GitSignsChangeLn' },
  },
  status_formatter = nil, -- Use default
  watch_gitdir = {
    interval = 100,
  },
}

-- telescope
require('telescope').setup {
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    file_ignore_patterns = { "^.git/" },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<esc>"] = "close"
      }
    },
    prompt_prefix = " ",
    selection_caret = " ",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8
      },
      vertical = {
        mirror = false
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120
    },
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case" -- or "ignore_case" or "respect_case"
    },
  },
}

-- why does zoxide work without this require?
require('telescope').load_extension('fzf')

-- treeshitter
require('nvim-treesitter.configs').setup {
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = 'gnn',
      node_incremental = 'grn',
      scope_incremental = 'grc',
      node_decremental = 'grm',
    },
  },
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- ┳━┓┳ ┓┏┓┓┏━┓┏━┓┏━┓┏┏┓┏┏┓┳━┓┏┓┓┳━┓┓━┓
-- ┃━┫┃ ┃ ┃ ┃ ┃┃  ┃ ┃┃┃┃┃┃┃┃━┫┃┃┃┃ ┃┗━┓
-- ┛ ┇┇━┛ ┇ ┛━┛┗━┛┛━┛┛ ┇┛ ┇┛ ┇┇┗┛┇━┛━━┛

local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 100 }
  end,
})

local packer_group = vim.api.nvim_create_augroup('Packer', {
  clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})
