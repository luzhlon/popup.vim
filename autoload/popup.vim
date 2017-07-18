" =============================================================================
" Filename:     autoload/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/7/18
" =============================================================================

let s:Names = {}            " Names of top menus
let s:Menus = {}            " Table of top menus
let s:last  = ''            " The last command user selected
let s:stack = []            " The stack of multi-storey menu(submenu)

" Add menu: submenu, [key, command, description]
fun! popup#add(key, name, ...)
    if !a:0|return|endif
    let s:Names[a:key] = a:name
    let s:Menus[a:key] =
          \ type(a:1[0])==3 ? a:1 : copy(a:000)
endf
" Add menu for current buffer
fun! popup#addl(key, name, ...)
    if !a:0|return|endif
    if !exists('b:BufMenus')
        let b:BufMenus = {}
    endif
    let s:Names[a:key] = a:name
    let b:BufMenus[a:key] =
          \ type(a:1[0])==3 ? a:1 : copy(a:000)
endf
" Remove a top menu
fun! popup#remove(key)
    call remove(s:Names, a:key)
    call remove(s:Menus, a:key)
endf
" The last menu-item user selected
fun! popup#last()
    return s:last
endf
" Combine the top menu and the buffer's menu
fun! s:getmenu(key)
    let m = [] | let bm = []
    if exists('b:BufMenus') && has_key(b:BufMenus, a:key)
        let bm = b:BufMenus[a:key]
    endif
    if has_key(s:Menus, a:key)
        let m = deepcopy(s:Menus[a:key])
        for item in bm
            call s:extendMenu(m, item)
        endfo
    else
        let m = bm
    endif
    return m
endf
"
fun! popup#popup(key)
    let m = s:getmenu(a:key)
    if empty(m) | return | endif
    call s:clearStack()
    call s:enterMenu(s:Names[a:key], m)
    while 1
        let key = s:popup()                 " show the menu's content
        let item = s:findItem(key)
        if empty(item)|break|endif
        let [k, n, C] = item                " key, name, command
        let t = type(C)
        if t == v:t_dict                    " has submenu
            call s:enterMenu(n, C['item'])
        elseif t == v:t_list
            call s:enterMenu(n, C)          " has submenu
        elseif t == v:t_func
            let s:last = C()
            return s:last
        else
            let s:last=C|return C
        endif
    endw
    return ''
endf
" Popup the prompt
fun! s:echoPrompt()
    let [i, l, n] = [0, [], len(s:stack)]
    while i < n
        call add(l, s:stack[i])
        let i += 2
    endw
    let items = s:curMenuItem()         " current menu
    let &ch = len(items) + 1
    " show the navigator in the first line
    echoh Boolean | echon join(l, ' → ') ':'
    " show the menu's items
    for item in items
        let [k, n, C] = item                " key, name, command
        echon "\n"
        echoh Type| echon '  '.n
        let t = type(C)
        if t == 4 || t == 3                 " has submenu
            echoh Underlined   |echon '('.k.")"
            echoh None         |echon "\t\t\t\t"
            echoh Comment      |echon ">"
        else
            echoh Underlined   |echon '('.k.")"
            echoh Include      |echon "\t\t".strtrans(string(C))
        endif
    endfo
    echoh None
endf
" Popup the menu, and return user's input
fun! s:popup()
    "store options
    let [lz, ch, ut] = [&lz, &ch, &ut]
    set nolazyredraw
    set ut=100000000
    " echo prompt for menu
    echo ''
    call s:echoPrompt()
    " get the user's input
    let c = getchar()
    "restore options
    let [&lz, &ch, &ut] = [lz, ch, ut]
    echo ''
    call timer_start(10, {id->execute('redraw')})
    return c
endf
"
fun! s:enterMenu(name, item)
    call add(s:stack, a:name)
    call add(s:stack, a:item)
endf
"
fun! s:clearStack()
    let s:stack = []
endf
" Get current menu
fun! s:curMenuName()
    return s:stack[-2]
endf
fun! s:curMenuItem()
    return s:stack[-1]
endf
" Strip the ALT-key
if has('nvim')
    fun! s:stripAlt(key)
        return type(a:key) != 0 ?
                    \ split(a:key, '.\zs')[-1] : nr2char(a:key)
    endf
else
    fun! s:stripAlt(key)
        return type(a:key) == 0 && a:key > 127 ?
                    \ nr2char(a:key - 128) : nr2char(a:key)
    endf
endif
" Find the item corresponding to key user inputted
fun! s:findItem(key)
    let c = s:stripAlt(a:key)
    for item in s:curMenuItem()
        if item[0] == c
            return item
        endif
    endfo
    return []
endf
" Extend the menu
fun! s:extendMenu(menu, item)
    let items = a:menu
    for i in items
        if i[0] == a:item[0]
            let i[1] = a:item[1]
            let i[2] = a:item[2]
            return
        endif
    endfo
    call add(items, copy(a:item))
endf
