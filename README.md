# Vim-Vimflowy
## Overview 
[Vimflowy](https://github.com/WuTheFWasThat/vimflowy) is a fantastic tool, but requires working in a browser. 

The Vim-Vimflowy plugin mimics the basic zoom in/out behavior of Vimflowy, while *also* allowing you to use your custom vim shortcuts/plugins/setup. 

At any point during editing -- no matter how far zoomed in/out -- you can type `:w`or `ZZ` to save the entire document. For now, `vi [mydocument.txt]` will reopen the document at the highest level.

### Usage 
- `]` will focus on a block (current line and any subsequent lines with indentation > current line)
- `[` will return to parent.

Saving at any focus level will save the entire document safely. 

### Caveats
Saving works at any level...but vim unwraps the entire document and *then* saves it to your file. This can be expensive for large files.


## Installation
- Option 1: 
Plug 'mbbrodie/vim-vimflowy' 
(using your preferred plugin manager)
- Option 2:
Download and place plugin/vimflowy.vim in ~/.vim/plugins/vimflowy.vim

### Optional Filepath stack
I prefer small files and tend to use `gf` to navigate to other files containing similar vimflowy-like structure.
Place the code block below in your `~/.vimrc` to allow the following shortcuts:
- `<leader>g` to goto a file
- `<leader>b` to 'pop' off and go to the most recent previous file
- `<leader>f` to go forward again (after going back)

(You can attain similar behavior with <C-o> and <C-S-^>, but I find these helpful for jumping between files).

```
let g:filestack = []
let g:redofilestack = []
function! GoFile()
    let g:filestack = add(g:filestack, expand('%:p'))
    execute 'e <cfile>'
endfunction
function! BackFile()
    if len(g:filestack) > 0 
        let b:tmpfile = remove(g:filestack, -1) 
        let g:redofilestack = add(g:redofilestack, expand('%:p'))
        execute 'e ' . b:tmpfile 
    endif
endfunction
function! ForwardFile()
    if len(g:redofilestack) > 0 
        let b:tmpfile = remove(g:redofilestack, -1) 
        let g:filestack = add(g:filestack, expand('%:p'))
        execute 'e ' . b:tmpfile
    endif
endfunction
map <leader>g :call GoFile()<CR>
map <leader>b :call BackFile()<CR>
map <leader>f :call ForwardFile()<CR>
```

### Optional Folding
Vim + online plugins provide a wide range of useful folding options. I use this particular setup because it 'kind of' feels like Vimflowy. 

Paste the following in your `~/.vimrc`
```
set foldmethod=indent
set foldlevelstart=99
nnoremap <space> j za k 
```

Given the following:
```
  1 Secret Recipe
  2     Ingredients      " ASSUME YOUR CURSOR IS ON THIS LINE
  3         Chocolate
  4         Butter
  5         Love
  6     Steps
  7         Mix
  8         Cook
  9         Eat
```
Pressing spacebar will fold as such

```
  1 Secret Recipe
  2     Ingredients
  3 +---  3 lines: Chocolate----------------------------------------------------------------------------------------------------------------------
  6     Steps
  7         Mix
  8         Cook
  9         Eat
```
Press spacebar again on line 2 to unfold the Ingredients


## Acknowledgments
`https://github.com/jkramer/vim-narrow` for the starting code for the Narrow() and Widen() functions. Modifications/extensions to the original code are listed in CHANGES.
