" =============================================================================
" Filename:     autoload/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/8/1
" =============================================================================

let g:popup.menus = {}
let g:popup.ftmenus = {}
let g:popup.last = ['', '']

let s:menus = g:popup.menus
let s:ftmenus = g:popup.ftmenus

if !exists('g:popup_menus')
    let g:popup_menus = {}
endif

" The last menu-item user selected
fun! popup#last()
    let [cmd, flag] = g:popup.last
    " echom cmd flag
    if flag == ':'
        call timer_start(1, {->execute(cmd)})
        return s:nop()
    else
        call feedkeys(cmd, flag == '!' ? 'n': '')
        return ''
    endif
endf

" Combine the buffer's menu and the top menu
fun! popup#get(key)
    let M = 0
    if exists('b:popup_menus') && has_key(b:popup_menus, a:key)
        let M = b:popup_menus[a:key].copy()
    endif

    if has_key(s:ftmenus, &ft) && has_key(s:ftmenus[&ft], a:key)
        let m = s:ftmenus[&ft][a:key]
        let M = empty(M) ? m.copy() : M.merge(m)
    endif

    if has_key(s:menus, a:key)
        let m = s:menus[a:key]
        let M = empty(M) ? m.copy() : M.merge(m)
    endif

    return M
endf

fun! s:nop()
    let ch = "\<F12>"
    if mode() =~ '[Ric].\?'
        let ch = "\<c-r>\<esc>"
    elseif mode() =~ 'n.\?'
        let ch = "\<ESC>"
    endif
    call feedkeys(ch, 'n') | return ''
endf

fun! s:load(key)
    let name = split(a:key, '#')[0]
    exe 'runtime' 'pmenu/'.name.'.vim'
endf

" Popup the specific menu by key
fun! popup#(key, ...)
    let M = popup#get(a:key)
    if empty(M) | call s:load(a:key) | endif
    let M = popup#get(a:key)

    if empty(M)
        echoe 'Can not find popup menu:' a:key
        return s:nop()
    endif

    let last = M.popup()
    if empty(last)
        return s:nop()
    else
        let g:popup.last = last
        return popup#last()
    endif
endf

fun! popup#reg(key, menu, ...) abort
    call s:checkmenu(a:menu)
    if a:0
        let ft = a:1
        if !has_key(s:ftmenus, ft)
            let s:ftmenus[ft] = {}
        endif
        let s:ftmenus[ft][a:key] = a:menu
        if !has_key(s:menus, a:key)
            call s:load(a:key)
        endif
    else
        let s:menus[a:key] = a:menu
    endif
endf

fun! s:checkmenu(menu) abort
    call assert_true(type(a:menu) == v:t_dict
                \ && has_key(a:menu, 'popup'),
                \ 'Not a valid menu')
endf

fun! popup#menus(...)
    if a:0
        return get(g:popup.ftmenus, a:1, {})
    else
        return g:popup.menus
    endif
endf
