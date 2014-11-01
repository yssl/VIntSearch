" wrappers
function! VIntSearch#Cc(linenum)
	call s:Cc(a:linenum)
endfunction

function! VIntSearch#Cnext()
	call s:Cnext()
endfunction

function! VIntSearch#Cprev()
	call s:Cprev()
endfunction

function! VIntSearch#BuildTag()
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

function! VIntSearch#Search(keyword, cmd, options, is_literal, jump_to_firstitem, open_quickfix)
	if a:is_literal
		let search_keyword = "\"".a:keyword."\""
	else
		let search_keyword = a:keyword
	endif

	if a:cmd==#'ctags'
		let qflist = s:GetCtagsQFList(search_keyword)
	elseif a:cmd==#'grep'
		let qflist = s:GetGrepQFList(search_keyword, a:options)
	else
		echo 'VIntSearch: '.a:cmd.': Unsupported command.'
		return
	endif

	call s:DoFinishingWork(qflist, search_keyword, a:cmd, a:options, a:jump_to_firstitem, a:open_quickfix)
endfunction

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

function! VIntSearch#SearchRaw(keyword_and_options, cmd, jump_to_firstitem, open_quickfix)
	let dblquota_indices = []
	for i in range(len(a:keyword_and_options))
		if a:keyword_and_options[i]==#'"'
			call add(dblquota_indices, i)
		endif
	endfor

	if len(dblquota_indices)==0
		let is_literal = 0
		let [keyword, options] = s:SplitKeywordOptions(a:keyword_and_options)
	elseif len(dblquota_indices)==2
		let is_literal = 1
		let keyword = a:keyword_and_options[dblquota_indices[0]+1:dblquota_indices[1]-1]
		let options_raw = a:keyword_and_options[:dblquota_indices[0]-1].a:keyword_and_options[dblquota_indices[1]+1:]
		let [non, options] = s:SplitKeywordOptions(options_raw)
	else
		echo 'VIntSearch: Only two quotation marks are allowed: '.a:keyword_and_options
		return
	endif

	"echo dblquota_tokens
	"echo keyword is_literal options 
	call VIntSearch#Search(keyword, a:cmd, options, is_literal, a:jump_to_firstitem, a:open_quickfix)
endfunction 

function! VIntSearch#MoveBackward()
	call s:MoveBackward()
endfunction

function! VIntSearch#MoveForward()
	call s:MoveForward()
endfunction

"" script variable
if !exists('s:searchstack')
	let s:searchstack = []
endif
if !exists('s:stacklevel')
	let s:stacklevel = 0
endif
if !exists('s:jump_after_search')
	let s:jump_after_search = 0
endif

"" functions
function! s:Cc(linenum)
	execute a:linenum.'cc'
	call s:CheckJumpAfterSearch()
endfunction

function! s:Cnext()
	execute 'cnext'
	call s:CheckJumpAfterSearch()
endfunction

function! s:Cprev()
	execute 'cprev'
	call s:CheckJumpAfterSearch()
endfunction

function! s:CheckJumpAfterSearch()
	let qflist = getqflist()
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

function! s:ManipulateQFWindow(jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	if a:jump_to_firstitem
		call s:Cc(2)	|" because the first line is search result message
	endif
	if a:open_quickfix
		execute a:quickfix_splitcmd.' copen'
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

function! s:MoveForward()
	if len(s:searchstack)==0
		echo 'VIntSearch: MoveForward: Search stack is empty.'
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
	call setqflist(ss.qflist)

	call s:UncheckJumpAfterSearch()
	redraw
	echo 'VIntSearch: MoveForward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:MoveBackward()
	if len(s:searchstack)==0
		echo 'VIntSearch: MoveBackward: Search stack is empty.'
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
	call setqflist(ss.qflist)

	call s:UncheckJumpAfterSearch()
	redraw
	echo 'VIntSearch: MoveBackward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:ClearStack()
	unlet s:searchstack
	let s:searchstack = []
	let s:stacklevel = 0
	echo 'VIntSearch: Search stack is cleared.'
endfunction

function! s:PrintStack()
python << EOF
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
propMat.append(['', '#', 'TO Keyword', 'CMD', 'FROM File', 'Line', 'Text'])

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

function! s:MakeFindOpt()
	let findopt = ""
	for i in range(len(g:vintsearch_codeexts))
		let ext = g:vintsearch_codeexts[i]
		let findopt = findopt."-iname \'*.".ext."\'"
		if i<len(g:vintsearch_codeexts)-1
			let findopt = findopt." -o "
		endif
	endfor
	return findopt
endfunction

function! s:MakeGrepOpt()
	let grepopt = "--include=*.{"
	for i in range(len(g:vintsearch_codeexts))
		let ext = g:vintsearch_codeexts[i]
		let grepopt = grepopt.ext
		if i<len(g:vintsearch_codeexts)-1
			let grepopt = grepopt.","
		endif
	endfor
	let grepopt = grepopt."}"
	return grepopt
endfunction

function! s:MakeFindStrOpt()
	let findstropt = ""
	for i in range(len(g:vintsearch_codeexts))
		let ext = '*.'.g:vintsearch_codeexts[i]
		let findstropt = findstropt.ext
		if i<len(g:vintsearch_codeexts)-1
			let findstropt = findstropt." "
		endif
	endfor
	echo findstropt
	return findstropt
endfunction

"function! s:GetRepoDirFrom(filepath, buftype)
function! s:GetRepoDirFrom(filepath)
	"if a:buftype==#'nofile' || a:buftype==#'quickfix' || a:filepath=='None'
		"return ''
	"else
	if a:filepath==#''
		return ''
	endif
python << EOF
repodirs = vim.eval('g:vintsearch_repodirs')
filepath = vim.eval('a:filepath')
dir = os.path.dirname(filepath)
while True:
	prevdir = dir
	dir = os.path.dirname(prevdir)
	if dir==prevdir:
		# no repository found case
		vim.command('return \'\'')
		break
	else:
		exist = False
		for repodir in repodirs:
			if os.path.exists(os.path.join(dir, repodir)):
				vim.command('return \'%s\''%dir)
				exist = True
				break
		if exist:
		   break	
EOF
	endif
endfunction

function! s:GetWorkDir(mode)
	if a:mode==#'rf'
		let workdir = s:GetRepoDirFrom(expand("%:p"))
		if workdir==#''
			let workdir = expand("%:p")
		endif
		return workdir
	elseif a:mode==#'rc'
		let workdir = s:GetRepoDirFrom(expand("%:p"))
		if workdir==#''
			let workdir = getcwd()
		endif
		return workdir
	elseif a:mode==#'c'
		let workdir = getcwd()
		return workdir
	else
		echo "VIntSearch: unknown workdir mode \'".a:mode."\'"
		return ''
	endif
endfunction

function! s:PrintSearchPath()
	echo 'VIntSearch: Search path is: '.s:GetWorkDir(g:vintsearch_searchpathmode)
endfunction

function! s:BuildTag()
	let findopt = s:MakeFindOpt()
	"echo findopt
	"return
	
	let tagfilename = g:vintsearch_tagfilename
	
	let prevdir = getcwd()
	let workdir = s:GetWorkDir(g:vintsearch_searchpathmode)
	if workdir==#''
		return
	endif 
	execute 'cd' workdir

	execute ":!find ".findopt.">tf.tmp ; ctags -f ".tagfilename." -L tf.tmp --fields=+n ; rm tf.tmp"
	
	execute 'cd' prevdir
	
	redraw
	echo "VIntSearch: A tagfile for code files in \'".workdir."\' is created: ".workdir."/".tagfilename
endfunction

function! s:DoFinishingWork(qflist, keyword, cmd, options, jump_to_firstitem, open_quickfix)
	let numresults = len(a:qflist)
	if len(a:options)>0
		let optionstr = ' '.a:options
	else
		let optionstr = a:options
	endif
	let message = 'VIntSearch (by '.a:cmd.optionstr.'): '.numresults.' results are found for: '.a:keyword

 	if numresults>0
		call insert(a:qflist, {'text':message}, 0)
		call setqflist(a:qflist)

		call s:SetToCurStackLevel(a:keyword, a:cmd.optionstr, expand('%'), line('.'), getline(line('.')), a:qflist)
		call s:UncheckJumpAfterSearch()
		call s:ManipulateQFWindow(a:jump_to_firstitem, a:open_quickfix, g:vintsearch_qfsplitcmd)
	endif

	redraw
	echo message
endfunction

function! s:GetGrepQFList(keyword, options)
	let prevdir = getcwd()
	let workdir = s:GetWorkDir(g:vintsearch_searchpathmode)
	if workdir==#''
		return
	endif 
	execute 'cd' workdir

	"grep! prevents grep from opening first result
	if has('win32')		|"findstr in windows
		let findstropt = s:MakeFindStrOpt()
		execute "\:grep! /s ".a:keyword." ".findstropt
	else	|"grep in unix
		let grepopt = s:MakeGrepOpt()
		"echo grepopt
		execute "\:grep! -r ".grepopt." ".a:options." ".a:keyword." *"
	endif

	execute 'cd' prevdir

	let qflist = getqflist()
	return qflist
endfunction

" ctags list to quickfix
"http://andrewradev.com/2011/06/08/vim-and-ctags/
"http://andrewradev.com/2011/10/15/vim-and-ctags-finding-tag-definitions/
function! s:GetCtagsQFList(keyword)
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

python << EOF
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
