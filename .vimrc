"*****************************************************************************
"" Vim-Plug core
"*****************************************************************************
"
let vimplug_exists=expand('~/.vim/autoload/plug.vim')
let curl_exists=expand('curl')

if !filereadable(vimplug_exists)
  if !executable(curl_exists)
    echoerr "Install Curl you doughnut."
    execute "q!"
  endif
  echo "Installing Vim-Plug..."
  echo ""
  silent exec "!"curl_exists" -fLo " . shellescape(vimplug_exists) . " --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
  let g:not_finish_vimplug = "yes"

  autocmd VimEnter * PlugInstall
endif

if !isdirectory($HOME."/.vim/undo-dir")
  call mkdir($HOME."/.vim/undo-dir", "", 0700)
endif

call plug#begin(expand('~/.vim/plugged'))

"*****************************************************************************
"" Plug install packages
"*****************************************************************************
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'itchyny/lightline.vim'
Plug 'Raimondi/delimitMate'
Plug 'Yggdroot/indentLine'
Plug 'statox/FYT.vim'
Plug 'roxma/vim-tmux-clipboard'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'christoomey/vim-tmux-navigator'

call plug#end()

" Required:
filetype plugin indent on


"*****************************************************************************
"" Basic Setup
"*****************************************************************************"

if exists('$SHELL')
    set shell=$SHELL
else
    set shell=/bin/sh
endif

syntax on

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
set ttyfast
set undodir=~/.vim/undo-dir
set undofile
set backspace=indent,eol,start
set lazyredraw
set tabstop=2
set softtabstop=0
set shiftwidth=2
set expandtab
set hidden
set hlsearch
set incsearch
set ignorecase
set smartcase
set ruler
set relativenumber
set number
set wildmenu
set gcr=a:blinkon0
set scrolloff=3
set cul
set laststatus=2
set showtabline=2
set guioptions-=e
set showmatch
set matchtime=3
set modeline
set modelines=10
set title
set titleold="Terminal"
set titlestring=%F
set mouse=a
set mousemodel=popup
set t_Co=256
set shortmess+=I
set cursorline
set splitbelow

" change cursor in insert mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" IndentLine
let g:indentLine_enabled = 1
let g:indentLine_concealcursor = ''
let g:indentLine_char = '┆'
let g:indentLine_faster = 1

if &term =~ '256color'
  set t_ut=
endif

let no_buffers_menu=1

if has('termguicolors')
          set termguicolors
endif

set background=dark

let g:lightline = {'colorscheme': 'catppuccin_frappe'}
colorscheme catppuccin_frappe

let g:FYT_flash_time = 200

"*****************************************************************************
"" Commands
"*****************************************************************************

" remove blank lines
command Nobl :g/^\s*$/d

" remove trailing white space
command Nows :%s/\s\+$//

" make current buffer executable
command Chmodx :!chmod a+x %

"*****************************************************************************
"" Functions
"*****************************************************************************
if !exists('*s:setupWrapping')
  function s:setupWrapping()
    set wrap
    set wm=2
    set textwidth=79
  endfunction
endif

" Disable visualbell
set noerrorbells visualbell t_vb=
if has('autocmd')
  autocmd GUIEnter * set visualbell t_vb=
endif

"" Copy/Paste/Cut
if has('unnamedplus')
  set clipboard=unnamed,unnamedplus
endif

"" Copy over ssh
function! Osc52Yank()
    let buffer=system('base64 -w0', @0)
    let buffer=substitute(buffer, "\n$", "", "")
    let buffer='\e]52;c;'.buffer.'\x07'
    silent exe "!echo -ne ".shellescape(buffer)." > ".shellescape("/dev/tty")
endfunction
command! Osc52CopyYank call Osc52Yank()
augroup Example
    autocmd!
    autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
augroup END

augroup CloseHelpWithQ
    autocmd!
    autocmd FileType help nnoremap <buffer> q :close<CR>
augroup END

"*****************************************************************************
"" Autocmd Rules
"*****************************************************************************
"" The PC is fast enough, do syntax highlight syncing from start unless 200 lines
augroup vimrc-sync-fromstart
  autocmd!
  autocmd BufEnter * :syntax sync maxlines=200
augroup END

"" Remember cursor position
augroup vimrc-remember-cursor-position
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
augroup END

"" txt
augroup vimrc-wrapping
  autocmd!
  autocmd BufRead,BufNewFile *.txt call s:setupWrapping()
augroup END

set autoread

"*****************************************************************************
"" Mappings
"*****************************************************************************

nnoremap <SPACE> <Nop>
let mapleader=' '

" search will center on line
nnoremap n nzzzv
nnoremap N Nzzzv

" terminal emulation
nnoremap <silent> <leader>sh :terminal<CR>

"" Split
noremap <Leader>h :<C-u>split<CR>
noremap <Leader>v :<C-u>vsplit<CR>

"" Git
noremap <Leader>ga :Gwrite<CR>
noremap <Leader>gc :Git commit --verbose<CR>
noremap <Leader>gsh :Git push<CR>
noremap <Leader>gll :Git pull<CR>
noremap <Leader>gs :Git<CR>
noremap <Leader>gb :Git blame<CR>
noremap <Leader>gd :Gvdiffsplit<CR>
noremap <Leader>gr :GRemove<CR>

"" Set working directory
nnoremap <leader>. :lcd %:p:h<CR>

"" Opens an edit command with the path of the currently edited file filled in
noremap <Leader>e :e <C-R>=expand("%:p:h") . "/" <CR>

noremap <Leader>xx :Chmodx<CR>

noremap YY "+y<CR>
noremap <leader>p "+gP<CR>
noremap XX "+x<CR>
" noremap p "_dP<CR>

"" Buffer nav
noremap <c-n> :bn<cr>
noremap <c-p> :bp<cr>
noremap <c-x> :bd<cr>
noremap <Tab> :b#<CR>

"" map <leader>o & <leader>O to newline without insert mode
noremap <silent> <leader>o :<C-u>call append(line("."), repeat([""], v:count1))<CR>
noremap <silent> <leader>O :<C-u>call append(line(".")-1, repeat([""], v:count1))<CR>

"" Clean search (highlight)
nnoremap <silent> <Esc><Esc> :noh<cr>

"" Switching windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
noremap <C-h> <C-w>h

"" Vmap for maintain Visual Mode after shifting > and <
vmap < <gv
vmap > >gv

"" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
