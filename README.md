# VIntSearch

(screenshot - grep)  
(screenshot - ctags)  
(screenshot - search stack)  

## Features
- Unified search stack integrating results from grep and ctags (more general than vim's tag stack)
- Quickfix-listed search results
- Stacking not only search keywords and their position, but also search results in quickfix
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Unified search path for grep and ctags

### Search Path
The search path means,  
- grep - root of all subdirs grep will look into
- ctags - location of tag file including symbols in all subdirs

## Commands
**:VIntSearchPrintPath**, **:VSpath**    
Print current search path.

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

**:VIntSearchListTypeGrep** [keyword] [options]  
**:VSgrep** [keyword] [options]  
Search [keyword] by grep with grep options [options]. Search results are updated in quickfix.

**:VIntSearchListTypeCtags**  
**:VSctags**  
Search [keyword] by ctags. Search results are updated in quickfix.

## Motivation
