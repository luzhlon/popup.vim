" =============================================================================
" Filename:    autoload/pmenu.vim
" Author:      luzhlon
" Date:        2017-10-30
" Description: ...
" =============================================================================

" Echo prompt and get the item {{{
fun! s:prompt() dict
    let stack_names = [self.name]
    let stack_items = [self.items]
    let flag = ''

    while 1
        let items = stack_items[-1]
        call s:echo_prompt(stack_names, items)
        let key = s:strip_alt(getchar())
        if key == g:popup.upkey
            " Leave menu
            if len(stack_names) < 2 | return | endif
            call remove(stack_names, -1)
            call remove(stack_items, -1)
            continue
        endif

        let item = s:find_item(items, key)
        if empty(item) | break | endif
        let [k, n, C] = item                " key, name, command

        if len(k) > 1 | let flag = k[1] | endif

        let t = type(C)
        if t == v:t_list                    " Enter submenu
            call add(stack_names, n)
            call add(stack_items, C)
        else
            return [t == v:t_func ? C(): C, flag]
        endif
    endw
endf
" }}}

" Popup this menu {{{
fun! s:popup(...) dict
    " Store options
    let [lz, ch, ut] = [&lz, &ch, &ut]
    set nolazyredraw
    set ut=100000000

    let ret = self.prompt()

    " Restore options
    let [&lz, &ch, &ut] = [lz, ch, ut]
    echo "\r"

    return ret
endf
" }}}

" Add a menu item
fun! s:add_item(char, description, keys) dict
    call add(self.items, [a:char, a:description, a:keys])
endf

" Echo prompt {{{
fun! s:echo_prompt(names, items)
    echo ''
    let &cmdheight = len(a:items) + 1
    " Echo the menu names
    echoh Boolean | echon join(a:names, g:popup.arrow) ':'
    " count the maximum length of item's names
    let maxnamelen = 0
    for item in a:items
        let n = strdisplaywidth(item[1])
        let maxnamelen = n > maxnamelen ? n : maxnamelen
    endfo
    " show the menu's items
    for item in a:items
        echon "\n"
        if type(item) == v:t_string
            echoh Comment | echon item
            continue
        endif
        let [k, n, C] = item                " key, name, command
        echoh Normal | echon '  ['
        echoh Underlined  | echon printf('%2S', strtrans(k))
        echoh Normal | echon "]\t"
        echoh Type | echon n
        echon repeat(' ', maxnamelen - strdisplaywidth(n) + 1) "\t"
        let t = type(C)
        if t == v:t_dict || t == v:t_list   " Submenu
            echoh WarningMsg | echon '>'
        elseif t == v:t_func                " Function
            echoh Include | echon string(C)
        else                                " Command
            echoh Function | echon strtrans(C)
        endif
    endfo
    echoh None
    " redraw
endf
" }}}

" Merge with another menu {{{
fun! s:merge(m) dict
    let self.items += a:m.items
    return self
endf
" }}}

" Find a item {{{
fun! s:find_item(items, key)
    for item in a:items
        if type(item) == v:t_list && item[0][0] ==# a:key
            return item
        endif
    endfo
endf
" }}}

fun! s:copy() dict
    let another = copy(self)
    let another.items = copy(self.items)
    return another
endf

" Strip the ALT-key {{{
if has('nvim')
    fun! s:strip_alt(c)
        let k = type(a:c) == v:t_number ? nr2char(a:c): a:c
        return len(k) > 1 ? split(k, '.\zs')[-1]: k
    endf
else
    fun! s:strip_alt(c)
        if type(a:c) == v:t_number
            let n = a:c
            return nr2char(n > 127 ? n - 128 : n)
        endif
        return a:c
    endf
endif
" }}}

" Create a new popup menu {{{
fun! pmenu#new(name, ...)
    return {
        \ 'name': a:name, 'items': copy(a:000),
        \ 'popup': funcref('s:popup'),
        \ 'prompt': funcref('s:prompt'),
        \ 'merge': funcref('s:merge'),
        \ 'copy': funcref('s:copy'),
        \ 'add_item': funcref('s:add_item'),
        \ }
endf
" }}}
