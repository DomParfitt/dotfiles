" Show line numbers
set number

" Set indentation to 2 spaces
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Setup plugins
call plug#begin('~/.vim/plugged')

  Plug 'dense-analysis/ale'
  Plug 'Yggdroot/indentLine'
  Plug 'itchyny/lightline.vim'
  Plug 'preservim/nerdtree'
  Plug 'joshdick/onedark.vim'
  Plug 'sheerun/vim-polyglot'

call plug#end()

" OneDark Config
let g:onedark_termcolors=16
colorscheme onedark

" Change the line number and end buffer symbol colors
highlight EndOfBuffer ctermfg=darkgrey
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkgrey

" Lightline Config
set laststatus=2
set noshowmode

let g:lightline = {
      \ 'colorscheme': 'onedark',
      \ }

" IndentLine Config
let g:indentLine_char='▏'

