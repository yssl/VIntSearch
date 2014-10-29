# VIntSearch

- Search results by ctags
![byctags](https://cloud.githubusercontent.com/assets/5915359/4835401/e4ed8880-5fb6-11e4-9832-6ac4e72e6ec5.png)

- Search results by grep
![bygrep](https://cloud.githubusercontent.com/assets/5915359/4835402/e81a074a-5fb6-11e4-93ef-1c9b2456b0c5.png)

- Integrated search stack
![stack](https://cloud.githubusercontent.com/assets/5915359/4835403/e9c0bde6-5fb6-11e4-9176-5fe45093ed9f.png)

## Features
- Integrated search stack containing results from grep and ctags (similar usage, but more general than vim's tag stack)
- Quickfix-listed search results from ctags (and grep also)
- Various search commands (for word under the cursor, visually selected text, or any text you type)
- Stacking not only search keywords and their position, but also search results in quickfix
- Unified search path for grep and ctags

## Getting Started

If you've not installed ctags,  
build tags

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
