" in plugin/regvim.vim
if exists('g:loaded_regvim') | finish | endif " prevent loading file twice

let s:save_cpo = &cpo " save user coptions
set cpo&vim " reset them to defaults

" Highlight groups for RegVim
hi def link RegVimHighlight Special

" Commands for RegVim
command! RegVim lua require'regvim'.toggle()
command! RegVimEnable lua require'regvim'.enable()
command! RegVimDisable lua require'regvim'.disable()
command! RegVimSetup lua require'regvim'.setup()

" Auto-setup RegVim on load (can be disabled with let g:regvim_auto_setup = 0)
if get(g:, 'regvim_auto_setup', 1)
  autocmd VimEnter * ++once lua require'regvim'.setup()
endif

let &cpo = s:save_cpo " and restore after
unlet s:save_cpo

let g:loaded_regvim = 1
