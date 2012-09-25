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
if !exists("g:totalminifier_configdir")
    let g:totalminifier_configdir = $HOME.'/.totalminifier/'
endif

if !isdirectory(g:totalminifier_configdir)
    call mkdir(g:totalminifier_configdir)
    call system('cp '.g:totalminifier_templatedir.'* '.g:totalminifier_configdir)
endif

command! -nargs=* TotalMinifier call totalminifier#Minifier(<f-args>)
command! TotalMinifierCreate call totalminifier#Create()

let &cpo = s:save_cpo
