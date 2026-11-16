if exists('g:loaded_async_compiler_plugin')
  finish
endif

let g:loaded_async_compiler_plugin = 1

command -nargs=* -bang Compile         call async#compiler#compile(0, <q-args>, <bang>1, <q-mods>)
command -nargs=0 -bang ReCompile       call async#compiler#recompile(<bang>1, <q-mods>)
command -nargs=0 -bang KillCompilation call async#compiler#kill(<bang>0)

nnoremap <Plug>(async-compiler-recompile)        <cmd>ReCompile<cr>
nnoremap <Plug>(async-compiler-kill-compilation) <cmd>KillCompilation<cr>

" See (https://github.com/vim/vim/issues/18614)
autocmd QuickFixCmdPost,QuickFixCmdPre * " Needs silent in case user has not registered a relevant autocmd
