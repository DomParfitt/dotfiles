" Show line numbers
set number

" Set indentation to 2 spaces
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Correct mappings for Ctrl+<Left|Right>
map  <ESC>[1;5D <C-Left>
map! <ESC>[1;5D <C-Left>
map  <ESC>[1;5C <C-Right>
map! <ESC>[1;5C <C-Right>

" Setup plugins
call plug#begin('~/.vim/plugged')

  Plug 'dense-analysis/ale'
  Plug 'jiangmiao/auto-pairs'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  Plug 'Yggdroot/indentLine'
  Plug 'itchyny/lightline.vim'
  Plug 'preservim/nerdtree'
  Plug 'joshdick/onedark.vim'
  Plug 'sheerun/vim-polyglot'

call plug#end()

" 
" ALE Config
"
let g:ale_lint_on_text_changed=1

"
" CoC Config
"

" Map tab and shift-tab to cycle through completions list
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Map ctrl-space to open completions list
inoremap <silent><expr> <c-@> coc#refresh()

" 
" IndentLine Config
"
let g:indentLine_char='▏'

" 
" Lightline Config
"
set laststatus=2
set noshowmode

let g:lightline = {
  \ 'colorscheme': 'onedark',
  \ }

" 
" OneDark Config
"
let g:onedark_termcolors=16
colorscheme onedark

" Change the line number and end buffer symbol colors
highlight EndOfBuffer ctermfg=darkgrey
highlight LineNr ctermfg=darkgrey
highlight Comment ctermfg=darkgrey

