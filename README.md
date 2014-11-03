# VIntSearch

VIntSearch provides a unified interface for symbols or text search in vim.
It supports two search methods (i.e. ctags and grep) and shows results in an integrated way as its name indicates (VIntSearch - Vi Integrated Search).

## Features

- Quickfix-listed results from ctags search
- Easier commands for grep search
- Unified search stack containing search history by grep and ctags (similar usage to vim's tag stack, but more general one)
- Unified search path for grep and ctags
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Stacking not only search keywords and their position, but also search results in Quickfix

## Screenshots

- Search results by ctags
![byctags](https://cloud.githubusercontent.com/assets/5915359/4852495/903a342a-607c-11e4-8b01-a4dde78d9492.png)

- Search results by grep
![bygrep](https://cloud.githubusercontent.com/assets/5915359/4852496/907e4ea8-607c-11e4-9c50-e25a8770aad8.png)

- Unified search stack
![stack](https://cloud.githubusercontent.com/assets/5915359/4852497/9085b67a-607c-11e4-8300-1928ecb5d850.png)

## Installation

- Using plugin managers (recommended)
    - [Vundle](https://github.com/gmarik/Vundle.vim) : Add `Bundle 'yssl/VIntSearch'` to .vimrc & `:BundleInstall`
    - [NeoBundle](https://github.com/Shougo/neobundle.vim) : Add `NeoBundle 'yssl/VIntSearch'` to .vimrc & `:NeoBundleInstall`
    - [vim-plug](https://github.com/junegunn/vim-plug) : Add `Plug 'yssl/VIntSearch'` to .vimrc & `:PlugInstall`
- Using [Pathogen](https://github.com/tpope/vim-pathogen)
    - `cd ~/.vim/bundle; git clone https://github.com/yssl/VIntSearch.git`
- Manual install (not recommended)
    - Download this plugin and extract it in `~/.vim/`

This plugin requires a version of vim with python support. You can check your vim with `:echo has('python')`.
If your vim doesn't support python, one of the easiest solutions would be installing a more featured version of vim by:  
`sudo apt-get install vim-nox`.

## Getting Started

1. You need Exuberant Ctags to fully use this plugin. If you don't have it, please install it first.
2. Install this plugin.
3. Open one of your source files with vim.
4. Build a tag file by typing **:VIntSearchBuildTag**. The tag file will be created in the nearest ancestor dir that contains a repository dir such as ```.git```, or in the current working dir if the source file is not managed by any version control system. (Type ```:help g:vintsearch_searchpathmode``` for more detail) 
5. Note that your ```set tags=...``` setting should have ```./tags;,tags;``` to use the generated tag file. (The name of the tag file can be changed by setting ```g:vintsearch_tagfilename```)
6. Move the cursor to one of the functions or variables. Typing **:VIntSearchListCursorGrep** or **:VIntSearchListCursorCtags** will give search results in Quickfix. Typing **:VIntSearchPrintStack** will show the search stack.

## Search Path

*Search path* is a directory 1) that is recursively searched by grep, 2) that is recursively listed all source files to generate the tag file by **:VIntSearchBuildTag**, and 3) where the tag file is located.

**:VIntSearchPrintPath**, **:VSpath**    
Print current *search path*.

You can check ```:help g:vintsearch_searchpathmode``` to see how the *search path* is determined.

## Search Commands

All following commands search the *search path* recursively. Search results are updated in Quickfix.

**:VIntSearchListCursorGrep**  
**:VIntSearchListCursorCtags**  
Search for a word under the cursor by grep or ctags.

**:VIntSearchJumpCursorGrep**  
**:VIntSearchJumpCursorCtags**  
Search for a word under the cursor by grep or ctags and jump to the first result.

**:VIntSearchListSelectionGrep**  
**:VIntSearchListSelectionCtags**  
Search for visually selected text by grep or ctags.

**:VIntSearchJumpSelectionGrep**  
**:VIntSearchJumpSelectionCtags**  
Search for visually selected text by grep or ctags and jump to the first result.

**:VIntSearchListTypeGrep** [keyword] [options], **:VSgrep** [keyword] [options]  
Search for [keyword] by grep with [options]. (See ```man grep``` for more details about [options])

**:VIntSearchListTypeCtags** [keyword], **:VSctags** [keyword]  
Search for [keyword] by ctags.

## Stack Commands

*Search stack* contains your search history - search keywords you jumped to, from which file, and search results in Quickfix also. You can browse your source code more easily by moving forward and backward in the *search stack*.

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
Replacement of vim's ```:cc```, ```:cnext```, and ```:cprev``` commands for VIntSearch. Jumping to a new position from VIntSearch's Quickfix results can be reflected in the *search stack* ONLY using these commands. If you're using key mapings for ```:cnext``` or ```:cprev```, you can just replace them with these commands. To jump using ```enter``` or ```double-Click``` from the Quickfix results and reflect it in *search stack*, I recommend you to use [QFEnter](http://www.vim.org/scripts/script.php?script_id=4778) plugin and register ```:VScc``` commands by adding ```let g:qfenter_cc_cmd = 'VScc ##'``` in your .vimrc.

## Key Mappings

VIntSearch does not provide default key mappings to keep your key mappings clean. Instead, I suggest convenient one what I'm using now. You can add them to your .vimrc and modify them as you want.

```
function! s:nnoreicmap(option, shortcut, command)
    execute 'nnoremap '.a:option.' '.a:shortcut.' '.a:command
    execute 'imap '.a:option.' '.a:shortcut.' <Esc>'.a:shortcut
    execute 'cmap '.a:option.' '.a:shortcut.' <Esc>'.a:shortcut
endfunction

" VIntSearch
call s:nnoreicmap('','<A-b>',':VIntSearchBuildTag<CR><CR>')
call s:nnoreicmap('','<A-]>',':VIntSearchJumpCursorCtags<CR>')
call s:nnoreicmap('','<A-\>',':VIntSearchJumpCursorGrep<CR><CR>')
call s:nnoreicmap('','<A-g>]',':VIntSearchListCursorCtags<CR>')
call s:nnoreicmap('','<A-g>\',':VIntSearchListCursorGrep<CR><CR>')
call s:nnoreicmap('','<A-t>',':VIntSearchMoveBackward<CR>')
call s:nnoreicmap('','<A-T>',':VIntSearchMoveForward<CR>')
vnoremap <A-]> :<C-u>VIntSearchJumpSelectionCtags<CR>
vnoremap <A-\> :<C-u>VIntSearchJumpSelectionGrep<CR><CR>
vnoremap <A-g>] :<C-u>VIntSearchListSelectionCtags<CR>
vnoremap <A-g>\ :<C-u>VIntSearchListSelectionGrep<CR><CR>
call s:nnoreicmap('','<F8>',':VScnext<CR>')
call s:nnoreicmap('','<S-F8>',':VScprev<CR>')
```

I've define the function `s:nnoreicmap()` to map for normal, insert and command-line modes simultaneously, and installed ![vim-fixkey](https://github.com/drmikehenry/vim-fixkey) plugin to use alt-key mappings. `<A-T>` means alt+shift+t.
