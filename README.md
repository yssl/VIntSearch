# VIntSearch

VIntSearch provides a unified interface for symbols or text search in vim.
It supports two search methods (i.e. ctags and grep) and shows results in an integrated way as its name indicates (VIntSearch - Vi Integrated Search).

## Features

- Quickfix-listed results from ctags search
- Easier commands for grep search
- Unified search stack containing results from grep and ctags (similar usage to vim's tag stack, but more general one)
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Stacking not only search keywords and their position, but also search results in Quickfix
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
4. Build a tag file by typing **:VIntSearchBuildTag**. The tag file will be created in the nearest ancestor dir that contains a repository dir such as ```.git```, or in the current working dir if the source file is not managed by any version control system. (Type ```:help g:vintsearch_searchpathmode``` for more detail) 
5. Note that your ```set tags=...``` setting should have ```./tags;,tags;``` to use the generated tag file. (The name of the tag file can be changed by setting ```g:vintsearch_tagfilename```)
6. Move the cursor to one of the functions or variables. Typing **:VIntSearchListCursorGrep** or **:VIntSearchListCursorCtags** will give search results in Quickfix. Typing **:VIntSearchPrintStack** will show the search stack.

## Search Path

*Search path* is a directory 1) that is recursively searched by grep, 2) that is recursively listed all source files to generate the tag file by **:VIntSearchBuildTag**, and 3) where the tag file is located.

**:VIntSearchPrintPath**, **:VSpath**    
Print current search path.

You can check ```:help g:vintsearch_searchpathmode``` to see how the search path is determined.

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
Search for [keyword] by grep with [options] (See ```man grep``` for more details about [options]).

**:VIntSearchListTypeCtags** [keyword], **:VSctags** [keyword]  
Search for [keyword] by ctags.

### Stack Commands

**:VIntSearchMoveBackward**, **:VSbwd**  

**:VIntSearchMoveForward**, **:VSfwd**  

**:VIntSearchClearStack**, **:VSclear**  

**:VIntSearchPrintStack**, **:VSstack**  

**:VScnext**
**:VScprev**

## Motivation

## Key Mappings
