"""""""""""""""""""""""""""""""""""""""""""""
" template code
" Exit when your app has already been loaded (or "compatible" mode set)
if exists("g:loaded_stsearch") || &cp
  finish
endif
let g:loaded_stsearch	= 1
let s:keepcpo           = &cpo
set cpo&vim
 
""""""""""""""""""""""""""""""""""""""""""""""
"" my code

"" global variables
if !exists('g:stsearch_codeexts')
	let g:stsearch_codeexts = ["m","c","cpp","h","hpp","inl","py","lua"]
endif
if !exists('g:stsearch_searchresults')
	let g:stsearch_searchresults = []
endif
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
"
" commands 
command! StSearchBuildTag call s:BuildTag()
command! -complete=tag -nargs=1 StSearchFindCtag call s:FindCtag(<f-args>)
command! -complete=tag -nargs=1 StSearchFindGrep call s:FindGrep(<f-args>)

"" autocmd
"augroup WDManagerAutoCmds
	"autocmd!
	"autocmd BufEnter * call s:ChangeToWDof(expand('<afile>')) 
"augroup END

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


"let g:origbufname = ''
"function! SaveCurBufName()
	"let g:origbufname = bufname('%')
"endfunction
"command! SaveCurBufName call SaveCurBufName()

function! s:FindGrep(name)
	call feedkeys("\<Esc>")
	"grep! prevents grep from opening first result
	echo "\:grep! -r ".s:grepopt." ".a:name." *\<CR>")
	call feedkeys("\:grep! -r ".s:grepopt." ".a:name." *\<CR>")
	call s:QuickfixOpen()
endfunction

function! s:QuickfixOpen()
	botright copen
	execute 'wincmd p'
endfunction


" ctags list to quickfix
"http://andrewradev.com/2011/06/08/vim-and-ctags/
"http://andrewradev.com/2011/10/15/vim-and-ctags-finding-tag-definitions/
function! s:FindCtag(name)
	""""""""""""""""""""""""""""""""
	" using taglint()
	"""""""""""""""""""""""""""""""
	"call SaveCurBufName()
	"let tags = taglist('^'.a:name.'$')
	"for entry in tags
		"let text = substitute(entry['cmd'], '/^', '', '')
		"let text = substitute(text, '$/', '', '')
		""echo text
		"let entry.text = text
	"endfor

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
	silent execute 'ts '.a:name
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
	"echo tags
	"return

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

  " Place the tags in the quickfix window, if possible
  if len(qf_taglist) > 0
    call setqflist(qf_taglist)
	call QuickfixOpen()
  else
    echo "No tags found for ".a:name
  endif
endfunction
command! -nargs=1 FindTags call s:FindTags(<f-args>)



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
