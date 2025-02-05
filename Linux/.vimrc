syntax enable
colorscheme desert
set tabstop=4
set softtabstop=4
set number
set statusline+=%F
set showcmd
filetype plugin on

" Show a line where the cursor current location is.
set cursorline

setlocal indentexpr=GetGooglePythonIndent(v:lnum)

let s:maxoff = 50 " maximum number of lines to look backwards.

function GetGooglePythonIndent(lnum)

  " Indent inside parens.
  " Align with the open paren unless it is at the end of the line.
  " E.g.
  "   open_paren_not_at_EOL(100,
  "                         (200,
  "                          300),
  "                         400)
  "   open_paren_at_EOL(
  "       100, 200, 300, 400)
  call cursor(a:lnum, 1)
  let [par_line, par_col] = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bW',
        \ "line('.') < " . (a:lnum - s:maxoff) . " ? dummy :"
        \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
        \ . " =~ '\\(Comment\\|String\\)$'")
  if par_line > 0
    call cursor(par_line, 1)
    if par_col != col("$") - 1
      return par_col
    endif
  endif

  " Delegate the rest to the original function.
  return GetPythonIndent(a:lnum)

endfunction

let pyindent_nested_paren="&sw*2"
let pyindent_open_paren="&sw*2"

let g:jedi#goto_stubs_command = "<leader>js"

" Load Pathogen
"call pathogen#infect('bundle/{}')
"call pathogen#helptags()

" Map Ctrl-t to ctrlp tag lookup
let g:ctrlp_extensions = ['tag']

" Smarter working directory for CTRL-P
let g:ctrlp_working_path_mode = 'a'

nmap <silent> <C-t> :CtrlPTag<CR>

" Set the path
set path=.,,**

" Replace all instances of the word under the cursor
nnoremap <Leader>s :%s/\V\<<C-r><C-w>\>/

" Show buffer number in airline tabs
let g:airline#extensions#tabline#buffer_nr_show = 1

" Allow undo after quitting vim
set undofile
set undodir=~/.vim/undodir//

" Automatically remove trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

" Command history length
set history=10000

" Better tab settings
"set sts=2
"set shiftwidth=2
set expandtab
set smartindent

" Disable mouse support, so that the terminal handles mouse highlighting
" instead of vim
set mouse=

" Automatically read and write files as needed
set autowrite

" With these options together, we only use case sensitive search when there is a captial letter in the search term
set ignorecase
set smartcase

" Always syntax format the whole file
syntax sync fromstart

" Don't update the screen while macros are running
set lazyredraw

" completion on the command line
set wildmode=list:longest

" Prevents searched terms from remaining highlighted once search is done
set nohlsearch

" word wrapping
set wrap
set linebreak

" Global ignores
set wildignore+=tmp

" Preferred font
set guifont=Inconsolata:h18.00

" Prevent extra file system events when writing files
set backupcopy=yes

" central backup directores
"set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
"set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp

" Disable F1 help
nmap <F1> :echo<CR>
imap <F1> <C-o>:echo<CR>

" Remap omni-completion to CTRL+Space
nmap <C-space> ea<C-n>
imap <C-space> <C-n>

" Source project local .vimrc files
set exrc

au VimLeave * :!clear
