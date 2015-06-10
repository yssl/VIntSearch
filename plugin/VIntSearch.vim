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
	" search path is the root dir of grep search path tree or the dir where tags
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
	let g:vintsearch_repodirs = ['.git', '.hg', '.svn', '.cvs', '.bzr']
endif
if !exists('g:vintsearch_search_include_patterns')
	let g:vintsearch_search_include_patterns =
		\ ['*.c','*.cpp','*.h','*.hpp','*.inl','*.py','*.lua','*.vim','*.js',
		\'*.md','*.txt','*.tex']
endif
if !exists('g:vintsearch_search_exclude_patterns')
	let g:vintsearch_search_exclude_patterns =
		\ []
endif
if !exists('g:vintsearch_qfsplitcmd')
	let g:vintsearch_qfsplitcmd = 'botright'
endif

if !exists('g:vintsearch_enable_default_quickfix_enter')
	let g:vintsearch_enable_default_quickfix_enter = 1
endif

"" autocmd
augroup VIntSearchAutoCmds
	autocmd!
	if g:vintsearch_enable_default_quickfix_enter==1
		autocmd FileType qf nnoremap <silent> <buffer> <CR> :call DefaultQuickFixEnter()<CR>
		autocmd FileType qf nnoremap <silent> <buffer> <2-LeftMouse> :call DefaultQuickFixEnter()<CR>
	endif
augroup END

function! DefaultQuickFixEnter()
	let lnumqf = line('.')
	execute 'silent! :VScc '.lnumqf
endfunction

"" commands 

" useful grep options
" -w, --word-regexp
" -F, --fixed-strings
" -i, --ignore-case

"""""""""""""""""
" search path / tag commands

command! VIntSearchPrintPath call VIntSearch#PrintSearchPath()
command! VSpath call VIntSearch#PrintSearchPath()

command! VIntSearchBuildTag call VIntSearch#BuildTag()
command! VSbtag call VIntSearch#BuildTag()

"""""""""""""""""
" search commands

command! -complete=tag -nargs=1 VIntSearchCtags call VIntSearch#SearchRaw(<f-args>,'ctags')
command! -complete=tag -nargs=1 VSctags call VIntSearch#SearchRaw(<f-args>,'ctags')

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep tags -i
" 		:Vsgrep -i "let tags"
" 		:Vsgrep "let tags" -i
command! -complete=tag -nargs=1 VIntSearchGrep call VIntSearch#SearchRaw(<f-args>,'grep')
command! -complete=tag -nargs=1 VSgrep call VIntSearch#SearchRaw(<f-args>,'grep')

command! -complete=tag -nargs=1 VIntSearchCFGrep call VIntSearch#SearchRaw(<f-args>,'cfgrep')
command! -complete=tag -nargs=1 VScfgrep call VIntSearch#SearchRaw(<f-args>,'cfgrep')

command! -complete=tag -nargs=1 VIntSearchFind call VIntSearch#SearchRaw(<f-args>,'find')
command! -complete=tag -nargs=1 VSfind call VIntSearch#SearchRaw(<f-args>,'find')

"""""""""""""""""
" search commands with cursor

command! -complete=tag -nargs=* VIntSearchCtagsCursor call VIntSearch#SearchCursor('ctags',<f-args>)
command! -complete=tag -nargs=* VIntSearchGrepCursor call VIntSearch#SearchCursor('grep',<f-args>)
command! -complete=tag -nargs=* VIntSearchCFGrepCursor call VIntSearch#SearchCursor('cfgrep',<f-args>)
command! -complete=tag -nargs=* VIntSearchFindCursor call VIntSearch#SearchCursor('find',<f-args>)

"""""""""""""""""
" stack commands

command! VIntSearchMoveBackward call VIntSearch#MoveBackward(1)
command! VSbwd call VIntSearch#MoveBackward(1)

command! VIntSearchMoveForward call VIntSearch#MoveForward(1)
command! VSfwd call VIntSearch#MoveForward(1)

command! VIntSearchClearStack call VIntSearch#ClearStack()
command! VSclear call VIntSearch#ClearStack()

command! VIntSearchPrintStack call VIntSearch#PrintStack()
command! VSstack call VIntSearch#PrintStack()

command! -nargs=1 VScc call VIntSearch#Cc(<args>, 1)
command! VScnext call VIntSearch#Cnext(1)
command! VScprev call VIntSearch#Cprev(1)

"""""""""""""""""
" deprecated search commands

command! VIntSearchJumpCursorCtags call VIntSearch#SearchDep('VIntSearchJumpCursorCtags', expand('<cword>'),'ctags','',0,1,0,1)
command! VIntSearchJumpCursorGrep call VIntSearch#SearchDep('VIntSearchJumpCursorGrep', expand('<cword>'),'grep','-wF',0,1,0,1)

command! VIntSearchListCursorCtags call VIntSearch#SearchDep('VIntSearchListCursorCtags', expand('<cword>'),'ctags','',0,0,1,1)
command! VIntSearchListCursorGrep call VIntSearch#SearchDep('VIntSearchListCursorGrep', expand('<cword>'),'grep','-wF',0,0,1,1)

command! VIntSearchJumpSelectionCtags call VIntSearch#SearchDep('VIntSearchJumpSelectionCtags', s:get_visual_selection_dep(),'ctags','',0,1,0,1)
command! VIntSearchJumpSelectionGrep call VIntSearch#SearchDep('VIntSearchJumpSelectionGrep', s:get_visual_selection_dep(),'grep','-F',1,1,0,1)

command! VIntSearchListSelectionCtags call VIntSearch#SearchDep('VIntSearchListSelectionCtags', s:get_visual_selection_dep(),'ctags','',0,0,1,1)
command! VIntSearchListSelectionGrep call VIntSearch#SearchDep('VIntSearchListSelectionGrep', s:get_visual_selection_dep(),'grep','-F',1,0,1,1)

command! -complete=tag -nargs=1 VIntSearchListTypeCtags call VIntSearch#SearchRawDep('VIntSearchListTypeCtags', <f-args>,'ctags',0,1,1)

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep -i "let tags"
command! -complete=tag -nargs=1 VIntSearchListTypeGrep call VIntSearch#SearchRawDep('VIntSearchListTypeGrep', <f-args>,'grep',0,1,1)

command! VIntSearchListCursorGrepLocal call VIntSearch#SearchDep('VIntSearchListCursorGrepLocal', expand('<cword>'),'grep','-wF',0,0,1,1,expand('%:p'))
command! VIntSearchListSelectionGrepLocal call VIntSearch#SearchDep('VIntSearchListSelectionGrepLocal', s:get_visual_selection_dep(),'grep','-F',1,0,1,1,expand('%:p'))

command! -complete=tag -nargs=1 VIntSearchListTypeGrepLocal call VIntSearch#SearchRawDep('VIntSearchListTypeGrepLocal', <f-args>,'grep',0,1,1,expand('%:p'))

"""""""""""""""""""""""""""""""""""""""""""""
" utility function

" thanks for xolox!
function! s:get_visual_selection_dep()
	" Why is this not a built-in Vim script function?!
	let [lnum1, col1] = getpos("'<")[1:2]
	let [lnum2, col2] = getpos("'>")[1:2]
	let lines = getline(lnum1, lnum2)
	let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
	let lines[0] = lines[0][col1 - 1:]
	let str =  join(lines, "\n")
	let str = substitute(str, '"', '\\"', 'g')
	return str
endfunction

"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
