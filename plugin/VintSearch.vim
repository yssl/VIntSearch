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
if !exists('g:vintsearch_codeexts')
	let g:vintsearch_codeexts = ["m","c","cpp","h","hpp","inl","py","lua"]
endif
if !exists('g:vintsearch_workdir_mode')
	" rf : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current file dir
	" rc : nearest ancestor of current file dir that contain repo dir. 
	" 		if no repo dir, current workig dir
	let g:vintsearch_workdir_mode = 'rf'
endif
if !exists('g:vintsearch_width_keyword')
	let g:vintsearch_width_keyword = 25
endif
if !exists('g:vintsearch_width_file')
	let g:vintsearch_width_file = 40 
endif
if !exists('g:vintsearch_width_text')
	let g:vintsearch_width_text = 40
endif

"" commands 
command! VintSearchBuildTag call VintSearch#BuildTag()
command! VintSearchJumpCtagCursor call VintSearch#FindCtags(expand('<cword>'),1,0,'botright')
command! VintSearchJumpGrepCursor call VintSearch#FindGrep(expand('<cword>'),1,0,'botright')

command! VintSearchListCtagCursor call VintSearch#FindCtags(expand('<cword>'),0,1,'botright')
command! VintSearchListGrepCursor call VintSearch#FindGrep(expand('<cword>'),0,1,'botright')

command! -complete=tag -nargs=1 VintSearchListCtag call VintSearch#FindCtags(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 SSctag call VintSearch#FindCtags(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 VintSearchListGrep call VintSearch#FindGrep(<f-args>,0,1,'botright')
command! -complete=tag -nargs=1 SSgrep call VintSearch#FindGrep(<f-args>,0,1,'botright')

command! VintSearchDecreaseStackLV call VintSearch#DecreaseStackLevel()
command! VSdec call VintSearch#DecreaseStackLevel()
command! VintSearchIncreaseStackLV call VintSearch#IncreaseStackLevel()
command! VSinc call VintSearch#IncreaseStackLevel()

command! VintSearchPrintStack call VintSearch#PrintStack()
command! VSprint call VintSearch#PrintStack()
command! VintSearchClearStack call VintSearch#ClearStack()
command! VSclear call VintSearch#ClearStack()

"" autocmd
"augroup VintSearchAutoCmds
	"autocmd!
"augroup END


"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
