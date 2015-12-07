if has('nvim') && !exists("g:vibe_term_mode")
	let g:vibe_term_mode = 'vsplit'
endif

" s:jobs is a global reference to all jobs started with new()
let s:jobs = {}

" new creates a new terminal with the given command. Mode is set based on the
" global variable g:vibe_term_mode, which is by default set to :vsplit
function! vibe#term#run(cmd)
	call vibe#term#run#mode(a:cmd, g:vibe_term_mode)
endfunction

" new creates a new terminal with the given command and window mode.
function! vibe#term#run#mode(cmd, mode)
	let mode = a:mode
	execute mode.' __vibe_term__'

	setlocal filetype=vibeterm
	setlocal bufhidden=delete
	setlocal winfixheight
	setlocal noswapfile
	setlocal nobuflisted

	let job = { 
		\ 'stderr' : [],
		\ 'stdout' : [],
		\ }

	let id = termopen(a:cmd, job)
	let job.id = id
	startinsert

	" resize new term if needed.
	let height = get(g:, 'vibe_term_height', winheight(0))
	let width = get(g:, 'vibe_term_width', winwidth(0))

	" we are careful how to resize. for example it's vertical we don't change
	" the height. The below command resizes the buffer
	if a:mode == "split"
		exe 'resize ' . height
	elseif a:mode == "vertical"
		exe 'vertical resize ' . width
	endif

	" we also need to resize the pty, so there you vibe...
	call jobresize(id, width, height)

	let s:jobs[id] = job
	return id
endfunction

