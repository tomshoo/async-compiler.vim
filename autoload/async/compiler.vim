let s:last_makeargs  = 0
let s:last_makebufnr = 0

function! s:post_makeprg(job_id, exit_code, ...) dict abort
  let l:sequence = printf("\e]777;notify;%s;%s\e\\",
        \ !a:exit_code ? 'Done compiling' : printf('Compilation failed (%d)', a:exit_code),
        \ self._title)

  if exists('$TMUX')
    let l:sequence = "\ePtmux;\e" . l:sequence
  endif

  if has('nvim')
    call nvim_ui_send(l:sequence)
  else
    call writefile([l:sequence], '/dev/tty', 'b')
  endif

  if a:exit_code
    call setqflist([], 'a', #{id: self._qfid, title: printf('(Exit Code: %d) %s', a:exit_code, self._title)})
  endif

  call win_gotoid(self._curwinid)
  doautocmd <nomodeline> QuickFixCmdPost make

  if self._shouldjump
    silent! cc
  endif
endfunction

function! s:append_lines(job_id, buffer, event) dict abort
  let l:RemoveAnsi = { l -> substitute(l, '\%(\e\[[0-?]*[ -/]*[@-~]\|\r\)', '', 'g') }
  let l:lines      = a:buffer->filter('len(v:val)')->map('l:RemoveAnsi(v:val)')

  call setqflist([], 'a', #{id: self._qfid, lines: l:lines})
endfunction

if !has('nvim')
  function! s:append_line_string(opts, line)
    let a:opts._lines .= a:line
  endfunction

  function! s:final_out_cb(job, exit_code, opts)
    let process = job_info(a:job).process

    call a:opts.on_stdout(process, split(a:opts._lines, '\n'), 'exit')
    call a:opts.on_exit(process, a:exit_code, 'exit')

    unlet! s:current_compilation_job
  endfunction

  function! s:translate_options(opts)
    let a:opts._lines = ''

    return #{out_cb:  { chan, message  -> s:append_line_string(a:opts, message) },
          \  err_cb:  { chan, message  -> s:append_line_string(a:opts, message) },
          \  exit_cb: { job, exit_code -> s:final_out_cb(job, exit_code, a:opts) },
          \ }
  endfunction
endif

function! async#compiler#compile(remake, args, jump, mods) abort
  let l:opts = #{
        \  term:             v:true,
        \  pty:              v:true,
        \  stdout_buffered:  v:true,
        \  on_stdout:        function('<SID>append_lines'),
        \  on_exit:          function('<SID>post_makeprg'),
        \ }

  let l:makeprg  = &makeprg
  let l:efm      = &errorformat
  let l:mods     = len(a:mods) ? a:mods : 'hor'
  let l:makeargs = a:args

  let l:opts._curwinid = win_getid(winnr())

  if a:remake && type(l:makeargs) != v:t_string
    let l:makeargs = input('(' . l:makeprg . '): ')
  endif

  if l:makeprg =~# '\$\*'
    let l:makeprg = substitute(l:makeprg, '\$\*', { -> l:makeargs }, 'g')
  else
    let l:makeprg .= ' ' . l:makeargs
  endif

  let l:opts._title = ':' . l:makeprg

  doautocmd <nomodeline> QuickFixCmdPre make

  if exists('s:current_compilation_job')
    call async#compiler#kill(0)
  endif

  if has('nvim')
    exe l:mods . ' split +enew'
  endif

  call setqflist([], ' ', #{title: l:opts._title, efm: l:efm})

  let s:last_makeargs  = l:makeargs

  let l:opts._qfid       = getqflist(#{id: 0}).id
  let l:opts._shouldjump = a:jump

  if has('nvim')
    let s:current_compilation_job = jobstart(l:makeprg, l:opts)
  else
    let s:current_compilation_job = term_start(l:makeprg, s:translate_options(l:opts))->term_getjob()
  endif

  let  s:last_makebufnr = bufnr()
  setl bufhidden=wipe
endfunction

function! async#compiler#kill(force) abort
  if !exists('s:current_compilation_job')
    return
  endif

  if !a:force && confirm('There is an active compilation running. Are you sure?', "&Yes\n&No", 2) == 2
    return
  endif

  if has('nvim')
    call jobstop(s:current_compilation_job)
  else
    call job_stop(s:current_compilation_job)
    call term_wait(s:last_makebufnr)
  endif

  for win in win_findbuf(s:last_makebufnr)
    call win_execute(win, 'wincmd c')
  endfor

  unlet! s:current_compilation_job
  let s:last_makebufnr = 0
endfunction

function! async#compiler#recompile(jump, mods) abort
  call async#compiler#compile(1, s:last_makeargs, a:jump, a:mods)
endfunction

function! async#compiler#reset_args()
  let s:last_makeargs = 0
endfunction
