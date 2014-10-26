# VIntSearch

(screenshot - grep)  
(screenshot - ctags)  
(screenshot - search stack)  

## Features
- Unified search stack containing results from grep and ctags (similar usage, but more general than vim's tag stack)
- Quickfix-listed search results from ctags (and grep also)
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Stacking not only search keywords and their position, but also search results in quickfix
- Unified search path for grep and ctags

## Getting Started

If you've not installed ctags,  
build tags

## Commands

### Search Directory
The search path means,  
- grep - root of all subdirs grep will look into
- ctags - location of tag file including symbols in all subdirs

**:VIntSearchPrintPath**, **:VSpath**    
Print current search path.

### Searching

**:VIntSearchListCursorGrep**  
**:VIntSearchListCursorCtags**  
Search a word under the cursor in current search path recursively by grep or ctags. Search results are updated in quickfix.

**:VIntSearchJumpCursorGrep**  
**:VIntSearchJumpCursorCtags**  
Search a word under the cursor in current search path recursively by grep or ctags. Search results are updated in quickfix and the cursor jumps to the first result.

**:VIntSearchListSelectionGrep**  
**:VIntSearchListSelectionCtags**  
Search visually selected text in current search path recursively by grep or ctags. Search results are updated in quickfix.

**:VIntSearchJumpSelectionGrep**  
**:VIntSearchJumpSelectionCtags**  
Search visually selected text in current search path recursively by grep or ctags. Search results are updated in quickfix and the cursor jumps to the first result.

**:VIntSearchListTypeGrep** [keyword] [options], **:VSgrep** [keyword] [options]  
Search [keyword] by grep with grep options [options]. Search results are updated in quickfix.

**:VIntSearchListTypeCtags**, **:VSctags**  
Search [keyword] by ctags. Search results are updated in quickfix.

### Search Stack

**:VIntSearchMoveBackward**, **:VSbwd**  

**:VIntSearchMoveForward**, **:VSfwd**  

**:VIntSearchClearStack**, **:VSclear**  

**:VIntSearchPrintStack**, **:VSstack**  

**:VScnext**
**:VScprev**

## Motivation

## Key Mappings
