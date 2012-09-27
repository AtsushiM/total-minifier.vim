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

let g:totalminifier_plugindir = expand('<sfile>:p:h:h').'/'
let g:totalminifier_templatedir = g:totalminifier_plugindir.'template/'

if !exists("g:totalminifier_cdloop")
    let g:totalminifier_cdloop = 5
endif
if !exists("g:totalminifier_config")
    let g:totalminifier_config = 'TotalMinifier'
endif

command! -nargs=* TotalMinifier call totalminifier#Minifier(<f-args>)
command! TotalMinifierCreate call totalminifier#Create()
command! TotalMinifierEdit call totalminifier#Edit()

let &cpo = s:save_cpo
