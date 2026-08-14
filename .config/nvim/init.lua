local opt = vim.opt
local g = vim.g

-- ┏━┓┳━┓┏┓┓o┏━┓┏┓┓┓━┓
-- ┃ ┃┃━┛ ┃ ┃┃ ┃┃┃┃┗━┓
-- ┛━┛┇   ┇ ┇┛━┛┇┗┛━━┛

opt.ignorecase = true
opt.splitbelow = true
opt.splitright = true
opt.cul = true
opt.mouse = "a"
opt.signcolumn = "yes"
opt.cmdheight = 1
opt.undofile = true
opt.grepprg = "rg --vimgrep"
opt.incsearch = true -- Makes search act like search in modern browsers
opt.scrolloff = 4 -- Lines of context
opt.showcmd = false
opt.number = true
opt.numberwidth = 2
opt.relativenumber = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true
opt.shortmess:append("asI") --disable intro
opt.fillchars = { eob = " " }
opt.winborder = "rounded"
opt.clipboard = "unnamedplus"
opt.statusline =
  [[ %{hostname()}%< • %{fnamemodify(getcwd(),':t')}/%<%f%m %r%h%w%=%{&ft!=''?&ft:'none'} • %l:%c • %P ]]

vim.cmd("colorscheme habamax")

vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE", fg = "#a0a0a0" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "NONE", fg = "#606060" })

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
      right = "-R",
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

-- ┳━┓┳  ┳ ┓┏━┓o┏┓┓┓━┓
-- ┃━┛┃  ┃ ┃┃ ┳┃┃┃┃┗━┓
-- ┇  ┇━┛┇━┛┇━┛┇┇┗┛━━┛

vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    load = function()
      require("nvim-treesitter.configs").setup({
        auto_install = true,
        highlight = {
          enable = true,
        },
      })
    end,
  },
})

require("gitsigns").setup({
  signs = {
    add = { text = "▕" },
    change = { text = "▕" },
    delete = { text = "▕" },
    topdelete = { text = "▕" },
    changedelete = { text = "▕" },
    untracked = { text = "▕" },
  },
})

-- ┳━┓o┏┓┓┳━┓o┏┓┓┏━┓┓━┓
-- ┃━┃┃┃┃┃┃ ┃┃┃┃┃┃ ┳┗━┓
-- ┇━┛┇┇┗┛┇━┛┇┇┗┛┇━┛━━┛

local fzf = require("fzf-lua")
local opts = {}

--Remap space as leader key
map("", "<Space>", "<Nop>", { noremap = true, silent = true })
g.mapleader = " "
g.maplocalleader = " "

map("n", "<leader>gt", fzf.git_status, opts)
map("n", "<leader>cm", fzf.git_commits, opts)
map("n", "<leader>ff", fzf.files, opts)
map("n", "<leader>fo", fzf.oldfiles, opts)
map("n", "<leader>fb", fzf.blines, opts)
map("n", "<leader>th", fzf.colorschemes, opts)
map("n", "<leader><space>", fzf.buffers, opts)
map("n", "<leader>fh", fzf.help_tags, opts)
map("n", "<leader>cd", fzf.zoxide, opts)

map("n", "<leader>fd", function()
  fzf.files({ cmd = "fd --hidden --follow --exclude .git" })
end, opts)

map("n", "<leader>fi", function()
  fzf.files({ cmd = "fd --no-ignore-vcs" })
end, opts)

-- full‑file search prompt
map("n", "<leader>fw", function()
  fzf.live_grep_native({ cwd = fzf.utils.root() })
end, opts)

map("n", "\\", fzf.live_grep_native, opts)

-- buffers
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

-- Turn off search matches with <Esc>
map("n", "<Esc>", "<Esc>:nohlsearch<CR>", { silent = true })

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
    vim.hl.on_yank({ higroup = "Visual", timeout = 100 })
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
