# VIntSearch

VIntSearch provides a unified interface for symbols or text search in vim.
It supports two search methods (i.e. ctags and grep) and shows results in an integrated way as its name indicates (VIntSearch - Vi Integrated Search).

## Features
- Quickfix-listed search results from ctags (and grep also)
- Easier commands for grep search
- Unified search stack containing results from grep and ctags (similar usage to vim's tag stack, but more general stack)
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Stacking not only search keywords and their position, but also search results in quickfix
- Unified search path for grep and ctags

## Screenshots
- Search results by ctags
![byctags](https://cloud.githubusercontent.com/assets/5915359/4852495/903a342a-607c-11e4-8b01-a4dde78d9492.png)

- Search results by grep
![bygrep](https://cloud.githubusercontent.com/assets/5915359/4852496/907e4ea8-607c-11e4-9c50-e25a8770aad8.png)

- Unified search stack
![stack](https://cloud.githubusercontent.com/assets/5915359/4852497/9085b67a-607c-11e4-8300-1928ecb5d850.png)

## Getting Started

1. You need Exuberant Ctags to fully use this plugin. If you don't have it, please install it first.
2. Install this plugin.
3. Open one of your source files with vim.
4. Build a tag file by typing **:VIntSearchBuildTag**. The tag file will be created in the nearest ancestor dir that contains a repository dir such as ```.git```, or in the current working dir if the source file is not managed by any version control system. A notification message will be given. (Type ```:help g:vintsearch_searchpathmode``` for more detail) 
5. Note that your ```set tags=...``` setting should have ```./tags;``` to use the generated tag file. (The name of the tag file can be changed by setting ```g:vintsearch_tagfilename```)
6. Move the cursor to one of functions or variables. Typing **:VIntSearchListCursorGrep** or **:VIntSearchListCursorCtags** will give search results in the quickfix window. Typing **:VIntSearchPrintStack** will show the search stack.


## Commands

### Search Path
*Search path* means,  
- grep - root of all subdirs grep will look into
- ctags - location of tag file including symbols in all subdirs

**:VIntSearchPrintPath**, **:VSpath**    
Print current search path.

### Search

All search commands search the *search path* and its sub-directories and search results are updated in quickfix.

**:VIntSearchListCursorGrep**  
**:VIntSearchListCursorCtags**  
Search a word under the cursor by grep or ctags.

**:VIntSearchJumpCursorGrep**  
**:VIntSearchJumpCursorCtags**  
Search a word under the cursor by grep or ctags and the cursor jumps to the first result.

**:VIntSearchListSelectionGrep**  
**:VIntSearchListSelectionCtags**  
Search visually selected text by grep or ctags.

**:VIntSearchJumpSelectionGrep**  
**:VIntSearchJumpSelectionCtags**  
Search visually selected text by grep or ctags and the cursor jumps to the first result.

**:VIntSearchListTypeGrep** [keyword] [options], **:VSgrep** [keyword] [options]  
Search [keyword] by grep with grep options [options].

**:VIntSearchListTypeCtags**, **:VSctags**  
Search [keyword] by ctags.

### Search Stack

**:VIntSearchMoveBackward**, **:VSbwd**  

**:VIntSearchMoveForward**, **:VSfwd**  

**:VIntSearchClearStack**, **:VSclear**  

**:VIntSearchPrintStack**, **:VSstack**  

**:VScnext**
**:VScprev**

## Motivation

## Key Mappings
