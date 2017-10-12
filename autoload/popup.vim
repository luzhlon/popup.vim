" =============================================================================
" Filename:     autoload/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/8/1
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
" Combine the buffer's menu and the top menu
fun! s:getmenu(key)
    let m = exists('b:BufMenus') && has_key(b:BufMenus, a:key) ?
                \ copy(b:BufMenus[a:key]) : []
    if has_key(s:Menus, a:key)
        let m += s:Menus[a:key]
    endif
    return m
endf
" Popup the specific menu by key
fun! popup#popup(key)
    let m = s:getmenu(a:key)
    if empty(m) | return | endif
    call s:clearStack()
    call s:enterMenu(s:Names[a:key], m)
    let s:last = ''
    while 1
        let key = s:popup()                 " show the menu's content
        if key == g:popup#upkey
            call s:leaveMenu()
            continue
        endif
        let item = s:findItem(key)
        if empty(item) | break | endif
        let [k, n, C] = item                " key, name, command
        let t = type(C)
        if t == v:t_dict                    " has submenu
            call s:enterMenu(n, C['item'])
        elseif t == v:t_list
            call s:enterMenu(n, C)          " has submenu
        elseif t == v:t_func
            let s:last = C() | break
        else
            let s:last = C | break
        endif
    endw
    if empty(s:last)
        let l = line('.') | let c = col('.')
        call timer_start(5, {id->cursor(l,c)})
    endif
    return s:last
endf
" Popup the menu, and return user's input
fun! s:popup()
    redraw
    "store options
    let [lz, ch, ut] = [&lz, &ch, &ut]
    set nolazyredraw
    set ut=100000000
    " Popup the prompt {{{ "
    let [i, l, n] = [0, [], len(s:stack)]
    while i < n
        call add(l, s:stack[i])
        let i += 2
    endw
    let items = s:curMenu()         " current menu
    let &ch = len(items) + 1
    " count the maximum length of item's names
    let maxnamelen = 0
    for item in items
        let n = strdisplaywidth(item[1])
        let maxnamelen = n > maxnamelen ? n : maxnamelen
    endfo
    " show the navigator in the first line
    echoh Boolean | echon join(l, g:popup#arrow) ':'
    " show the menu's items
    for item in items
        echon "\n"
        if type(item) == v:t_string
            echoh Comment | echon item
            continue
        endif
        let [k, n, C] = item                " key, name, command
        echoh Type
        echon '  ' . n . repeat(' ', maxnamelen - strdisplaywidth(n) + 1)
        echoh Normal | echon '('
        echoh Underlined  | echon printf('%2S', strtrans(k))
        echoh Normal | echon ')'
        let t = type(C)
        if t == v:t_dict || t == v:t_list   " Submenu
            echoh WarningMsg | echon "\t\t>"
        elseif t == v:t_func                " Function
            echoh Include | echon "\t\t" . string(C)
        else                                " Command
            echoh Function | echon "\t\t" . strtrans(C)
        endif
    endfo
    echoh None
    " }}} Popup the prompt "
    " get the user's input
    let c = getchar()
    "restore options
    let [&lz, &ch, &ut] = [lz, ch, ut]
    echo "\r" | redraw
    return type(c) == v:t_number ? nr2char(c) : c
endf
" Enter a menu: push it's name and items to top of stack
fun! s:enterMenu(name, item)
    call add(s:stack, a:name)
    call add(s:stack, a:item)
endf
" Leave a menu: pop the current menu's name and items
fun! s:leaveMenu()
    if len(s:stack) > 2
        call remove(s:stack, -2, -1)
    endif
endf
" Clear the stack used to store the submenus
fun! s:clearStack()
    let s:stack = []
endf
" Get current menu
fun! s:curMenu()
    return s:stack[-1]
endf
" Strip the ALT-key
if has('nvim')
    fun! s:stripAlt(key)
        return len(a:key) > 1 ? split(a:key, '.\zs')[-1]: a:key
    endf
else
    fun! s:stripAlt(key)
        if strchars(a:key) == 1
            let n = char2nr(a:key)
            return nr2char(n > 127 ? n - 128 : n)
        endif
        return a:key
    endf
endif
" Find the item corresponding to key user inputted
fun! s:findItem(key)
    let c = s:stripAlt(a:key)
    for item in s:curMenu()
        if type(item) == v:t_list && item[0] ==# c
            return item
        endif
    endfo
endf
