" File:         plugin/VIntSearch.vim
" Description:  "One should be able to jump between all kinds of search results".
" Author:       yssl <http://github.com/yssl>
" License:      MIT License

if exists("g:loaded_vintsearch") || &cp
	finish
endif
let g:loaded_vintsearch	= 1
let s:keepcpo           = &cpo
set cpo&vim
 
"""""""""""""""""""""""""""""""""""""""""""""

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
if !exists('g:vintsearch_includepatterns')
	let g:vintsearch_includepatterns =
		\ ['*.c','*.cpp','*.h','*.hpp','*.inl','*.py','*.lua','*.vim','*.js',
		\'*.md','*.txt','*.tex']
endif
if !exists('g:vintsearch_excludepatterns')
	let g:vintsearch_excludepatterns =
		\ []
endif
if !exists('g:vintsearch_qfsplitcmd')
	let g:vintsearch_qfsplitcmd = 'botright'
endif
if !exists('g:vintsearch_enable_default_quickfix_enter')
	let g:vintsearch_enable_default_quickfix_enter = 1
endif
if !exists('g:vintsearch_highlight_group')
	let g:vintsearch_highlight_group = 'Title'
endif
if !exists('g:vintsearch_symbol_defaultcmd')
	let g:vintsearch_symbol_defaultcmd = 'ctags'
endif
if !exists('g:vintsearch_text_defaultcmd')
	let g:vintsearch_text_defaultcmd = 'grep'
endif
if !exists('g:vintsearch_file_defaultcmd')
	let g:vintsearch_file_defaultcmd = 'find'
endif

"" deprecated global variables
if exists('g:vintsearch_search_include_patterns')
	let g:vintsearch_includepatterns = g:vintsearch_search_include_patterns
endif
if exists('g:vintsearch_search_exclude_patterns')
	let g:vintsearch_excludepatterns = g:vintsearch_search_exclude_patterns
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

" Useful grep options
" -w, --word-regexp
" -F, --fixed-strings
" -i, --ignore-case

"""""""""""""""""
" search path / tag commands

command! VIntSearchPrintPath call VIntSearch#PrintSearchPath()
command! VSpath call VIntSearch#PrintSearchPath()

command! VIntSearchBuildSymbolDB call VIntSearch#BuildSymbolDB()
command! VSbuild call VIntSearch#BuildSymbolDB()

"""""""""""""""""
" search commands

" :VStext -i tags
" :VStext tags -i
" :VStext -i "let tags"
" :VStext "let tags" -i

" :VIntSearch text vint -i
" :VIntSearch text "call VInt"

" :VIntSearchCmd text grep vint -i
" :VIntSearchCmd text grep "call VInt"

" :VIntSearchCursor symbol n j
" :VIntSearchCursor text n l

" :VIntSearchCursor symbol ctags n j
" :VIntSearchCursor text grep n l

command! -complete=tag -nargs=1 VSsymbol call VIntSearch#SearchRawDefault('symbol', <f-args>)
command! -complete=tag -nargs=1 VStext call VIntSearch#SearchRawDefault('text', <f-args>)
command! -complete=tag -nargs=1 VSfile call VIntSearch#SearchRawDefault('file', <f-args>)
command! -complete=tag -nargs=1 VScftext call VIntSearch#SearchRawDefault('cftext', <f-args>)

command! -complete=tag -nargs=1 VIntSearch call VIntSearch#SearchRawDefaultParse(<f-args>)
command! -complete=tag -nargs=* VIntSearchCursor call VIntSearch#SearchCursorDefault(<f-args>)

command! -complete=tag -nargs=1 VIntSearchCmd call VIntSearch#SearchRawWithCmdParse(<f-args>)
command! -complete=tag -nargs=* VIntSearchCursorCmd call VIntSearch#SearchCursorWithCmd(<f-args>)

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
" deprecated - will be removed in version 1.4.0

command! -complete=tag -nargs=1 VIntSearchCtags call VIntSearch#SearchRawDep(<f-args>,'ctags')
command! -complete=tag -nargs=1 VSctags call VIntSearch#SearchRawDep(<f-args>,'ctags')

" You can put grep options into <f-args>
" ex)	:Vsgrep -i tags
" 		:Vsgrep tags -i
" 		:Vsgrep -i "let tags"
" 		:Vsgrep "let tags" -i
command! -complete=tag -nargs=1 VIntSearchGrep call VIntSearch#SearchRawDep(<f-args>,'grep')
command! -complete=tag -nargs=1 VSgrep call VIntSearch#SearchRawDep(<f-args>,'grep')

command! -complete=tag -nargs=1 VIntSearchCFGrep call VIntSearch#SearchRawDep(<f-args>,'cfgrep')
command! -complete=tag -nargs=1 VScfgrep call VIntSearch#SearchRawDep(<f-args>,'cfgrep')

command! -complete=tag -nargs=1 VIntSearchFind call VIntSearch#SearchRawDep(<f-args>,'find')
command! -complete=tag -nargs=1 VSfind call VIntSearch#SearchRawDep(<f-args>,'find')

command! -complete=tag -nargs=* VIntSearchCtagsCursor call VIntSearch#SearchCursorDep('ctags',<f-args>)
command! -complete=tag -nargs=* VIntSearchGrepCursor call VIntSearch#SearchCursorDep('grep',<f-args>)
command! -complete=tag -nargs=* VIntSearchCFGrepCursor call VIntSearch#SearchCursorDep('cfgrep',<f-args>)
command! -complete=tag -nargs=* VIntSearchFindCursor call VIntSearch#SearchCursorDep('find',<f-args>)

command! VIntSearchBuildTag call VIntSearch#BuildTag()
command! VSbtag call VIntSearch#BuildTag()

"""""""""""""""""""""""""""""""""""""""""""""
let &cpo= s:keepcpo
unlet s:keepcpo

" vim:set noet sw=4 sts=4 ts=4 tw=78:
