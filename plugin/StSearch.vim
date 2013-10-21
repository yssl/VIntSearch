"""""""""""""""""""""""""""""""""""""""""""""
" template code
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_stsearch") || &cp
	finish
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
command! StSearchBuildTag call s:BuildTag()
"command! -complete=tag -nargs=1 StSearchCtag call s:FindCtags(<f-args>)
"command! -complete=tag -nargs=1 StSearchGrep call s:FindGrep(<f-args>)

command! StSearchJumpCtagCursor call s:FindCtags(expand('<cword>'),1,0,'botright')
command! StSearchJumpGrepCursor call s:FindGrep(expand('<cword>'),1,0,'botright')

command! StSearchListCtagCursor call s:FindCtags(expand('<cword>'),0,1,'botright')
command! StSearchListGrepCursor call s:FindGrep(expand('<cword>'),0,1,'botright')

command! StSearchPrintStack call s:PrintStack()
command! StSearchClearStack call s:ClearStack()

"" autocmd
"augroup WDManagerAutoCmds
	"autocmd!
	"autocmd BufEnter * call s:ChangeToWDof(expand('<afile>')) 
"augroup END


"" script variable
if !exists('s:searchstack')
	let s:searchstack = []
endif
if !exists('s:stacklevel')
	let s:stacklevel = 0
endif

let s:grepopt = "--include=*.{"
let s:findopt = ""
for i in range(len(g:stsearch_codeexts))
	let ext = g:stsearch_codeexts[i]
	let s:grepopt = s:grepopt.ext
	let s:findopt = s:findopt."-iname *.".ext
	if i<len(g:stsearch_codeexts)-1
		let s:grepopt = s:grepopt.","
		let s:findopt = s:findopt." -o "
	endif
endfor
let s:grepopt = s:grepopt."}"


"" functions
function! s:BuildTag()
	call feedkeys(":!find ".s:findopt.">tf.tmp ; ctags -L tf.tmp --fields=+n ; rm tf.tmp\<CR>")
endfunction

function! s:ManipulateQFWindow(jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	if a:jump_to_firstitem
		execute '1cc'
	endif
	if a:open_quickfix
		execute a:quickfix_splitcmd.' copen'
	endif
endfunction

function! s:SetToCurStackLevel(keyword, file, line, text)
	if s:stacklevel < len(s:searchstack)
		unlet s:searchstack[s:stacklevel : ]
	endif
	call add(s:searchstack, {'keyword':a:keyword, 'file':a:file, 'line':a:line, 'text':a:text})
	"todo - increase stack level only when jump to one of the result list
	"todo - map decrease & increase function
	"todo - shortname version of stsearchprint
	"todo - autoload file split
endfunction

function! s:IncreaseStackLevel()
	let s:stacklevel = s:stacklevel+1
	if s:stacklevel > len(s:searchstack)
		let s:stacklevel = len(s:searchstack)
	endif
	" todo - change buffer & quickfix to current level
endfunction

function! s:DecreaseStackLevel()
	let s:stacklevel = s:stacklevel-1
	if s:stacklevel < 0
		let s:stacklevel = 0
	endif
	" todo - change buffer & quickfix to current level
endfunction

function! s:ClearStack()
	unlet s:searchstack
	let s:searchstack = []
	let s:stacklevel = 1
	echo 'StSearch: Search stack is cleared'
endfunction

function! s:PrintStack()
	"todo - print type (grep or ctags)
	for i in range(len(s:searchstack))
		if s:stacklevel==i
			echo '> '.(i+1).' '.s:searchstack[i].keyword.' '.s:searchstack[i].file.' '.s:searchstack[i].line.' '.s:searchstack[i].text
		else
			echo (i+1).' '.s:searchstack[i].keyword.' '.s:searchstack[i].file.' '.s:searchstack[i].line.' '.s:searchstack[i].text
		endif
	endfor
endfunction

function! s:FindGrep(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
	"grep! prevents grep from opening first result
	execute "\:grep! -r ".s:grepopt." ".a:keyword." *"

	let numresults = len(getqflist())
 	if numresults>0
		call s:SetToCurStackLevel(a:keyword, expand('<afile>'), line('.'), getline(line('.')))
		call s:ManipulateQFWindow(a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
	endif

	redraw
	echo 'StSearch (by grep): '.numresults.' results are found for: '.a:keyword
endfunction

" ctags list to quickfix
"http://andrewradev.com/2011/06/08/vim-and-ctags/
"http://andrewradev.com/2011/10/15/vim-and-ctags-finding-tag-definitions/
function! s:FindCtags(keyword, jump_to_firstitem, open_quickfix, quickfix_splitcmd)
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

	"echo tags

	" Retrieve tags of the 'f' kind
	"let tags = filter(tags, 'v:val["kind"] == "f"')

	" Prepare them for inserting in the quickfix window
	let qf_taglist = []
	for entry in tags
		"echo entry

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
		call add(qf_taglist, qfitem)
	endfor

  "" Place the tags in the quickfix window, if possible
  "if len(qf_taglist) > 0
    "call setqflist(qf_taglist)
	"call QuickfixOpen()
  "else
    "echo "No tags found for ".a:name
  "endif


	let numresults = len(qf_taglist)
 	if numresults>0
    	call setqflist(qf_taglist)
		call s:SetToCurStackLevel(a:keyword, expand('<afile>'), line('.'), getline(line('.')))
		call s:ManipulateQFWindow(a:jump_to_firstitem, a:open_quickfix, a:quickfix_splitcmd)
	endif

	redraw
	echo 'StSearch (by ctags): '.numresults.' results are found for: '.a:keyword

endfunction


"""""""""""""""""""""""""""""""""""""""""""""
" template code
let &cpo= s:keepcpo
unlet s:keepcpo
