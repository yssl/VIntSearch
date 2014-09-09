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
if !exists('g:vintsearch_workdirmode')
	" workdir is the root dir of grep search path tree or the dir where tags
	" file is created.
	" rc : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current workig dir
	" rf : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current file dir
	let g:vintsearch_workdirmode = 'rc'
endif
if !exists('g:vintsearch_tagfilename')
	let g:vintsearch_tagfilename = 'tags'
endif
if !exists('g:vintsearch_repodirs')
	let g:vintsearch_repodirs = ['.git', '.hg', '.svn']
endif
if !exists('g:vintsearch_codeexts')
	let g:vintsearch_codeexts = ["m","c","cpp","h","hpp","inl","py","lua","vim"]
endif

"" commands 

" useful grep options
" -w, --word-regexp
" -F, --fixed-strings
" -i, --ignore-case
command! VIntSearchBuildTag call VIntSearch#BuildTag()

command! VIntSearchJumpCursorCtags call VIntSearch#SearchCtags("\"".expand('<cword>')."\"",1,0,'botright')
command! VIntSearchJumpCursorGrep call VIntSearch#SearchGrep("-w \"".expand('<cword>')."\"",1,0,'botright')

command! VIntSearchListCursorCtags call VIntSearch#SearchCtags("\"".expand('<cword>')."\"",0,1,'botright')
command! VIntSearchListCursorGrep call VIntSearch#SearchGrep("-w \"".expand('<cword>')."\"",0,1,'botright')

command! VIntSearchJumpSelectionCtags call VIntSearch#SearchCtags("\"".s:get_visual_selection()."\"",1,0,'botright')
command! VIntSearchJumpSelectionGrep call VIntSearch#SearchGrep("-F \"".s:get_visual_selection()."\"",1,0,'botright')

command! VIntSearchListSelectionCtags call VIntSearch#SearchCtags("\"".s:get_visual_selection()."\"",0,1,'botright')
command! VIntSearchListSelectionGrep call VIntSearch#SearchGrep("-F \"".s:get_visual_selection()."\"",0,1,'botright')

command! -complete=tag -nargs=1 VIntSearchListCtags call VIntSearch#SearchCtags(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 VSctag call VIntSearch#SearchCtags(<f-args>,0,1,'botright')

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep -i "let tags"
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
