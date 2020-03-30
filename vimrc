" Show line numbers
set number

" Setup plugins
call plug#begin('~/.vim/plugged')

" Install OneDark color scheme
Plug 'joshdick/onedark.vim'

" Install vim polyglot
Plug 'sheerun/vim-polyglot'

call plug#end()

" Setup OneDark color scheme
let g:onedark_termcolors=16
colorscheme onedark

" Change the line number and end buffer symbol colors
highlight EndOfBuffer ctermfg=darkgrey
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkgrey

