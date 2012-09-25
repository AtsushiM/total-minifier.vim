"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/total-minifier.vim
"VERSION:  0.9
"LICENSE:  MIT

if exists("g:loaded_total_minifier")
    finish
endif
let g:loaded_total_minifier = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* TotalMinifier call totalminifier#Minifier(<f-args>)

let &cpo = s:save_cpo
