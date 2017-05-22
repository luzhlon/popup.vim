" =============================================================================
" Filename:     autoload/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/2/19
" =============================================================================
scripte utf-8
let s:Names = {}            "顶级菜单名称
let s:Menus = {}            "顶级菜单表
let s:last  = ''            "最后一次执行的命令
let s:stack = []            "菜单栈

"添加菜单:(submenu, [key, command, description])
fun! popup#add(key, name, ...)
    if !a:0|return|endif
    let s:Names[a:key] = a:name
    let s:Menus[a:key] =
          \ type(a:1[0])==3 ? a:1 : copy(a:000)
endf
"添加buffer相关的菜单
fun! popup#addl(key, name, ...)
    if !a:0|return|endif
    if !exists('b:BufMenus')
        let b:BufMenus = {}
    endif
    let s:Names[a:key] = a:name
    let b:BufMenus[a:key] =
          \ type(a:1[0])==3 ? a:1 : copy(a:000)
endf
"删除菜单
fun! popup#remove(key)
    call remove(s:Names, a:key)
    call remove(s:Menus, a:key)
endf
"最后一个命令
fun! popup#last()
    return s:last
endf
"返回顶级菜单和buffer菜单合并的结果
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
"弹出菜单并返回用户的命令
fun! popup#popup(key)
    let m = s:getmenu(a:key)
    if empty(m) | return | endif
    call s:clearStack()
    call s:enterMenu(s:Names[a:key], m)
    while 1
        let key = s:popup()   "显示菜单内容
        let item = s:findItem(key)
        if empty(item)|break|endif
        let [k, n, C] = item                "key, name, command
        let t = type(C)
        if t == v:t_dict                    "有子菜单
            call s:enterMenu(n, C['item'])
        elseif t == v:t_list
            call s:enterMenu(n, C)          "有子菜单
        elseif t == v:t_func
            let s:last = C()
            return s:last
        else
            let s:last=C|return C
        endif
    endw
    return ''
endf
"弹出菜单提示
fun! s:echoPrompt()
    echo ''
    "第一行显示当前的菜单位置的导航栏
    let [i, l, n] = [0, [], len(s:stack)]
    while i < n
        call add(l, s:stack[i])
        let i += 2
    endw
    let items = s:curMenuItem()         "当前菜单
    let &ch = len(items)+2
    "显示菜单导航栏
    echoh Boolean|echon join(l, ' → ') ":\n"
    "显示所有的菜单条目
    for item in items
        let [k, n, C] = item                "key, name, command
        echoh Type| echon '  '.n
        let t = type(C)
        if t == 4 || t == 3                 "有子菜单
            echoh Underlined   |echon '('.k.")"
            echoh None         |echon "\t\t\t\t"
            echoh Comment      |echon ">\n"
        else
            echoh Underlined   |echon '('.k.")"
            echoh Include      |echon "\t\t".strtrans(string(C)) "\n"
        endif
    endfo
    echoh None
endf
"弹出列表内容，并获取用户的输入
fun! s:popup()
    "store options
    let [lz, ch, ut] = [&lz, &ch, &ut]
    set nolazyredraw
    set ut=100000000
    "echo
    call s:echoPrompt()
    "get input
    let c = getchar()
    "restore options
    let [&lz, &ch, &ut] = [lz, ch, ut]
    redraw
    return c
endf
"进入菜单
fun! s:enterMenu(name, item)
    call add(s:stack, a:name)
    call add(s:stack, a:item)
endf
"清空菜单栈
fun! s:clearStack()
    let s:stack = []
endf
"获取当前菜单
fun! s:curMenuName()
    return s:stack[-2]
endf
fun! s:curMenuItem()
    return s:stack[-1]
endf
if has('nvim')
"去除alt键组合后的按键字母
fun! s:stripAlt(key)
    return type(a:key) != 0 ?
                \ split(a:key, '.\zs')[-1] : nr2char(a:key)
endf
else
"去除alt键组合
fun! s:stripAlt(key)
    return type(a:key) == 0 && a:key > 127 ?
                \ nr2char(a:key - 128) : nr2char(a:key)
endf
endif
"寻找按键对应的当前菜单里的条目
fun! s:findItem(key)
    let c = s:stripAlt(a:key)
    for item in s:curMenuItem()
        if item[0] == c
            return item
        endif
    endfo
    return []
endf
"扩展菜单
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
