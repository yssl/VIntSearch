"""""""""""""""""""""""""""""""""""""""""""""
" template code
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_stackedsearch") || &cp
  finish
endif
let g:loaded_stackedsearch	= 1
let s:keepcpo           = &cpo
set cpo&vim
 
""""""""""""""""""""""""""""""""""""""""""""""
"" my code

"" global variables
"if !exists('g:wdmgr_defaultwd')
	"let g:wdmgr_defaultwd = getcwd()
"endif
"if !exists('g:wdmgr_patternwd')
	"let g:wdmgr_patternwd = {}
"endif
"if !exists('g:wdmgr_width_file')
	"let g:wdmgr_width_file = 60
"endif
"if !exists('g:wdmgr_width_pattern')
	"let g:wdmgr_width_pattern = 10
"endif
"if !exists('g:wdmgr_width_wd')
	"let g:wdmgr_width_wd = 60
"endif

"" commands
"command! -complete=dir -nargs=1 WDMgrChdir call s:Chdir(<f-args>)
"command! -complete=dir -nargs=1 Wcd call s:Chdir(<f-args>)
"command! WDMgrSetDefaultWD call s:SetCWDasDefaultWD()
"command! WDMgrPrintWDs call WDManager#PrintWDs()

"" autocmd
"augroup WDManagerAutoCmds
	"autocmd!
	"autocmd BufEnter * call s:ChangeToWDof(expand('<afile>')) 
"augroup END

"" functions
"function! s:Chdir(dir)
	"execute 'cd' a:dir 
	"call s:SetCWDasDefaultWD()
"endfunction

"function! s:SetCWDasDefaultWD()
	"let g:wdmgr_defaultwd = getcwd()
	"echo 'WDManager: CWD and Default WD: '.g:wdmgr_defaultwd
"endfunction

"function! s:ChangeToWDof(bufname)
	"if len(a:bufname)==0
		"return
	"endif
	"let l:wd = s:GetWDof(a:bufname)
	"execute 'cd' l:wd
	""echo 'WDManager: CWD is '.l:wd
"endfunction

"function! s:GetWDof(bufname)
"python << EOF
"import vim
"import fnmatch
"bufname = vim.eval('a:bufname')
"patternwd = vim.eval('g:wdmgr_patternwd')
"inpatternwd = False
"for pattern, wd in patternwd.items():
	"#print fnmatch.fnmatch(bufname, pattern), pattern, bufname
	"if fnmatch.fnmatch(bufname, pattern):
		"inpatternwd = True
		"vim.command('return expand(\'%s\')'%wd)
		"break
"if inpatternwd==False:
	"vim.command('return expand(g:wdmgr_defaultwd)')
"EOF
"endfunction


"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
