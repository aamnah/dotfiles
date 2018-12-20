" ~/.vimrc

" Author: Aamnah
" Link: https://aamnah.com
" Version: 0.0.2

" Basics -------------------------------------------------------------

set number			" enable line numbers
set ruler				" show line and column numbers at bottom right of screen
syntax on				" enable syntax highlighting 


" Encoding -------------------------------------------------------------

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8


" Usability ------------------------------------------------------------
set mouse=a " enable Mouse if termial emulator supports it (xterm does)


" Colors ---------------------------------------------------------------
set t_Co=256 " Use 256 colors in Terminals that support them (xterm does)
						 " so colorschemes that use them (e.g. Monokai) show as expected
						 " Otherwise it'll only show 8 or 16 colors
						 " If tmux is installed, add `set -g default-terminal "screen-256color"`
						 " in `~/.tmux.conf` 
syntax on 
syntax enable
colorscheme sublimemonokai
filetype on " syntax-highlighting based on file names



" User Interface -------------------------------------------------------

set number " show line numbers
set ruler  " show current cursor position
set title  " show title in console title bar
set wrap   " wrap lines
set laststatus=2 " tell Vim to always put a status line in, even if there is only one window
set cmdheight=2 " use a status bar that is 2 rows high
set columns=120
"set textwidth=100 " line wrap (no. of columns)


set autoindent " auto-indent new lines
filetype indent on " follow indents specified in filetype (e.g. 4spaces for Python)
set smartindent " match indent to that of parent

set showmatch  " highlight matching braces
set showcmd " show incomplete commands
set showmode " always show which mode i'm currently editing in
set colorcolumn=90 " add a colored column at 90 to avoid going too far right

set shortmess+=I " hide the launch 


" Auto-relaod ----------------------------------------------------------

set autoread " automatically reload files changed outside of Vim, 
						 " this on it's own will do nothing, hence the following line of code 
						 " to make it happen when cursor stops moving

" trigger autoread when cursor stops moving
au CursorHold,CursorHoldI * checktime



" History & Memory -----------------------------------------------------

set hidden " hide buffers instead of closing them
set history=1000 " remember more commands and search history
set undolevels=1000 " use many muchos level of undo
set updatetime=1000 " Speed up the updatetime so gitgutter and friends are quicker

set ttyfast " make keyboard faaaaaaaast
set timeout timeoutlen=1000 ttimeoutlen=50


" Tabs & Spacing -------------------------------------------------------

set tabstop=2 " a tab is 2 spaces
set softtabstop=2 " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=2 " no. of spaces to use for auto-indenting
set expandtab " convert Tabs to Spaces (e.g. Python)
set smarttab " insert tabs on the start of a line according to shiftwidth, not tabstop


" Folding --------------------------------------------------------------

set foldenable " enable code folding
set foldcolumn=2 " add a fold column
set foldmethod=marker " detect trile-{ style fold markers
set foldlevelstart=99 " start out with everything unfolded
set foldopen=block,hor,insert,jump,mark,percent,quickfix,search,tag,undo " which commands trigger auto-unflod


" Search ---------------------------------------------------------------

set hlsearch " highlight search results
set incsearch " incremenatl search, show search matches as you type
set ignorecase " case-insensitive search matching
set smartcase " auto-convert to case-insensitie if uppercase in search query




" REFERENCES
" basic config - http://vimconfig.com/
" https://github.com/nvie/vimrc/blob/master/vimrc
" autoread - https://unix.stackexchange.com/a/383044
