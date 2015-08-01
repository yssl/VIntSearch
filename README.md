# VIntSearch

VIntSearch is a vim plugin providing an integrated interface across various types of searches. It currently supports symbol search, text search, and file search.
Search results are given in the quickfix window and a user can conviniently move forward / backward through the integrated search history.
VIntSearch means **V**im **Int**egrated **Search**.

## Features

- Quickfix-listed search results for all types of searches
- Integrated search stack containing all types of search history (similar to vim's tag stack, but more general one)
- Unified search path for all search types
- Stacking not only search keywords and their position, but also search results in the quickfix
- Search keyword can be a word under the cursor, visually selected text, or any string you type

## Screenshots

- Symbol search
![symbol-search](https://cloud.githubusercontent.com/assets/5915359/9022502/5c6329fe-38b2-11e5-8d36-78cbf380bb3a.png)

- Text search
![text-search](https://cloud.githubusercontent.com/assets/5915359/9022494/468a46e4-38b2-11e5-93f9-5830e9c351da.png)

- File search
![file-search](https://cloud.githubusercontent.com/assets/5915359/9022503/63e29bf6-38b2-11e5-9379-c40285ac3fd1.png)

- Search stack
![search-stack](https://cloud.githubusercontent.com/assets/5915359/9022504/6f103236-38b2-11e5-8e27-2506e8e88f4c.png)

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
4. Build a tag file by typing **:VIntSearchBuildSymbolDB**. The tag file will be created in the nearest ancestor dir that contains a repository dir such as ```.git```, or in the current working dir if the source file is not managed by any version control system (You can change this behavior via ```g:vintsearch_searchpathmode```). 
5. Note that your ```set tags=...``` setting should have ```./tags;,tags;``` to use the generated tag file (The name of the tag file is set by```g:vintsearch_tagfilename```).
6. Move the cursor to one of the functions or variables. Typing **:VIntSearchCursor symbol n l** or **:VIntSearchCursor text n l** will give search results in the quickfix window. Typing **:VIntSearchPrintStack** will show the search stack.

## Search Types / Commands

VIntSearch supports symbol search, text search, and file search.
Currently, available search commands for each type of search are as follows:

- Symbol search
	- ctags
- Text search
	- grep
- File search
	- find

You can set the default commands for search types via ```g:vintsearch_symbol_defaultcmd```, ```g:vintsearch_text_defaultcmd```, and ```g:vintsearch_file_defaultcmd```.

## Search Path / Tag Commands

The *search path* is a directory 1) that is recursively searched by grep, 2) that is the root of the entire source directory tree for which a symbol db file is generated, and 3) where the symbol db file is located.
It is determined by **g:vintsearch_searchpathmode**.

**:VIntSearchPrintPath**, **:VSpath**    
Print the current *search path*.

**:VIntSearchBuildSymbolDB**, **:VSbuild**    
Build a symbol db file for the *search path*.

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

**:VSsymbol** [keyword]  
Search symbol for [keyword] \(by default using ctags).

**:VStext** [keyword] [options]  
Search text for [keyword] with [options] \(by default using grep, [option] is grep option). [keyword] can be double-quoted and the argument order can be changed.  

**:VSfile** [keyword] [options]  
Search file for [keyword] with [options] \(by default using find). Curently only works with -path options of find command.  

**:VScftext** [keyword] [options]  
Search text for [keyword] with [options] in the current file.

--------------------
**:VIntSearch** [search type] [keyword] [options]  
A search command taking a search type as an argument.

[search type] can be one of:
- symbol
- text
- file
- cftext

For example,
```:VIntSearch text "this is"``` is same to ```:VStext "this is"```.

**:VIntSearchCmd** [search type] [search command] [keyword] [options]  
A search command taking a search type and a search command as arguments. For example,
```:VIntSearchCmd text grep "this is"``` is same to ```:VStext "this is"```
with ```grep``` as the default text search command.

--------------------
**:VIntSearchCursor** [search type] [vimmode] [action]  
Search for *keyword* under the cursor with a specified [search type].

[vimmode] can be one of:  
- 'n' : Use this if vim is in *normal mode*. Then *keyword* is the word under the cursor.  
- 'v' : Use this if vim is in *visual mode*. Then *keyword* is the visually selected text.

[action] can be one of:  
- 'l' : List search result in the quickfix window and open the quickfix window.
- 'j' : Jump to the first search result. The quickfix window is also updated but not opened.

**:VIntSearchCursorCmd** [search type] [search command] [vimmode] [action]  
Search for *keyword* under the cursor with a specified [search type] and a
[search command].

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
call s:nnoreicmap('','<A-3>',':VIntSearchMoveBackward<CR>')
call s:nnoreicmap('','<A-4>',':VIntSearchMoveForward<CR>')

call s:nnoreicmap('','<A-]>',':VIntSearchCursor symbol n j<CR>')
call s:nnoreicmap('','g]',':VIntSearchCursor symbol n l<CR>')
call s:nnoreicmap('','g[',':VIntSearchCursor text n l<CR><CR>')
call s:nnoreicmap('','g{',':VIntSearchCursor cftext n l<CR><CR>')
call s:nnoreicmap('','g\',':VIntSearchCursor file n l<CR><CR>')
vnoremap <A-]> :<C-u>VIntSearchCursor symbol v j<CR>
vnoremap g] :<C-u>VIntSearchCursor symbol v l<CR>
vnoremap g[ :<C-u>VIntSearchCursor text v l<CR><CR>
vnoremap g{ :<C-u>VIntSearchCursor cftext v l<CR><CR>
vnoremap g\ :<C-u>VIntSearchCursor file v l<CR><CR>

call s:nnoreicmap('','<F8>',':VScnext<CR>')
call s:nnoreicmap('','<S-F8>',':VScprev<CR>')
```

`s:nnoreicmap()` is a function to register mappings for normal, insert and command-line modes simultaneously. I installed ![vim-fixkey](https://github.com/drmikehenry/vim-fixkey) to use alt-key mappings.
