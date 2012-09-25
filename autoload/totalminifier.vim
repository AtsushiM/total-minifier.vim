"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/total-minifier.vim
"VERSION:  0.9
"LICENSE:  MIT

let s:save_cpo = &cpo
set cpo&vim

function! totalminifier#Create()
    if !filereadable(g:totalminifier_config)
        if filereadable(g:totalminifier_templatedir.g:totalminifier_config)
            call writefile(readfile(g:totalminifier_templatedir.g:totalminifier_config), g:totalminifier_config)
        else
            call writefile([], g:totalminifier_config)
        endif
        exec 'e '.g:totalminifier_config
    endif
endfunction

function! totalminifier#configDir(target)
    let i = 0
    let dir = expand('%:p:h').'/'
    let flg = 0

    while i < 10
        if !filereadable(dir.'/'.a:target)
            let dir = dir.'../'
        else
            let flg = 1
            break
        endif

        let i = i + 1
    endwhile

    if flg == 0
        let dir = ''
    else
        let dir = fnamemodify(dir, ':p')
    endif

    return dir
endfunction

function! totalminifier#Minifier()
    let orgdir = getcwd()
    let confdir = totalminifier#configDir('TotalMinifier')
    let config = readfile(confdir.'TotalMinifier')

    exec 'cd '.confdir

    let deploy_dir = '../deploy'
    let use_growlnotify = 0
    let before_reset = 1
    let binary_rename = 0
    let remove_svn = 1
    let html = 'index.html'
    let html_nullprop = 0
    let css = 'css/screen.css'
    let img = 'imgs'
    let js = 'js'

    let line = []
    let key = ''
    let value = ''
    for i in config
        let line = matchlist(i, '\v^#(.*)')

        if line != []
            continue
        endif

        let line = matchlist(i, '\v( *)(.{-})( *)(:)( *)(.*)')

        if line == []
            continue
        endif

        let key = line[2]
        let value = line[6]

        if key == 'deploy_dir'
            let deploy_dir = value
        elseif key == 'use_growlnotify'
            let use_growlnotify = value
        elseif key == 'before_reset'
            let before_reset = value
        elseif key == 'binary_rename'
            let binary_rename = value
        elseif key == 'remove_svn'
            let remove_svn = value
        elseif key == 'html'
            let html = value
        elseif key == 'html_nullprop'
            let html_nullprop = value
        elseif key == 'css'
            let css = value
        elseif key == 'img'
            let img = value
        elseif key == 'js'
            let js = value
        endif
    endfor

    call totalminifier#Growl(use_growlnotify, 'TotalMinifier start.')
    let deploy_dir = totalminifier#DeployDir(deploy_dir)
    call totalminifier#BeforeReset(before_reset, deploy_dir)

    call totalminifier#Img(deploy_dir, img)

    call totalminifier#JS(deploy_dir, js)

    call totalminifier#HTMLMinifier(deploy_dir, html, html_nullprop)

    call totalminifier#CSSMinifier(deploy_dir, css)

    call totalminifier#RemoveSVN(remove_svn, deploy_dir.'/'.img)

    call totalminifier#Growl(use_growlnotify, 'TotalMinifier complete.')

    exec 'cd '.orgdir
endfunction

function! totalminifier#Growl(flg, txt)
    if a:flg == 1
        call system("growlnotify -t 'TotalMinifier' -m '".a:txt."'")
    endif
endfunction

function!totalminifier#DeployDir(dir)
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p')
    endif

    return fnamemodify(a:dir, ':p')
endfunction

function! totalminifier#RemoveSVN(flg, dir)
    if a:flg == 1
        call system('find '.a:dir.' -name ".svn" -exec rm -rf {} ";"')
    endif
endfunction

function! totalminifier#BeforeReset(flg, dir)
    if a:flg == 1
        call system('rm -r '.a:dir.'/*')
    endif
endfunction

function! totalminifier#Img(dir, img_dir)
    let dir = a:dir
    let img_dir = a:img_dir

    call system('cp -r -f '.img_dir.' '.dir.'/'.img_dir)
endfunction

function! totalminifier#JS(dir, path)
    let dir = a:dir
    let path = split(a:path, ' ')
    let parent = ''

    for i in path
        let parent = fnamemodify(dir.'/'.i, ':h')
        if !isdirectory(parent)
            call mkdir(parent, 'p')
        endif

        call system('cp -r -f '.i.' '.dir.'/'.i)
    endfor
endfunction

function! totalminifier#HTMLMinifier(dir, path, nullprop)
    let dir = a:dir
    let path = split(a:path, ' ')
    let nullprop = a:nullprop

    for i in path
        exec 'HTMLMinifier -input='.i.' -output='.dir.'/'.i.' -deletenullprop='.nullprop
    endfor
endfunction

function! totalminifier#CSSMinifier(dir, path)
    let dir = a:dir
    let path = split(a:path, ' ')

    for i in path
        exec 'CSSMinifier -input='.i.' -output='.dir.'/'.i
    endfor
endfunction

let &cpo = s:save_cpo
