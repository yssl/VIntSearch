"""""""""""""""""""""""""""""""""""""""""""""
" template code
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_vintsearch") || &cp
	finish
endif
let g:loaded_vintsearch	= 1
let s:keepcpo           = &cpo
set cpo&vim
 
"""""""""""""""""""""""""""""""""""""""""""""
" my code

"" global variables
if !exists('g:vintsearch_workdir_mode')
	" rc : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current workig dir
	" rf : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current file dir
	let g:vintsearch_workdir_mode = 'rc'
endif
if !exists('g:vintsearch_repodirs')
	let g:vintsearch_repodirs = ['.git', '.hg', '.svn']
endif
if !exists('g:vintsearch_codeexts')
	let g:vintsearch_codeexts = ["m","c","cpp","h","hpp","inl","py","lua","vim"]
endif

"" commands 
command! VIntSearchBuildTag call VIntSearch#BuildTag()

command! VIntSearchJumpCtagCursor call VIntSearch#SearchCtags(expand('<cword>'),1,0,'botright')
command! VIntSearchJumpGrepCursor call VIntSearch#SearchGrep(expand('<cword>'),1,0,'botright')

command! VIntSearchListCtagCursor call VIntSearch#SearchCtags(expand('<cword>'),0,1,'botright')
command! VIntSearchListGrepCursor call VIntSearch#SearchGrep(expand('<cword>'),0,1,'botright')

command! VIntSearchJumpCtagSelection call VIntSearch#SearchCtags(s:get_visual_selection(),1,0,'botright')
command! VIntSearchJumpGrepSelection call VIntSearch#SearchGrep(s:get_visual_selection(),1,0,'botright')

command! VIntSearchListCtagSelection call VIntSearch#SearchCtags(s:get_visual_selection(),0,1,'botright')
command! VIntSearchListGrepSelection call VIntSearch#SearchGrep(s:get_visual_selection(),0,1,'botright')

command! -complete=tag -nargs=1 VIntSearchListCtag call VIntSearch#SearchCtags(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 VSctag call VIntSearch#SearchCtags(<f-args>,0,1,'botright')

command! -complete=tag -nargs=1 VIntSearchListGrep call VIntSearch#SearchGrep(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 VSgrep call VIntSearch#SearchGrep(<f-args>,0,1,'botright')

command! VIntSearchMoveBackward call VIntSearch#MoveBackward()
command! VSbwd call VIntSearch#MoveBackward()

command! VIntSearchMoveForward call VIntSearch#MoveForward()
command! VSfwd call VIntSearch#MoveForward()

command! VIntSearchPrintStack call VIntSearch#PrintStack()
command! VSsprint call VIntSearch#PrintStack()

command! VIntSearchPrintPath call VIntSearch#PrintSearchPath()
command! VSpprint call VIntSearch#PrintSearchPath()

command! VIntSearchClearStack call VIntSearch#ClearStack()
command! VSclear call VIntSearch#ClearStack()

command! -nargs=1 VScc call VIntSearch#Cc(<args>)
command! VScnext call VIntSearch#Cnext()
command! VScprev call VIntSearch#Cprev()

" thanks for xolox!
function! s:get_visual_selection()
  " Why is this not a built-in Vim script function?!
  let [lnum1, col1] = getpos("'<")[1:2]
  let [lnum2, col2] = getpos("'>")[1:2]
  let lines = getline(lnum1, lnum2)
  let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][col1 - 1:]
  return join(lines, "\n")
endfunction

"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
