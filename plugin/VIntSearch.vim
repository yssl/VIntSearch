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

command! VIntSearchJumpCursorCtags call VIntSearch#Search(expand('<cword>'),'ctags','',0,1,0,1)
command! VIntSearchJumpCursorGrep call VIntSearch#Search(expand('<cword>'),'grep','-wF',0,1,0,1)

command! VIntSearchListCursorCtags call VIntSearch#Search(expand('<cword>'),'ctags','',0,0,1,1)
command! VIntSearchListCursorGrep call VIntSearch#Search(expand('<cword>'),'grep','-wF',0,0,1,1)

command! VIntSearchJumpSelectionCtags call VIntSearch#Search(s:get_visual_selection(),'ctags','',0,1,0,1)
command! VIntSearchJumpSelectionGrep call VIntSearch#Search(s:get_visual_selection(),'grep','-F',1,1,0,1)

command! VIntSearchListSelectionCtags call VIntSearch#Search(s:get_visual_selection(),'ctags','',0,0,1,1)
command! VIntSearchListSelectionGrep call VIntSearch#Search(s:get_visual_selection(),'grep','-F',1,0,1,1)

command! -complete=tag -nargs=1 VIntSearchListTypeCtags call VIntSearch#SearchRaw(<f-args>,'ctags',0,1,1)
command! -complete=tag -nargs=1 VSctags call VIntSearch#SearchRaw(<f-args>,'ctags',0,1,1)

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep -i "let tags"
command! -complete=tag -nargs=1 VIntSearchListTypeGrep call VIntSearch#SearchRaw(<f-args>,'grep',0,1,1)
command! -complete=tag -nargs=1 VSgrep call VIntSearch#SearchRaw(<f-args>,'grep',0,1,1)

"""""""""""""""""
" search commands for a current file

command! VIntSearchListCursorGrepLocal call VIntSearch#Search(expand('<cword>'),'grep','-wF',0,0,1,1,expand('%:p'))
command! VIntSearchListSelectionGrepLocal call VIntSearch#Search(s:get_visual_selection(),'grep','-F',1,0,1,1,expand('%:p'))

command! -complete=tag -nargs=1 VIntSearchListTypeGrepLocal call VIntSearch#SearchRaw(<f-args>,'grep',0,1,1,expand('%:p'))
command! -complete=tag -nargs=1 VSgrepL call VIntSearch#SearchRaw(<f-args>,'grep',0,1,1,expand('%:p'))

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

" thanks for xolox!
function! s:get_visual_selection()
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
