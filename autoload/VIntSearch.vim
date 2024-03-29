" File:         autoload/VIntSearch.vim
" Description:  "One should be able to jump between all kinds of search results".
" Author:       yssl <http://github.com/yssl>
" License:      MIT License

" Support for Python3 and Python2
" from https://github.com/Valloric/YouCompleteMe
function! s:UsingPython3()
	if has('python3')
		return 1
	endif
	return 0
endfunction
let s:using_python3 = s:UsingPython3()
let s:pythonX_until_EOF = s:using_python3 ? "python3 << EOF" : "python << EOF"

" wrappers
function! VIntSearch#Cc(linenum, use_quickfix)
	call s:Cc(a:linenum, a:use_quickfix)
endfunction

function! VIntSearch#Cnext(wrap_around, use_quickfix)
	call s:Cnext(a:wrap_around, a:use_quickfix)
endfunction

function! VIntSearch#Cprev(wrap_around, use_quickfix)
	call s:Cprev(a:wrap_around, a:use_quickfix)
endfunction

function! VIntSearch#BuildSymbolDB()
	call s:BuildTag()
endfunction

function! VIntSearch#PrintStack()
	call s:PrintStack()
endfunction

function! VIntSearch#PrintSearchPath()
	call s:PrintSearchPath()
endfunction

function! VIntSearch#ClearStack()
	call s:ClearStack()
endfunction

" script variable
if !exists('s:searchstack')
	let s:searchstack = []
endif
if !exists('s:stacklevel')
	let s:stacklevel = 0
endif
if !exists('s:jump_after_search')
	let s:jump_after_search = 0
endif

"""""""""""""""""""""""""""""""""""""""""
" main search function
function! s:Search(searchtype, searchcmd, keyword, options, jump_to_firstitem, open_result_win)
	if a:searchcmd==#'default'
		if a:searchtype==#'symbol'
			let searchcmd = g:vintsearch_symbol_defaultcmd
		elseif a:searchtype==#'text' || a:searchtype==#'cftext'
			let searchcmd = g:vintsearch_text_defaultcmd
		elseif a:searchtype==#'file'
			let searchcmd = g:vintsearch_file_defaultcmd
		endif
	else
		let searchcmd = a:searchcmd
	endif

	let search_keyword = a:keyword
	if a:searchtype==#'file' && searchcmd==#'find'
		let search_keyword = '*'.search_keyword.'*'
	endif

	let real_keyword = substitute(search_keyword, '%', '\\%', 'g')
	let real_keyword = substitute(real_keyword, '#', '\\#', 'g')

	if searchcmd==#'ctags'
		let qflist = s:GetCtagsQFList(real_keyword)
	elseif searchcmd==#'grep'
		if a:searchtype==#'text'
			let qflist = s:GetGrepQFList(real_keyword, a:options, 1)
		elseif a:searchtype==#'cftext'
			let qflist = s:GetGrepQFList(real_keyword, a:options, 1, expand('%:p'))
		endif
	elseif searchcmd==#'find'
		let qflist = s:GetFindQFList(real_keyword, a:options)
	else
		echom 'VIntSearch: '.searchcmd.': Unsupported command.'
		return
	endif

	if qflist!=[0]
		call s:DoFinishingWork(qflist, search_keyword, a:searchtype, searchcmd, a:options, a:jump_to_firstitem, a:open_result_win, 1)
	endif
endfunction

"""""""""""""""""""""""""""""""""""""""""
" two major of search functions using s:Search()
" SearchCursor(): search keyword is the word under the cursor (provided by expand('<cword>'))
" SearchRaw(): search keyword is given by user (via keyword_and_options)
"
" searchtype: 'symbol' or 'text' or 'file' or 'cftext'
" searchcmd: for example, 'grep' for 'text' type

" keyword is give by expand('<cword>')
" options are determined by vimmode
" jump_to_firstitem & open_result_win are determined by action
"
" vimmode: 'n'(normal mode), 'v'(visual selection mode)
" action: 'j'(jump), 'l'(list)
fun! VIntSearch#SearchCursor(searchtype, searchcmd, vimmode, action)
	if a:vimmode==#'n'
		let keyword = expand('<cword>')
		let options = '-wF'
	elseif a:vimmode==#'v'
		let keyword = '"'.s:get_visual_selection().'"'
		let options = '-F'
	else
		echom 'VIntSearch: '.a:vimmode.': Unsupported vim mode.'
		return
	endif

	if a:action==#'j'
		let jump_to_firstitem = 1
		let open_result_win = 0
	elseif a:action==#'l'
		let jump_to_firstitem = 0
		let open_result_win = 1
	else
		echom 'VIntSearch: '.a:action.': Unsupported action.'
		return
	endif

	call s:Search(a:searchtype, a:searchcmd, keyword, options, jump_to_firstitem, open_result_win)
endfun

" keyword is given by user (via keyword_and_options)
" options are give by user (via keyword_and_options)
" jump_to_firstitem & open_result_win are fixed (jump_to_firstitem=0, open_result_win=1)
"
" keyword_and_options: a string having both keyword and options (e.g., "filePath -i")
fun! VIntSearch#SearchRaw(searchtype, searchcmd, keyword_and_options)
	let dblquota_indices = []
	for i in range(len(a:keyword_and_options))
		if a:keyword_and_options[i]==#'"'
			if i>0 && a:keyword_and_options[i-1]==#'\'
			else
				call add(dblquota_indices, i)
			endif
		endif
	endfor

	if len(dblquota_indices)==0
		let [keyword, options] = s:SplitKeywordOptions(a:keyword_and_options)
	elseif len(dblquota_indices)==2
		let keyword = a:keyword_and_options[dblquota_indices[0]:dblquota_indices[1]]
		if dblquota_indices[0]==0
			let options_raw = a:keyword_and_options[dblquota_indices[1]+1:]
		else
			let options_raw = a:keyword_and_options[:dblquota_indices[0]-1].a:keyword_and_options[dblquota_indices[1]+1:]
		endif
		let [non, options] = s:SplitKeywordOptions(options_raw)
	else
		echom 'VIntSearch: Only two quotation marks are allowed: '.a:keyword_and_options
		return
	endif

	call s:Search(a:searchtype, a:searchcmd, keyword, options, 0, 1)
endfun 

"""""""""""""""""""""""""""""""""""""""""
" search functions using VIntSearch#SearchCursor()

" just call VIntSearch#SearchCursor() with searchcmd 'default'
fun! VIntSearch#SearchCursorDefault(searchtype, vimmode, action)
	call VIntSearch#SearchCursor(a:searchtype, 'default', a:vimmode, a:action)
endfun

" just call VIntSearch#SearchCursor()
fun! VIntSearch#SearchCursorWithCmd(searchtype, searchcmd, vimmode, action)
	call VIntSearch#SearchCursor(a:searchtype, a:searchcmd, a:vimmode, a:action)
endfun

"""""""""""""""""""""""""""""""""""""""""
" search functions using VIntSearch#SearchRaw()

" VIntSearch#SearchRawDefault('text', 'filePath -i)
fun! VIntSearch#SearchRawDefault(searchtype, keyword_and_options)
	call VIntSearch#SearchRaw(a:searchtype, 'default', a:keyword_and_options)
endfun

" VIntSearch#SearchRawDefaultParse('text filePath -i)
fun! VIntSearch#SearchRawDefaultParse(type_and_keyword_and_options)
	let splited = split(a:type_and_keyword_and_options)
	let searchtype = splited[0]
	let keyword_and_options = join(splited[1:])
	call VIntSearch#SearchRaw(searchtype, 'default', keyword_and_options)
endfun

" VIntSearch#SearchRawWithCmdParse('text grep filePath -i)
fun! VIntSearch#SearchRawWithCmdParse(type_and_cmd_and_keyword_and_options)
	let splited = split(a:type_and_cmd_and_keyword_and_options)
	let searchtype = splited[0]
	let searchcmd = splited[1]
	let keyword_and_options = join(splited[2:])
	call VIntSearch#SearchRaw(searchtype, searchcmd, keyword_and_options)
endfun

"""""""""""""""""""""""""""""""""""""""""
" utility function used by VIntSearch#SearchRaw() to split keyword and option
function! s:SplitKeywordOptions(keyword_and_options)
	let space_tokens = split(a:keyword_and_options)
	let keyword = ''
	let options = ''
	for token in space_tokens
		if token[0]==#'-'
			if len(options)>0
				let options = options.' '
			endif
			let options = options.token
		else
			let keyword = token
		endif
	endfor
	return [keyword, options]
endfunction

"""""""""""""""""""""""""""""""""""""""""

function! VIntSearch#MoveBackward(use_quickfix)
	call s:MoveBackward(a:use_quickfix)
endfunction

function! VIntSearch#MoveForward(use_quickfix)
	call s:MoveForward(a:use_quickfix)
endfunction

"" functions
function! s:Cc(linenum, use_quickfix)
	if a:use_quickfix
		exec a:linenum.'cc'
	else
		exec a:linenum.'ll'
	endif
	call s:CheckJumpAfterSearch(a:use_quickfix)
endfunction

function! s:Cnext(wrap_around, use_quickfix)
	try
		if a:use_quickfix
			exec 'cnext'
		else
			exec 'lnext'
		endif
	catch E553
		if a:wrap_around
			exec 'cfirst'
		else
			echom 'VIntSearch: Cnext: No more items'
		endif
	endtry
	call s:CheckJumpAfterSearch(a:use_quickfix)
endfunction

function! s:Cprev(wrap_around, use_quickfix)
	try
		if a:use_quickfix
			execute 'cprev'
		else
			execute 'lprev'
		endif
	catch E553
		if a:wrap_around
			exec 'clast'
		else
			echom 'VIntSearch: Cprev: No more items'
		endif
	endtry
	call s:CheckJumpAfterSearch(a:use_quickfix)
endfunction

function! s:CheckJumpAfterSearch(use_quickfix)
	if a:use_quickfix
		let qflist = getqflist()
	else
		let qflist = getloclist(0)
	endif
	if len(qflist) < 1
		return
	else
		if match(qflist[0].text, 'VIntSearch') < 0
			return 
		endif
	endif

	if s:jump_after_search==0
		let s:stacklevel = s:stacklevel + 1
	endif
	let s:jump_after_search = 1
endfunction

function! s:UncheckJumpAfterSearch()
	let s:jump_after_search = 0
endfunction

function! s:ManipulateQFWindow(jump_to_firstitem, open_result_win, quickfix_splitcmd, use_quickfix)
	if a:jump_to_firstitem
		call s:Cc(2, a:use_quickfix)	|" because the first line is search result message
	endif
	if a:open_result_win
		if a:use_quickfix
			exec a:quickfix_splitcmd.' copen'
		else
			exec a:quickfix_splitcmd.' lopen'
		endif
	endif
endfunction

function! s:SetToCurStackLevel(keyword, type, file, line, text, qflist)
	if s:stacklevel < len(s:searchstack)
		unlet s:searchstack[s:stacklevel : ]
	endif
	call add(s:searchstack, 
			\{'keyword':a:keyword, 'type':a:type, 
			\'file':a:file, 'line':a:line, 'text':a:text,
			\'qflist':a:qflist})
endfunction

function! s:MoveForward(use_quickfix)
	if len(s:searchstack)==0
		echom 'VIntSearch: MoveForward: Search stack is empty.'
		return
	endif

	let s:stacklevel = s:stacklevel+1
	if s:stacklevel > len(s:searchstack)-1
		let s:stacklevel = len(s:searchstack)-1
	endif

	let buftype = getbufvar(winbufnr(0), '&buftype')
	if buftype==#'quickfix'
		exec 'wincmd p'
	endif

	let ss = s:searchstack[s:stacklevel]
	execute 'buffer '.ss.file
	if a:use_quickfix
		call setqflist(ss.qflist)
	else
		call setloclist(0, ss.qflist)
	endif

	call s:UncheckJumpAfterSearch()
	redraw
	echom 'VIntSearch: MoveForward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:MoveBackward(use_quickfix)
	if len(s:searchstack)==0
		echom 'VIntSearch: MoveBackward: Search stack is empty.'
		return
	endif

	let s:stacklevel = s:stacklevel-1
	if s:stacklevel < 0
		let s:stacklevel = 0
	endif

	let buftype = getbufvar(winbufnr(0), '&buftype')
	if buftype==#'quickfix'
		exec 'wincmd p'
	endif
	
	let ss = s:searchstack[s:stacklevel]
	execute 'buffer '.ss.file
	if a:use_quickfix
		call setqflist(ss.qflist)
	else
		call setloclist(0, ss.qflist)
	endif

	call s:UncheckJumpAfterSearch()
	redraw
	echom 'VIntSearch: MoveBackward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:ClearStack()
	unlet s:searchstack
	let s:searchstack = []
	let s:stacklevel = 0
	echom 'VIntSearch: Search stack is cleared.'
endfunction

function! s:PrintStack()
exec s:pythonX_until_EOF
import vim
def ltrunc(s, width, prefix=''):
	if width >= len(s): prefix = ''
	return prefix+s[-width+len(prefix):]
def rtrunc(s, width, postfix=''):
	if width >= len(s): postfix = ''
	return s[:width-len(postfix)]+postfix
def toWidthColMat(rowMat):
	colMat = [[None]*len(rowMat) for c in range(len(rowMat[0]))]
	for r in range(len(rowMat)):
		for c in range(len(rowMat[r])):
			colMat[c][r] = len(rowMat[r][c])
	return colMat

# build property matrix
propMat = []
propMat.append(['', '#', 'TO Keyword', 'Type', 'FROM File', 'Line', 'Text'])

searchstack = vim.eval('s:searchstack')
stacklevel = int(vim.eval('s:stacklevel'))
for i in range(len(searchstack)+1):
	if i==stacklevel:	mark = '> '
	else:				mark = '  '

	if i<len(searchstack):
		ss = searchstack[i]
		propMat.append([mark, str(i+1), ss['keyword'], ss['type'],\
						ss['file'], ss['line'], \
						ss['text'].lstrip().replace('\t',' ')]) 
	else:
		propMat.append([mark,'','','','','','']) 

# build width info
totalWidth = int(vim.eval('&columns'))-1
widthColMat = toWidthColMat(propMat)

widths = []
len_labels = 7
accWidth = 0
for c in range(len_labels):
	if c==0:	gapWidth = 0
	else:		gapWidth = 2
	maxColWidth = max(widthColMat[c])+gapWidth
	widths.append(maxColWidth)
	accWidth += maxColWidth

reduceWidth = accWidth - totalWidth
colFile = propMat[0].index('FROM File')
colText = propMat[0].index('Text')
if reduceWidth > 0:
	widths[colText] -= reduceWidth

# print
prefix = '..'
for r in range(len(propMat)):
	if r==0:	vim.command('echohl Title')
	s = ''
	for c in range(len(propMat[r])):
		if len(propMat[r][c])<widths[c]:
			if c==5:  # Line
				s += propMat[r][c].rjust(widths[c]-2) + '  '
			else:
				s += propMat[r][c].ljust(widths[c])
		else:
			if c==colFile:
				s += ltrunc(propMat[r][c], widths[c]-2, prefix) +'  '
			elif c==colText:
				s += rtrunc(propMat[r][c], widths[c]-2, prefix) +'  '
			else:
				s += propMat[r][c]
	vim.command('echo \'%s\''%s)
	if r==0:	vim.command('echohl None')
EOF
endfunction

""""""""""""""""""""""""""""""""""""""""""""
" find examples (on Linux)

"# exclude *.h or *impl* and include *layer*

"find -path *.h -prune -o -path *impl* -prune -o -path *layer* -print


"# exclude *.h or *impl* and include *.h or *layer*
"# : same result with 
"# exclude *.h or *impl* and include *layer*
"# because *.h has already been excluded

"find -path *.h -prune -o -path *impl* -prune -o -path *.h -print -o -path *layer* -print


"# exclude *.h or *impl* and include *.cpp or *layer*

"find -path *.h -prune -o -path *impl* -prune -o -path *.cpp -print -o -path *layer* -print


"# exclude *.h or *impl* and include *.cpp AND *layer*

"find -path *.h -prune -o -path *impl* -prune -o -path *.cpp -a -path *layer* -print
"find -path *.h -prune -o -path *impl* -prune -o \( -path *.cpp \) -a -path *layer* -print


"# exclude *.h or *impl*, include ( *.h or *.cpp ) AND *layer*
"# : same result with 
"# exclude *.h or *impl* and include *.cpp AND *layer*
"# because *.h has already been excluded

"find -path *.h -prune -o -path *impl* -prune -o \( -path *.h -o -path *.cpp \) -a -path *layer* -print


"# exclude *.h or *impl*, include ( *.html or *.cpp ) AND *layer*

"find -path *.h -prune -o -path *impl* -prune -o \( -path *.html -o -path *.cpp \) -a -path *layer* -print


"# exclude *.h or *impl* AND *layer*

"find -path *.h -prune -o -path *impl* -prune -a -path *layer* -print
""""""""""""""""""""""""""""""""""""""""""""

func! s:GetFindOptionForExclude(excludePattern)
	let findopt = ""
	for i in range(len(a:excludePattern))
		let pattern = a:excludePattern[i]
		let findopt = findopt."-path \"".pattern."\" -prune"
		if i<len(a:excludePattern)-1
			let findopt = findopt." -o "
		endif
	endfor
	return findopt
endfunc

"# exclude *.h or *impl* and include *.cpp or *layer*
func! s:MakeFindOptionAllOr()
	let findopt = s:GetFindOptionForExclude(g:vintsearch_excludepatterns)
	let findopt = findopt." "
	"if len(g:vintsearch_includepatterns) > 0
		"if !has('win32')
			"let findopt = findopt." -o "
		"endif
	"endif
	for i in range(len(g:vintsearch_includepatterns))
		let pattern = g:vintsearch_includepatterns[i]
		let findopt = findopt."-path \"".pattern."\" -print"
		if i<len(g:vintsearch_includepatterns)-1
			let findopt = findopt." -o "
		endif
	endfor
	return findopt
endfunc

"# exclude *.h or *impl*, include ( *.html or *.cpp ) AND *layer*
" linux find and UnxUtils find understand options in slightly different ways.
func! s:MakeFindOptionLastAndWith(keyword)
	let findopt = s:GetFindOptionForExclude(g:vintsearch_excludepatterns)
	if len(g:vintsearch_includepatterns) > 0
		if has('win32')
			let findopt = findopt." ^( "
		else
			"let findopt = findopt." -o \\( "
			let findopt = findopt." \\( "
		endif
	endif
	for i in range(len(g:vintsearch_includepatterns))
		let pattern = g:vintsearch_includepatterns[i]
		let findopt = findopt."-path \"".pattern."\""

		if i<len(g:vintsearch_includepatterns)-1
			let findopt = findopt." -o "
		endif
	endfor
	if len(g:vintsearch_includepatterns) > 0
		if has('win32')
			let findopt = findopt." ^) "
		else
			let findopt = findopt." \\) "
		endif
	endif
	let findopt = findopt." -a -path ".a:keyword." -print"
	return findopt
endfunc

"" old version of CombineGrepPatterns() and MakeGrepPatternOption()
"" use unix shell wildcard {}, which is not suppored by windows cmd.
"fun! s:CombineGrepPatterns(patterns)
	"let combStr = ""
	"if len(a:patterns)==1
		"let combStr = combStr.a:patterns[0]
	"else
		"let combStr = combStr."{"
		"for i in range(len(a:patterns))
			"let pattern = a:patterns[i]
			"let combStr = combStr.pattern
			"if i<len(a:patterns)-1
				"let combStr = combStr.","
			"endif
		"endfor
		"let combStr = combStr."}"
	"endif
	"return combStr
"endfun

"function! s:MakeGrepPatternOption()
	"let includeStr = s:CombineGrepPatterns(g:vintsearch_includepatterns)
	"let excludeStr = s:CombineGrepPatterns(g:vintsearch_excludepatterns)
	"let grepopt = "--include=".includeStr." --exclude=".excludeStr." --exclude-dir=".excludeStr
	"return grepopt
"endfunction

fun! s:CombineGrepPatterns(optionName, patterns)
	let combStr = ""
	for i in range(len(a:patterns))
		let combStr = combStr.a:optionName.a:patterns[i]." "
	endfor
	return combStr
endfun

function! s:MakeGrepPatternOption()
	let includeStr = s:CombineGrepPatterns("--include=", g:vintsearch_includepatterns)
	let excludeStr = s:CombineGrepPatterns("--exclude=", g:vintsearch_excludepatterns)
	let excludeDirStr = s:CombineGrepPatterns("--exclude-dir=", g:vintsearch_excludepatterns)
	let patternOpt = includeStr.excludeStr.excludeDirStr
	return patternOpt
endfunction

function! s:GetRepoDirFrom(filepath)
	if a:filepath==#''
		return ''
	endif
exec s:pythonX_until_EOF
repodirs = vim.eval('g:vintsearch_repodirs')
filepath = vim.eval('a:filepath')
dir = os.path.dirname(filepath)
while True:
	exist = False
	for repodir in repodirs:
		if os.path.exists(os.path.join(dir, repodir)):
			vim.command('return \'%s\''%dir)
			exist = True
			break
	if exist:
		break	

	prevdir = dir
	dir = os.path.dirname(dir)
	if dir==prevdir:
		#print 'no repo dir in ancestors of %s'%firstdir
		vim.command('return \'\'')
		break
EOF
	endif
endfunction

function! s:GetSearchPath(mode)
	if a:mode==#'rf'
		let searchpath = s:GetRepoDirFrom(expand("%:p"))
		if searchpath==#''
			let searchpath = expand("%:p")
		endif
		return searchpath
	elseif a:mode==#'rc'
		let searchpath = s:GetRepoDirFrom(expand("%:p"))
		if searchpath==#''
			let searchpath = getcwd()
		endif
		return searchpath
	elseif a:mode==#'c'
		let searchpath = getcwd()
		return searchpath
	else
		echom "VIntSearch: unknown search path mode \'".a:mode."\'"
		return ''
	endif
endfunction

function! s:PrintSearchPath()
	echom 'VIntSearch: Search path is: '.s:GetSearchPath(g:vintsearch_searchpathmode)
endfunction

function! s:BuildTag()
	let findopt = s:MakeFindOptionAllOr()
	
	let tagfilename = g:vintsearch_tagfilename
	
	let prevdir = getcwd()
	let searchpath = s:GetSearchPath(g:vintsearch_searchpathmode)
	if searchpath==#''
		return
	endif 
	execute 'cd' searchpath

	"execute ":!find ".findopt.">tf.tmp ; ctags --c++-kinds=+p -f ".tagfilename." -L tf.tmp --fields=+n ; rm tf.tmp"

	let findcmdopt ='"'.g:vintsearch_findcmd_path.'" '.findopt

	let pathListStr = system(findcmdopt)
	let pathList = split(pathListStr, '\n')
	call writefile(pathList, "tf.tmp")
	execute ":silent !ctags --c++-kinds=+p -f ".tagfilename." -L tf.tmp --fields=+n"
	call delete("tf.tmp")
	
	execute 'cd' prevdir
	
	redraw

	if !filereadable(searchpath.'/'.g:vintsearch_tagfilename)
		echom "VIntSearch: The tag file is NOT created. Please install Exuberant Ctags first."
	else
		echom "VIntSearch: The tag file for all source files under \'".searchpath."\' has been created: ".searchpath."/".tagfilename
	endif
endfunction

function! s:DoFinishingWork(qflist, keyword, searchtype, searchcmd, options, jump_to_firstitem, open_result_win, use_quickfix)
	let numresults = len(a:qflist)
	if len(a:options)>0
		let optionstr = ' '.a:options
	else
		let optionstr = a:options
	endif

	let message = 'VIntSearch ('.a:searchtype.' search by '.a:searchcmd.optionstr.'): '.numresults.' results are found for: '.a:keyword 

 	if numresults>0
		call insert(a:qflist, {'text':message}, 0)
		if a:use_quickfix
			call setqflist(a:qflist)
		else
			call setloclist(0, a:qflist)
		endif

		call s:SetToCurStackLevel(a:keyword, a:searchtype, expand('%'), line('.'), getline(line('.')), a:qflist)
		call s:UncheckJumpAfterSearch()
		call s:ManipulateQFWindow(a:jump_to_firstitem, a:open_result_win, g:vintsearch_qfsplitcmd, a:use_quickfix)

		if g:vintsearch_highlight_group !=# ''
			exec ':match '.g:vintsearch_highlight_group.' /'.a:keyword.'/'
		endif
	endif

	redraw

	echom message
endfunction

function! s:GetGrepQFList(keyword, options, use_quickfix, ...)
	let prevdir = getcwd()
	let searchpath = s:GetSearchPath(g:vintsearch_searchpathmode)
	if searchpath==#''
		return [0]
	endif 
	execute 'cd' searchpath

	if a:use_quickfix
		let grepcmd = 'grep'
	else
		let grepcmd = 'lgrep'
	endif

	"grep! prevents grep from opening first result
	if a:0 > 0	|"grep in a file (filepath: a:1)
		exec "\:".grepcmd."! ".a:options." -e ".a:keyword." ".a:1
	else
		let patternopt = s:MakeGrepPatternOption()
		exec "\:".grepcmd."! -r ".patternopt." ".a:options." -e ".a:keyword." *"
	endif

	execute 'cd' prevdir

	if a:use_quickfix
		let qflist = getqflist()
	else
		let qflist = getloclist(0)
	endif
	return qflist
endfunction

function! s:GetFindQFList(keyword, options)
	let prevdir = getcwd()
	let searchpath = s:GetSearchPath(g:vintsearch_searchpathmode)
	if searchpath==#''
		return [0]
	endif 
	execute 'cd' searchpath

	let findopt = s:MakeFindOptionLastAndWith(a:keyword)

	"let keyword_option = '-path'
	"if a:options =~ '-i'
		"let keyword_option = '-ipath'
	"endif

	" todo: use find . and grep (find all files paths and search keyword & include & exclude via grep)
	" http://stackoverflow.com/questions/13073731/linux-find-on-multiple-patterns

	let findcmdopt ='"'.g:vintsearch_findcmd_path.'" '.findopt
	"echoerr findcmdopt
	let pathListStr = system(findcmdopt)
	let pathList = split(pathListStr, '\n')

	execute 'cd' prevdir

	let qflist = []
	for path in pathList
		" getqflist()
		"[{'lnum': 124, 'bufnr': 59, 'col': 0, 'valid': 1, 'vcol': 0, 'nr': -1,
		"'type': '', 'pattern': '', 'text': 'FindTags generateClassificationBind()
		"'},
		"{'lnum': 193, 'bufnr': 59, 'col': 0, 'valid': 1, 'vcol': 0, 'nr': -1,
		"'type': '', 'pattern': '', 'text': ' generateClassificationBind()
		"'}]

		let qfitem = {
		  \ 'filename': path,
		  \ 'lnum': 0, 
		  \ 'text': '',
		  \ }
		call add(qflist, qfitem)
	endfor

	return qflist
endfunction

" ctags list to quickfix
"http://andrewradev.com/2011/06/08/vim-and-ctags/
"http://andrewradev.com/2011/10/15/vim-and-ctags-finding-tag-definitions/
function! s:GetCtagsQFList(keyword)
	let searchpath = s:GetSearchPath(g:vintsearch_searchpathmode)
	if searchpath==#''
		return [0]
	endif 

	if !filereadable(searchpath.'/'.g:vintsearch_tagfilename)
		echom 'VIntSearch: No tag file in search path '.searchpath.'. Please run :VIntSearchBuildSymbolDB or :VSbuild and try again.'
		return [0]
	endif

	if 1
		""""""""""""""""""""""""""""""""
		" using taglist()
		"""""""""""""""""""""""""""""""
		let tags = taglist('^'.a:keyword.'$')
		for entry in tags
			let text = substitute(entry['cmd'], '/^', '', '')
			let text = substitute(text, '$/', '', '')
			"echo text
			let entry.text = text
		endfor

	else
		""""""""""""""""""""""""""""""""
		" using :ts
		  "# pri kind tag               파일
		  "1 FS  m    mObjectList       ./Samples/sample5_limbIK/TestWin.cpp
					   "line:51 class:TestWin_impl 
					   "ObjectList mObjectList;
		  "2 FS  m    mObjectList       /home/yoonsang/Data/Research/2013_4_newQP/Code/taesooLib_yslee/Samples/sample5_limbIK/TestWin.cpp
					   "line:51 class:TestWin_impl 
					   "ObjectList mObjectList;
		"숫자 입력후 <엔터> (숫자없으면 취소): 
		"""""""""""""""""""""""""""""""
		redir => output
		silent execute 'ts '.a:keyword
		redir END
		let tags = []

exec s:pythonX_until_EOF
	import vim

	def splitTaglineByIndexes(tagline, indexes):
		tokens = []
		for i in range(len(labelidxs)):
			if i==0:					tokens.append(tagline[:labelidxs[i]+1])
			elif i==len(labelidxs)-1:	tokens.append(tagline[labelidxs[i]:])
			else:						tokens.append(tagline[labelidxs[i]:labelidxs[i+1]])
		return tokens

	output = vim.eval('output')
	#print output

	lines = output.split('\n')
	del lines[0]	# remove 'blank' line

	if not lines[2].startswith('E426'):
		labels = lines[0].split()
		labelidxs = [lines[0].find(label) for label in labels]
		#print labels
		#print splitLabelsByIndexes(lines[0], labelidxs)
		del lines[0]	# remove first row 'label' line

		lineinitem = -1
		for line in lines:
			firstToken = line.lstrip().split()[0]
			#print firstToken
			#print line

			if firstToken.isdigit():	# lineinitem 0
				num, pri, kind, tag, filename =  splitTaglineByIndexes(line, labelidxs)
				#print num, pri, kind, tag, filename
				#print line
				lineinitem = 0
				tokens = line.split()
				vim.command('call add(tags, {})') 
				vim.command('let tags[-1].num = '+num)
				vim.command('let tags[-1].pri = '+repr(pri))
				vim.command('let tags[-1].kind = '+repr(kind))
				vim.command('let tags[-1].tag = '+repr(tag))
				vim.command('let tags[-1].filename = '+repr(filename))
				lineinitem += 1
			else:
				if lineinitem==1:
					tokens = line.split()
					for token in tokens:
						key, value = token.split(':', 1)
						if value.isdigit():	value = int(value)
						vim.command('let tags[-1].%s = %s'%(key, repr(value)))
					lineinitem += 1
				elif lineinitem==2:
					vim.command('let tags[-1].text = '+repr(line))
					lineinitem += 1
				else:
					continue
EOF
	endif

	" Retrieve tags of the 'f' kind
	"let tags = filter(tags, 'v:val["kind"] == "f"')

	" Prepare them for inserting in the quickfix window
	let qflist = []
	for entry in tags
		" getqflist()
		"[{'lnum': 124, 'bufnr': 59, 'col': 0, 'valid': 1, 'vcol': 0, 'nr': -1,
		"'type': '', 'pattern': '', 'text': 'FindTags generateClassificationBind()
		"'},
		"{'lnum': 193, 'bufnr': 59, 'col': 0, 'valid': 1, 'vcol': 0, 'nr': -1,
		"'type': '', 'pattern': '', 'text': ' generateClassificationBind()
		"'}]

		let qfitem = {
		  \ 'filename': entry.filename,
		  \ 'lnum': entry.line, 
		  \ 'text': entry.text,
		  \ }
		call add(qflist, qfitem)
	endfor

	return qflist
endfunction



"""""""""""""""""""""""""""""""""""""""""""""
" utility function

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
