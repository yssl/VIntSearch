# VIntSearch

## Features
- Integrated search stack (more general than vim's tag stack)
- Quickfix-listed search results
- Stacking not only search keywords and their position, but also search results in quickfix
- Various search commands (for word under the cursor, visually selected text, or any text you type)

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

**:VIntSearchListTypeGrep**, **:VSgrep**  
**:VIntSearchListTypeCtags**, **:VSctags**  

## Motivation
