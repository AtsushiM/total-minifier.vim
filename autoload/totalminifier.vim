"AUTHOR:   Atsushi Mizoue <asionfb@gmail.com>
"WEBSITE:  https://github.com/AtsushiM/total-minifier.vim
"VERSION:  0.9
"LICENSE:  MIT

let s:save_cpo = &cpo
set cpo&vim

let s:alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

function! totalminifier#Edit()
    let dir = totalminifier#configDir(g:totalminifier_config)
    if dir != ''
        exec 'e '.dir.'/'.g:totalminifier_config
    endif
endfunction

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
    let html_removedebug = 1
    let html_setdeploy = 1
    let class_rename = 0
    let class_rename_ignore = ''
    let id_rename = 0
    let id_rename_ignore = ''
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
        elseif key == 'class_rename'
            let class_rename = value
        elseif key == 'class_rename_ignore'
            let class_rename_ignore = value
        elseif key == 'id_rename'
            let id_rename = value
        elseif key == 'id_rename_ignore'
            let id_rename_ignore = value
        elseif key == 'remove_svn'
            let remove_svn = value
        elseif key == 'html'
            let html = value
        elseif key == 'html_nullprop'
            let html_nullprop = value
        elseif key == 'html_removedebug'
            let html_removedebug = value
        elseif key == 'html_setdeploy'
            let html_setdeploy = value
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

    call totalminifier#HTMLMinifier(deploy_dir, html, html_nullprop, html_removedebug, html_setdeploy)

    call totalminifier#CSSMinifier(deploy_dir, css)

    call totalminifier#RemoveSVN(remove_svn, deploy_dir.'/'.img)

    call totalminifier#ClassRename(class_rename, class_rename_ignore, deploy_dir, html, css)

    call totalminifier#IDRename(id_rename, id_rename_ignore, deploy_dir, html, css)

    call totalminifier#Growl(use_growlnotify, 'TotalMinifier complete.')

    exec 'cd '.orgdir
endfunction

function! totalminifier#ClassRename(flg, ignore, dir, html, css)
    call totalminifier#ClassIDRename(a:flg, a:ignore, a:dir, a:html, a:css, 'class')
endfunction
function! totalminifier#IDRename(flg, ignore, dir, html, css)
    let ignore = a:ignore.' [0-9a-fA-F]{3}'.' [0-9a-fA-F]{6}'
    call totalminifier#ClassIDRename(a:flg, ignore, a:dir, a:html, a:css, 'id')
endfunction
function! totalminifier#ClassIDRename(flg, ignore, dir, html, css, mode)
    if a:flg != 1
        return
    endif

    let match_ignore = '\v^('.join(split(a:ignore, ' '), '|').')$'
    let dir = a:dir.'/'
    let htmls = split(a:html, ' ')
    let csss = split(a:css, ' ')
    let mode_html = a:mode
    let mode_css = '.'

    if mode_html == 'id'
        let mode_css = '#'
    endif

    let match_html = '\v(.{-})'.mode_html.'\="(.{-})"(.*)'

    let match_css = '\v(.{-})'
    if mode_css == '.'
        let match_css = match_css.'\'
    endif

    let match_css = match_css.mode_css.'([a-zA-Z]+[a-zA-Z0-9\-_]*)(.*)'

    let file = []
    let flg = 0
    let cls = []
    let clscnt = {}

    for i in htmls
        let file = readfile(dir.'/'.i)

        for f in file
            let flg = 0
            while flg == 0
                let cls = matchlist(f, match_html)

                if cls == []
                    let flg = 1
                    continue
                endif

                let f = cls[3]

                let cls = split(cls[2], ' ')

                for c in cls

                    if matchlist(c, match_ignore) != []
                        continue
                    endif

                    if !exists('clscnt["'.c.'"]')
                        let clscnt[c] = 0
                    endif

                    let clscnt[c] = clscnt[c] + 1
                endfor
            endwhile
        endfor
    endfor

    for i in csss
        let file = readfile(dir.'/'.i)

        for f in file
            let flg = 0
            while flg == 0
                let cls = matchlist(f, match_css)

                if cls == []
                    let flg = 1
                    continue
                endif

                let f = cls[3]

                let cls = split(cls[2], ' ')

                for c in cls

                    if matchlist(c, match_ignore) != []
                        continue
                    endif

                    if !exists('clscnt["'.c.'"]')
                        let clscnt[c] = 0
                    endif

                    let clscnt[c] = clscnt[c] + 1
                endfor
            endwhile
        endfor
    endfor

    let clsary = sort(items(clscnt), 'totalminifier#sortComp')
    let clslen = len(clsary)
    let clspoint = 0
    let clsinput = ''
    let clsalphapoint = 0
    let clstailcount = 0
    let clstaildigit = 0

    while clspoint < clslen
        if clspoint < 26
            let clsinput = s:alphabet[clspoint]
        else
            let clsinput = s:alphabet[clsalphapoint].(clstaildigit * 10 + clstailcount)
            let clstailcount = clstailcount + 1

            if clstailcount > 9
                let clstailcount = 0
                let clsalphapoint = clsalphapoint + 1

                if clsalphapoint > 25
                    let clsalphapoint = 0
                    let clstaildigit = clstaildigit + 1
                endif
            endif
        endif

        let clscnt[clsary[clspoint][0]] = clsinput
        let clspoint = clspoint + 1
    endwhile

    let filecomphtml = ''
    for i in htmls
        let file = readfile(dir.'/'.i)

        for f in file
            let flg = 0

            while flg == 0
                let cls = matchlist(f, match_html)

                if cls == []
                    let flg = 1
                    let filecomphtml = filecomphtml.f
                    continue
                endif

                let filecomphtml = filecomphtml.cls[1].mode_html.'="'

                let f = cls[3]

                let cls = split(cls[2], ' ')
                let clsbeforechar = ''

                for c in cls
                    let filecomphtml = filecomphtml.clsbeforechar
                    if matchlist(c, match_ignore) == []
                        let filecomphtml = filecomphtml.clscnt[c]
                    else
                        let filecomphtml = filecomphtml.c
                    endif
                    let clsbeforechar = ' '
                endfor

                let filecomphtml = filecomphtml.'"'
            endwhile
        endfor

        call writefile([filecomphtml], dir.'/'.i, 'b')
    endfor

    let filecompcss = ''
    for i in csss
        let file = readfile(dir.'/'.i)

        for f in file
            let flg = 0

            while flg == 0
                let cls = matchlist(f, match_css)

                if cls == []
                    let flg = 1
                    let filecompcss = filecompcss.f
                    continue
                endif

                let f = cls[3]

                let filecompcss = filecompcss.cls[1].mode_css
                if matchlist(cls[2], match_ignore) == []
                    let filecompcss = filecompcss.clscnt[cls[2]]
                else
                    let filecompcss = filecompcss.cls[2]
                endif
            endwhile
        endfor

        call writefile([filecompcss], dir.'/'.i, 'b')
    endfor
endfunction

function! totalminifier#sortComp(i1, i2)
    let i1v = a:i1[1]
    let i2v = a:i2[1]

    if i1v == i2v
        return 0
    elseif i1v > i2v
        return 1
    else
        return -1
    endif
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

    call system('cp -f '.img_dir.' '.dir.'/'.img_dir)
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

function! totalminifier#HTMLMinifier(dir, path, nullprop, removedebug, setdeploy)
    let dir = a:dir
    let path = split(a:path, ' ')
    let nullprop = a:nullprop

    for i in path
        exec 'HTMLMinifier -input='.i.' -output='.dir.'/'.i.' -deletenullprop='.nullprop.' -removedebug='.a:removedebug.' -setdeploy='.a:setdeploy
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
