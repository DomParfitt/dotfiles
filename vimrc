" Show line numbers
set number

" Set indentation to 2 spaces
set expandtab
set shiftwidth=2

" Setup plugins
call plug#begin('~/.vim/plugged')

Plug 'jiangmiao/auto-pairs'
Plug 'preservim/nerdtree'
Plug 'joshdick/onedark.vim'
Plug 'sheerun/vim-polyglot'

call plug#end()

" Setup OneDark color scheme
let g:onedark_termcolors=16
colorscheme onedark

" Change the line number and end buffer symbol colors
highlight EndOfBuffer ctermfg=darkgrey
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkgrey

