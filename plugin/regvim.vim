" plugin/regvim.vim
if exists('g:loaded_regvim') | finish | endif

" Commands
command! RegVim lua require'regvim'.toggle()
command! RegVimEnable lua require'regvim'.enable()
command! RegVimDisable lua require'regvim'.disable()

" Auto-setup
autocmd VimEnter * ++once lua require'regvim'.setup()

let g:loaded_regvim = 1
