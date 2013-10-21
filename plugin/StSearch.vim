"""""""""""""""""""""""""""""""""""""""""""""
" template code
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_stsearch") || &cp
	"finish
endif
let g:loaded_stsearch	= 1
let s:keepcpo           = &cpo
set cpo&vim
 
"""""""""""""""""""""""""""""""""""""""""""""
" my code

"" global variables
if !exists('g:stsearch_codeexts')
	let g:stsearch_codeexts = ["m","c","cpp","h","hpp","inl","py","lua"]
endif

"" commands 
command! StSearchBuildTag call StSearch#BuildTag()
"command! -complete=tag -nargs=1 StSearchCtag call s:FindCtags(<f-args>)
"command! -complete=tag -nargs=1 StSearchGrep call s:FindGrep(<f-args>)

command! StSearchJumpCtagCursor call StSearch#FindCtags(expand('<cword>'),1,0,'botright')
command! StSearchJumpGrepCursor call StSearch#FindGrep(expand('<cword>'),1,0,'botright')

command! StSearchListCtagCursor call StSearch#FindCtags(expand('<cword>'),0,1,'botright')
command! StSearchListGrepCursor call StSearch#FindGrep(expand('<cword>'),0,1,'botright')

command! StSearchPrintStack call StSearch#PrintStack()
command! StSearchClearStack call StSearch#ClearStack()

"" autocmd
"augroup WDManagerAutoCmds
	"autocmd!
	"autocmd BufEnter * call s:ChangeToWDof(expand('<afile>')) 
"augroup END


"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
