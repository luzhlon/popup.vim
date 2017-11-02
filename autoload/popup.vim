" =============================================================================
" Filename:     autoload/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/8/1
" =============================================================================

let s:last  = ''            " The last command user selected

if !exists('g:popup_menus')
    let g:popup_menus = {}
endif

" The last menu-item user selected
fun! popup#last()
    return s:last
endf

" Combine the buffer's menu and the top menu
fun! popup#get(key)
    let d = 0
    if exists('b:popup_menus') && has_key(b:popup_menus, a:key)
        let d = b:popup_menus
    elseif has_key(g:popup_menus, a:key)
        let d = g:popup_menus
    else
        return
    endif

    let Ret = d[a:key]
    if type(Ret) != v:t_dict
        let Ret = call(Ret, [])
        let d[a:key] = Ret
    endif
    return Ret
endf

" Popup the specific menu by key
fun! popup#(key, ...)
    let m = 0
    if type(a:key) == v:t_dict && type(a:key.popup) == v:t_func
        let m = a:0 ? call(function('pmenu#merge'), [a:key] + a:000): a:key
    elseif type(a:key) == v:t_string
        let m = popup#get(a:key)
    else
        throw 'Wrong argument'
        return ''
    endif

    if empty(m)
        echoe 'Can not find the menu:' a:key
        return ''
    endif

    let l = line('.') | let c = col('.')
    let s:last = m.popup()
    if empty(s:last)
        let s:last = ''
        call timer_start(50, {id->cursor(l,c)})
    endif
    return s:last
endf
