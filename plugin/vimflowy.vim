" vimflowy.vim
" Mike Brodie
"
" ****************************************************************************
" ORIGINAL LICENSE
" File:             narrow.vim
" Author:           Jonas Kramer
" Version:          0.1
" Last Modified:    2008-11-17
" Copyright:        Copyright (C) 2008 by Jonas Kramer. Published under the
"                   terms of the Artistic License 2.0.
" ****************************************************************************
" Installation: Copy this script into your plugin folder.
" Usage: Call the command :Narrow with a range to zoom into the range area.
" Call :Widen to zoom out again.
" WARNING! Be careful when doing undo operations in a narrowed buffer. If you
" undo the :Narrow action, :Widen will fail miserable and you'll probably have
" the hidden parts doubled in your buffer. The 'u' key is remapped to a save
" undo function, but you can still mess this plugin up with :earlier, g- etc.
" Also make sure that you don't mess with the buffers autocmd BufWriteCmd
" hook, as it is set to a function that allows saving of the whole buffer
" instead of only the narrowed region in narrowed mode. Otherwise, when saving
" in a narrowed buffer, only the region you zoomed into would be saved.
" ****************************************************************************

if exists('g:loadedNarrow')
	finish
endif

let s:savedOptions = &cpoptions
let g:narrowedBuffers = []
set cpoptions&vim


fu! vimflowy#Narrow(rb, re)
	
	" Save modified state.
	let modified = &l:modified

	let narrowData = { "pre": [], "post": [] }


	" Store buffer contents and remove everything outside the range.
	if a:re < line("$")
		let narrowData["post"] = getline(a:re + 1, "$")
		exe "silent " . (a:re + 1) . ",$d _"
	end

	if a:rb > 1
		let narrowData["pre"] = getline(1, a:rb - 1)
		exe "silent 1," . (a:rb - 1) . "d _"
	end
	let g:narrowedBuffers = add(g:narrowedBuffers, narrowData)

	let narrowData["change"] = changenr()

	augroup plugin-narrow
		au BufWriteCmd <buffer> call vimflowy#Save()
	augroup END

	" If buffer wasn't modified, unset modified flag.
	if !modified
		setlocal nomodified
	en

	echo "Narrowed. Be careful with undo/time travelling."

endf


fu! vimflowy#Widen()
	if len(g:narrowedBuffers) > 0
		" Save modified state.
		let modified = &l:modified

		" Save position.
		let pos = getpos(".")
		let b:narrowData = remove(g:narrowedBuffers, -1)

		" Calculate cursor position based of the length of the inserted
		" content, so the cursor doesn't move when widening.
		let pos[1] = pos[1] + len(b:narrowData["pre"])

		call append(0, b:narrowData["pre"])
		call append(line('$'), b:narrowData["post"])

		" Restore save command.
		augroup plugin-narrow
			au! BufWriteCmd <buffer>
		augroup END

		" If buffer wasn't modified, unset modified flag.
		if !modified
			setlocal nomodified
		en

		" Restore cursor position.
		call setpos('.', pos)
		unlet b:narrowData

		echo "Buffer restored."
	else
		echo "No buffer to widen."
	endif
endf


" Function to use instead of Vims builting save command, so we can save the
" whole buffer instead of only the narrowed region in it as Vim would do.
fu! vimflowy#Save()
	let name = bufname("%")

	if exists('g:narrowedBuffers')

		" Calculate cursor position based of the length of the inserted
		" content, so the cursor doesn't move when widening.
		"let pos[1] = pos[1] + len(b:narrowData["pre"])

		"call append(0, b:narrowData["pre"])
		"call append(line('$'), b:narrowData["post"])

		let g:updatedGBuffer = []
		while len(g:narrowedBuffers) > 0
			let b:narrowDataTmp = remove(g:narrowedBuffers, -1)
			let g:updatedGBuffer = add(g:updatedGBuffer,b:narrowDataTmp)
			if len(g:updatedGBuffer) < 1
				let content = copy(b:narrowDataTmp.pre)
				let content = extend(content, copy(getline(1, "$")))
				let content = extend(content, copy(b:narrowDataTmp.post))
			else
				let content = copy(b:narrowDataTmp.pre)
				let content = extend(content, copy(b:narrowDataTmp.post))
			endif
		endwhile
		let g:narrowedBuffers = reverse(g:updatedGBuffer)
		" Write file and hope for the best.
		call writefile(content, name)
		setlocal nomodified

		echo "Whee! I really hope that file is saved now!"
	endif
endf


" Wrapper around :undo to make sure the user doesn't undo the :Narrow command,
" which would break :Widen.
fu! s:safeUndo()
        if exists('b:narrowData')
		let pos = getpos(".")

		silent undo

		if changenr() < b:narrowData["change"]
			silent redo
			echo "I told you to be careful with undo! Widen first."
			call setpos(".", pos)
		en
	else
		undo
	en
endf


command! -bar -range Narrow call vimflowy#Narrow(<line1>, <line2>)
command! -bar Widen call vimflowy#Widen()

silent! nnoremap <silent> u  :<C-u>call <SID>safeUndo()<CR>


let &cpoptions = s:savedOptions
unlet s:savedOptions

let g:loadedNarrow = 1

function SelectIndent()
  let cur_line = line(".")
  let cur_ind = indent(cur_line)
  let line = cur_line
  "while indent(line - 1) >= cur_ind
  "  let line = line - 1
  "endw
  exe "normal " . line . "G"
  exe "normal V"
  let line = cur_line
  while indent(line + 1) > cur_ind
    let line = line + 1
  endw
  exe "normal " . line . "G"
endfunction		
nnoremap vip :call SelectIndent()<CR>

let mapleader = ","
map <leader>M :Widen<CR>
map <leader>m vip <bar> :Narrow<CR>
