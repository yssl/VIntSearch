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
if !exists('g:vintsearch_searchpathmode')
	" workdir is the root dir of grep search path tree or the dir where tags
	" file is created.
	" rc : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current workig dir
	" rf : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current file dir
	" c : current working directory
	let g:vintsearch_searchpathmode = 'rc'
endif
if !exists('g:vintsearch_tagfilename')
	let g:vintsearch_tagfilename = 'tags'
endif
if !exists('g:vintsearch_repodirs')
	let g:vintsearch_repodirs = ['.git', '.hg', '.svn']
endif
if !exists('g:vintsearch_codeexts')
	let g:vintsearch_codeexts = ["c","cpp","h","hpp","inl","py","lua","vim"]
endif
if !exists('g:vintsearch_qfsplitcmd')
	let g:vintsearch_qfsplitcmd = 'botright'
endif

"" commands 

" useful grep options
" -w, --word-regexp
" -F, --fixed-strings
" -i, --ignore-case
command! VIntSearchBuildTag call VIntSearch#BuildTag()

command! VIntSearchJumpCursorCtags call VIntSearch#Search(expand('<cword>'),'ctags','',0,1,0)
command! VIntSearchJumpCursorGrep call VIntSearch#Search(expand('<cword>'),'grep','-w',0,1,0)

command! VIntSearchListCursorCtags call VIntSearch#Search(expand('<cword>'),'ctags','',0,0,1)
command! VIntSearchListCursorGrep call VIntSearch#Search(expand('<cword>'),'grep','-w',0,0,1)

command! VIntSearchJumpSelectionCtags call VIntSearch#Search(s:get_visual_selection(),'ctags','',0,1,0)
command! VIntSearchJumpSelectionGrep call VIntSearch#Search(s:get_visual_selection(),'grep','-F',1,1,0)

command! VIntSearchListSelectionCtags call VIntSearch#Search(s:get_visual_selection(),'ctags','',0,0,1)
command! VIntSearchListSelectionGrep call VIntSearch#Search(s:get_visual_selection(),'grep','-F',1,0,1)

command! -complete=tag -nargs=1 VIntSearchListTypeCtags call VIntSearch#SearchRaw(<f-args>,'ctags',0,1)
command! -complete=tag -nargs=1 VSctags call VIntSearch#SearchRaw(<f-args>,'ctags',0,1)

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep -i "let tags"
command! -complete=tag -nargs=1 VIntSearchListTypeGrep call VIntSearch#SearchRaw(<f-args>,'grep',0,1)
command! -complete=tag -nargs=1 VSgrep call VIntSearch#SearchRaw(<f-args>,'grep',0,1)

command! VIntSearchMoveBackward call VIntSearch#MoveBackward()
command! VSbwd call VIntSearch#MoveBackward()

command! VIntSearchMoveForward call VIntSearch#MoveForward()
command! VSfwd call VIntSearch#MoveForward()

command! VIntSearchPrintStack call VIntSearch#PrintStack()
command! VSstack call VIntSearch#PrintStack()

command! VIntSearchPrintPath call VIntSearch#PrintSearchPath()
command! VSpath call VIntSearch#PrintSearchPath()

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
