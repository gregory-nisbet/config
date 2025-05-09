let g:vimrc_feat_plug                   = 1
let g:vimrc_feat_core_minimal           = 1
let g:vimrc_feat_core                   = 1
let g:vimrc_feat_controversial          = 1

if g:vimrc_feat_core_minimal
  " Make the undo feature simpler.
  " Previous version and current version, nothing else.
  set undolevels=1000

  setglobal tags=./tags;
  setglobal tags^=$HOME/tags

  let g:vim_indent={}

  set t_Co=0
  set nocompatible
  set nomodeline
  set nonumber
  set numberwidth=7
  set laststatus=2
  set nofixendofline
  set virtualedit=all
  set nojoinspaces
  set scrolloff=7
  " syntax on
  " filetype plugin indent on
  " colorscheme koehler
  set noautoindent
  set nocindent
  set nosmartindent
  set shiftwidth=8
  set tabstop=8
  set expandtab
  set nowrap

  set ruler
  " set noautochdir
  " set autochdir
  " autocmd BufEnter * silent! :lcd%:p:h
  set nocursorline
  set nocursorcolumn
  set nostartofline
  set wrap
  set laststatus=2

  syntax on
  set list

  set nofixendofline
  set hidden
endif

if g:vimrc_feat_plug
  call plug#begin()

  " Plug '~/vim/acl2'

  " Plug 'fatih/vim-go'

  Plug 'whonore/Coqtail'

  call plug#end()

  nnoremap \\ :CoqToLine<cr>
endif

if g:vimrc_feat_core
  let g:netrw_banner=0

  " let &grepprg = "grep -n -i -r -I --exclude-dir=\"{.git,.hg}\""
  let &grepprg = "varda"

  " e0 b9 8f -- e2 96 b8 -- e2 81 9b
  execute("set listchars=eol:\xe0\xb9\x8f,tab:\xe2\x96\xb8\\ ,trail:\xe2\x81\x9b,extends:>,precedes:<,space:\\ ")

  " takes: nothing
  " returns: command grepping the word under the cursor
  function! GrepWordPattern()
    let l:word = fnameescape(expand('<cword>'))
    let l:pattern = printf('grep %s', l:word)
    return l:pattern
  endfunction

  " takes: nothing
  " returns: nothing
  function! RunEnter(filetype)
    let l:isqf = (a:filetype ==# 'qf')
    if l:isqf
      execute 'a'
    else
      execute ':w!'
    endif
  endfunction

  " not silent and not nowait!
  nnoremap <expr> \g printf(':%s', GrepWordPattern())
  nnoremap <expr> \G ':grep '
  nnoremap <silent> <nowait> \h :edit %:h<cr>

  nnoremap <silent> <nowait> ) :cnext<cr>
  nnoremap <silent> <nowait> ( :cprev<cr>

  nnoremap <silent> <nowait> <bs>  X
  " nnoremap <silent> <nowait>    X  x

  nnoremap <silent> <nowait> <c-space> :qa!<cr>
  nnoremap <silent> <nowait> <nul> :qa!<cr>

  nnoremap <silent> <nowait> z, ,

  inoremap <silent> <nowait> <c-l> <esc>

  inoremap <silent> <nowait> <S-tab> <c-d>

  nnoremap <nowait> : ;
  nnoremap <nowait> ; :
  " I don't love this, but it works
  nnoremap <expr> <cr> (&filetype ==? 'qf' ? "<cr>" : ":w!<cr>")

  nnoremap <silent> <nowait> \l :set list!<cr>

  nnoremap <silent> <nowait> g= g+

  " Case insensitive search.
  nnoremap <nowait> <space><space> /\c
  " search
  nnoremap <silent> <nowait> <expr> <space>gr (printf(":%s<cr>", GrepWordPattern()))


  nnoremap \c :copen<cr>
  nnoremap tc :copen<cr>
  nnoremap \x :cclose<cr>
  nnoremap tx :cclose<cr>

  nnoremap <c-g> 1<c-g>

  nnoremap - <c-d>
  nnoremap = <c-u>
  nnoremap <c-v> v
  nnoremap v <c-v>

  nnoremap m <c-u>
  nnoremap <space>m m
  nnoremap f <c-d>
  nnoremap <space>f f
  nnoremap t <nop>
  nnoremap <space>t t

  nnoremap <c-]> g<c-]>
endif

autocmd FileType vim setlocal tabstop=2 shiftwidth=2 softtabstop=2
