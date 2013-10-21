"" wrappers
"function! WDManager#PrintWDs()
	"call s:PrintWDs()
"endfunction

"" functions
"function! s:GetPatternAndWDof(bufname)
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
		"vim.command('return [\'%s\',expand(\'%s\')]'%(pattern,wd))
		"break
"if inpatternwd==False:
	"vim.command('return [\'\',expand(g:wdmgr_defaultwd)]')
"EOF
"endfunction

"function! s:PrintWDs()
"python << EOF
"import vim
"def ltrunc(s, width, prefix=''):
    "if width >= len(s): prefix = ''
    "return prefix+s[-width+len(prefix):]

"#widths = [60,10,60]
"widths = [int(vim.eval('g:wdmgr_width_file')), int(vim.eval('g:wdmgr_width_pattern')), int(vim.eval('g:wdmgr_width_wd'))]
"prefix = '..'

"print '%s  %s  %s'%('File'.ljust(widths[0]), 'Pattern'.ljust(widths[1]), 'Working Directory'.ljust(widths[2]))
"for i in range(len(vim.windows)):
	"#bufname = vim.windows[i].buffer.name

	"# jump to each window to expand WD string correctly like '%', '%:p:h', etc
	"vim.command('wincmd w')
	"bufname = vim.current.window.buffer.name

	"vim.command('let l:ret = s:GetPatternAndWDof(\'%s\')'%bufname)
	"vim.command('let l:pattern = ret[0]')
	"vim.command('let l:wd = ret[1]')
	"pattern = vim.eval('l:pattern')
	"wd = vim.eval('l:wd')

	"tokens = [bufname, pattern, wd]
	"for j in range(len(tokens)):
		"if len(tokens[j])<widths[j]:	tokens[j] = tokens[j].ljust(widths[j])
		"else:							tokens[j] = ltrunc(tokens[j], widths[j], prefix)

	"print '%s  %s  %s'%(tokens[0], tokens[1], tokens[2])
"EOF
"endfunction
