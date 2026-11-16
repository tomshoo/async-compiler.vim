if exists('g:loaded_async_compiler_plugin')
  finish
endif

let g:loaded_async_compiler_plugin = 1
let s:focused = 1

function s:notify_user()
  if s:focused
    return
  endif

  let quickfix = getqflist(#{title: 1})
  let sequence = printf("\e]777;notify;%s;%s\e\\", 'Compilation completed', quickfix.title)

  if exists('$TMUX')
    let sequence = "\ePtmux;\e" . sequence
  endif

  if has('nvim')
    call nvim_ui_send(sequence)
  else
    call writefile([sequence], '/dev/tty', 'b')
  endif
endfunction

command -nargs=* -bang Compile         call async#compiler#compile(0, <q-args>, <bang>1, <q-mods>)
command -nargs=0 -bang ReCompile       call async#compiler#recompile(<bang>1, <q-mods>)
command -nargs=0 -bang KillCompilation call async#compiler#kill(<bang>0)

nnoremap <Plug>(async-compiler-recompile)        <cmd>ReCompile<cr>
nnoremap <Plug>(async-compiler-kill-compilation) <cmd>KillCompilation<cr>

augroup plugins#async-compiler
  autocmd!

  " See (https://github.com/vim/vim/issues/18614)
  " autocmd QuickFixCmdPost,QuickFixCmdPre * " Needs silent in case user has not registered a relevant autocmd

  autocmd User CompilationCompleted call <SID>notify_user()

  autocmd FocusLost   * let s:focused = 0
  autocmd FocusGained * let s:focused = 0
augroup END
