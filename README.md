# VIntSearch

VIntSearch is a vim plugin providing an integrated interface across various types of searches. It currently supports symbol search (by ctags) and text search (by grep).
Search results are given in the quickfix window and a user can conviniently move to previous or next search results via the integrated search stack.
VIntSearch means Vim Integrated Search.

## Features

- Quickfix-listed search results for all types of searches
- Integrated search stack containing search history for all types of searches (similar to vim's tag stack, but more general one)
- Unified search path for all search types
- Stacking not only search keywords and their position, but also search results in the quickfix
- Search keyword can be from a word under the cursor, visually selected text, or any string you type.

## Screenshots

- Integrated search stack
![stack](https://cloud.githubusercontent.com/assets/5915359/4852497/9085b67a-607c-11e4-8300-1928ecb5d850.png)

- Search results by ctags
![byctags](https://cloud.githubusercontent.com/assets/5915359/4852495/903a342a-607c-11e4-8b01-a4dde78d9492.png)

- Search results by grep
![bygrep](https://cloud.githubusercontent.com/assets/5915359/4852496/907e4ea8-607c-11e4-9c50-e25a8770aad8.png)

## Installation

- Using plugin managers (recommended)
    - [Vundle](https://github.com/gmarik/Vundle.vim) : Add `Plugin 'yssl/VIntSearch'` to .vimrc & `:PluginInstall`
    - [NeoBundle](https://github.com/Shougo/neobundle.vim) : Add `NeoBundle 'yssl/VIntSearch'` to .vimrc & `:NeoBundleInstall`
    - [vim-plug](https://github.com/junegunn/vim-plug) : Add `Plug 'yssl/VIntSearch'` to .vimrc & `:PlugInstall`
- Using [Pathogen](https://github.com/tpope/vim-pathogen)
    - `cd ~/.vim/bundle; git clone https://github.com/yssl/VIntSearch.git`
- Manual install (not recommended)
    - Download this plugin and extract it in `~/.vim/`

This plugin requires a version of vim with python support. You can check your vim with `:echo has('python')`.
If your vim doesn't support python, one of the easiest solutions would be installing a more featured version of vim by:  
`sudo apt-get install vim-nox`

## Getting Started

1. You need Exuberant Ctags to fully use this plugin. If you don't have it, please install it first: ```sudo apt-get install exuberant-ctags```.
2. Install this plugin.
3. Open one of your source files with vim.
4. Build a tag file by typing **:VIntSearchBuildTag**. The tag file will be created in the nearest ancestor dir that contains a repository dir such as ```.git```, or in the current working dir if the source file is not managed by any version control system. (Type ```:help g:vintsearch_searchpathmode``` for more detail) 
5. Note that your ```set tags=...``` setting should have ```./tags;,tags;``` to use the generated tag file. (The name of the tag file can be changed by setting ```g:vintsearch_tagfilename```)
6. Move the cursor to one of the functions or variables. Typing **:VIntSearchGrepCursor n l** or **:VIntSearchCtagsCursor n l** will give search results in the quickfix window. Typing **:VIntSearchPrintStack** will show the search stack.

## Search Path / Tag Commands

The *search path* is a directory 1) that is recursively searched by grep, 2) that is the root of the entire source directory tree for which a tag file is generated, and 3) where the tag file is located.
It is determined by **g:vintsearch_searchpathmode**.

**:VIntSearchPrintPath**, **:VSpath**    
Print the current *search path*.

**:VIntSearchBuildTag**, **:VSbtag**    
Build a tag file for the *search path*.

**g:vintsearch_searchpathmode**    
An option to determine the *search path*. Default:'rc'
- 'rc' : *Search path* is the nearest ancestor dir of the current file that contains 
       a repository dir. 
       If there is no repository dir, *search path* is the current workig dir.
- 'rf' : *Search path* is the nearest ancestor dir of the current file that contains 
       a repository dir. 
       If there is no repository dir, *search path* is the current file dir.
- 'c' : *Search path* is the current working dir.

## Search Commands

**:VIntSearchCtags** [keyword], **:VSctags** [keyword]  
Search for [keyword] by ctags.

**:VIntSearchGrep** [keyword] [grep_options], **:VSgrep** [keyword] [grep_options]  
Search for [keyword] by grep with [grep_options]. [keyword] can be double-quoted and the argument order can be changed.  
For example:
```
:VSgrep tags
:VSgrep "let tags"
:VSgrep tags -i
:VSgrep -i tags
:VSgrep "let tags" -i
```
(See ```man grep``` for more details about [grep_options])

**:VIntSearchCFGrep** [keyword] [grep_options], **:VScfgrep** [keyword] [grep_options]  
Search for [keyword] by grep with [grep_options] in the current file.

**:VIntSearchCtagsCursor** [vimmode] [action]  
Search for *keyword* under the cursor by ctags.

[vimmode] can be one of:  
- 'n' : Use this if vim is in *normal mode*. Then *keyword* is the word under the cursor.  
- 'v' : Use this if vim is in *visual mode*. Then *keyword* is the visually selected text.

[action] can be one of:  
- 'l' : List search result in the quickfix window and open the quickfix window.
- 'j' : Jump to the first search result. The quickfix window is also updated but not opened.

**:VIntSearchGrepCursor** [vimmode] [action]  
Search for *keyword* under the cursor by grep.

**:VIntSearchCFGrepCursor** [vimmode] [action]  
Search for *keyword* under the cursor by grep in the current file.

## Stack Commands

*Search stack* contains your search history - search keywords you jumped to, from which file, and search results in the quickfix window also. You can browse your source code more easily by moving forward and backward in the *search stack*.

**:VIntSearchPrintStack**, **:VSstack**  
Print current *search stack*.

**:VIntSearchMoveBackward**, **:VSbwd**  
Move backward in the *search stack*.

**:VIntSearchMoveForward**, **:VSfwd**  
Move forward in the *search stack*.

**:VIntSearchClearStack**, **:VSclear**  
Clear the *search stack*.

**:VScc**  
**:VScnext**  
**:VScprev**  
Replacement of vim's ```:cc```, ```:cnext```, and ```:cprev```.
Jumping to a new quickFix item should be done ONLY using these commands. 
If not, the jump will not be reflected in VIntSearch's search stack. 
- If you're using any key mapings for ```:cnext``` or ```:cprev```, you can just replace them with **:VScnext** and **:VScprev**. 
- When you press ```Enter``` or ```Double-click``` on a quickfix item, VIntSearch will automatically call **:VScc** instead of vim's ```:cc``` command.

## Key Mappings

VIntSearch does not provide default key mappings to keep your key mappings clean. Instead, I suggest convenient one what I'm using now. You can add them to your .vimrc and modify them as you want.

```
function! s:nnoreicmap(option, shortcut, command)
    execute 'nnoremap '.a:option.' '.a:shortcut.' '.a:command
    execute 'imap '.a:option.' '.a:shortcut.' <Esc>'.a:shortcut
    execute 'cmap '.a:option.' '.a:shortcut.' <Esc>'.a:shortcut
endfunction

" VIntSearch
call s:nnoreicmap('','<A-t>',':VIntSearchMoveBackward<CR>')
call s:nnoreicmap('','<A-T>',':VIntSearchMoveForward<CR>')

call s:nnoreicmap('','<A-]>',':VIntSearchCtagsCursor n j<CR>')
call s:nnoreicmap('','g]',':VIntSearchCtagsCursor n l<CR>')
call s:nnoreicmap('','g\',':VIntSearchGrepCursor n l<CR><CR>')
vnoremap <A-]> :<C-u>VIntSearchCtagsCursor v j<CR>
vnoremap g] :<C-u>VIntSearchCtagsCursor v l<CR>
vnoremap g\ :<C-u>VIntSearchGrepCursor v l<CR><CR>

call s:nnoreicmap('','g\|',':VIntSearchCFGrepCursor n l<CR><CR>')
vnoremap g\| :<C-u>VIntSearchCFGrepCursor v l<CR><CR>

call s:nnoreicmap('','<F8>',':VScnext<CR>')
call s:nnoreicmap('','<S-F8>',':VScprev<CR>')
```

I've define the function `s:nnoreicmap()` to map for normal, insert and command-line modes simultaneously, and installed ![vim-fixkey](https://github.com/drmikehenry/vim-fixkey) plugin to use alt-key mappings. `<A-T>` means alt+shift+t.
