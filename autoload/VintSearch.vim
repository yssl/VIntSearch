" wrappers
function! VintSearch#Cc(linenum)
	call s:Cc(a:linenum)
endfunction

function! VintSearch#Cnext()
	call s:Cnext()
endfunction

function! VintSearch#Cprev()
	call s:Cprev()
endfunction

function! VintSearch#BuildTag()
	call s:BuildTag()
endfunction

function! VintSearch#PrintStack()
	call s:PrintStack()
endfunction

function! VintSearch#PrintSearchPath()
	call s:PrintSearchPath()
endfunction

function! VintSearch#ClearStack()
	call s:ClearStack()
endfunction

function! VintSearch#SearchCtags(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	call s:SearchCtags(a:keyword, a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
endfunction

function! VintSearch#SearchGrep(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	call s:SearchGrep(a:keyword, a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
endfunction

function! VintSearch#MoveBackward()
	call s:MoveBackward()
endfunction

function! VintSearch#MoveForward()
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

function! s:Cprev(linenum)
	execute 'cprev'
	call s:CheckJumpAfterSearch()
	endif
endfunction

function! s:CheckJumpAfterSearch()
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
		call s:Cc(1)
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
	echo 'VintSearch: MoveForward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:MoveBackward()
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
	echo 'VintSearch: MoveBackward: Stack level is now: '.(s:stacklevel+1)
endfunction

function! s:ClearStack()
	unlet s:searchstack
	let s:searchstack = []
	let s:stacklevel = 0
	echo 'VintSearch: Search stack is cleared.'
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

# stack level, keyword, search type, file, line, text
width_stacklevel = 2
width_searchtype = 5
width_line = 6
widths = {'lv':width_stacklevel,
		'keyword':int(vim.eval('g:vintsearch_width_keyword')), 
		'type':width_searchtype, 
		'file':int(vim.eval('g:vintsearch_width_file')), 
		'line':width_line, 
		'text':int(vim.eval('g:vintsearch_width_text'))}
prefix = '..'

print '  %s  %s  %s  %s  %s  %s'%('LV'.ljust(widths['lv']),
								'Keyword'.ljust(widths['keyword']), 
								'Type'.ljust(widths['type']), 
								'Text'.ljust(widths['text']),
								'Line'.ljust(widths['line']), 
								'File'.ljust(widths['file']))

searchstack = vim.eval('s:searchstack')
stacklevel = int(vim.eval('s:stacklevel'))
#print stacklevel
for i in range(len(searchstack)+1):
	if i==stacklevel: mark = '> '
	else:				mark = '  '

	if i<len(searchstack):
		ss = searchstack[i]
		itemsd = {'lv':str(i+1), 'keyword':ss['keyword'],
				'type':ss['type'], 'text':ss['text'].lstrip().replace('\t',' '), 
				'line':ss['line'], 'file':ss['file']}
		for k in itemsd:
			if len(itemsd[k])<widths[k]:	itemsd[k] = itemsd[k].ljust(widths[k])
			else:
				if k=='file':
					itemsd[k] = ltrunc(itemsd[k], widths[k], prefix)
				else:
					itemsd[k] = rtrunc(itemsd[k], widths[k], prefix)

		print '%s%s  %s  %s  %s  %s  %s'%(mark,
										itemsd['lv'],
										itemsd['keyword'], 
										itemsd['type'],
										itemsd['text'], 
										itemsd['line'], 
										itemsd['file'])
	else:
		print '%s'%mark
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

function! s:FindRepoDirFrom(dir)
python << EOF
import vim
repodirs = vim.eval('g:repodirs')
firstdir = vim.eval('a:dir')
dir = firstdir
while True:
	prevdir = dir
	dir = os.path.dirname(prevdir)
	if dir==prevdir:
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
endfunction

function! s:GetWorkDir(mode)
	if a:mode==#'rf'
		let workdir = s:FindRepoDirFrom(expand("%:p"))
		if workdir==#''
			let workdir = expand("%:p")
		endif
		return workdir
	elseif a:mode==#'rc'
		let workdir = s:FindRepoDirFrom(expand("%:p"))
		if workdir==#''
			let workdir = getcwd()
		endif
		return workdir
	else
		echo "VintSearch: unknown workdir mode \'".a:mode."\'"
		return ''
	endif
endfunction

function! s:PrintSearchPath()
	echo 'VintSearch: Search path is: '.s:GetWorkDir(g:vintsearch_workdir_mode)
endfunction

function! s:BuildTag()
	let findopt = s:MakeFindOpt()
	"echo findopt
	"return
	
	let tagfilename = 'tags'
	
	let prevdir = getcwd()
	let workdir = s:GetWorkDir(g:vintsearch_workdir_mode)
	if workdir==#''
		return
	endif 
	execute 'cd' workdir

	execute ":!find ".findopt.">tf.tmp ; ctags -f ".tagfilename." -L tf.tmp --fields=+n ; rm tf.tmp"
	
	execute 'cd' prevdir
	
	redraw
	echo "VintSearch: A tagfile for code files in \'".workdir."\' is created: ".workdir."/".tagfilename
endfunction

function! s:DoFinishingWork(qflist, type, keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	let numresults = len(a:qflist)
	let message = 'VintSearch (by '.a:type.'): '.numresults.' results are found for: '.a:keyword

 	if numresults>0
		call insert(a:qflist, {'text':message}, 0)
		call setqflist(a:qflist)

		call s:SetToCurStackLevel(a:keyword, a:type, expand('%'), line('.'), getline(line('.')), a:qflist)
		call s:UncheckJumpAfterSearch()
		call s:ManipulateQFWindow(a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
	endif

	redraw
	echo message
endfunction

function! s:SearchGrep(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	let grepopt = s:MakeGrepOpt()
	"echo grepopt
	"return

	let prevdir = getcwd()
	let workdir = s:GetWorkDir(g:vintsearch_workdir_mode)
	if workdir==#''
		return
	endif 
	execute 'cd' workdir

	"grep! prevents grep from opening first result
	execute "\:grep! -r ".grepopt." ".a:keyword." *"

	execute 'cd' prevdir

	let qflist = getqflist()
	call s:DoFinishingWork(qflist, 'grep', a:keyword, a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
endfunction

" ctags list to quickfix
"http://andrewradev.com/2011/06/08/vim-and-ctags/
"http://andrewradev.com/2011/10/15/vim-and-ctags-finding-tag-definitions/
function! s:SearchCtags(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
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

	call s:DoFinishingWork(qflist, 'ctags', a:keyword, a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
endfunction
