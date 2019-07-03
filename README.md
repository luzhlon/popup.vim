
Deprecated. Please use [guider.nvim](https://github.com/luzhlon/guider.nvim)

# popup.vim

popup.vim可以让vim在底部弹出你自己定义的菜单，并通过按键触发相应的命令。

演示视频：

![popup.gif](https://raw.githubusercontent.com/luzhlon/gif/master/popup.gif)

## 添加菜单示例

### 添加到顶级菜单

```viml
call popup#reg('window', pmenu#new('Window & Buffer',
    \ ['o:', 'New tabpage', 'tabe'],
    \ ['x:', 'Close tabpage', 'tabc'],
    \ ['p!', 'Prev tabpage', 'gT'],
    \ ['n!', 'Next tabpage', 'gt'],
    \ '------------------------------',
    \ ['w', 'Wipe', "\<c-w>\<c-u>"],
    \ ['s:', 'Resize',  'call ResizeWindow()'],
    \ ['c', 'Copy buffer', "ggVGy:bot sp ene!\<cr>Vp"]
\ ))
```

### 多级菜单

```viml
call popup#reg('util#n', pmenu#new('Util',
  \ [' ', 'Common', [
    \ ["\t:", 'NERDTreeToggle',   'NERDTreeToggle'],
    \ ["\r:", 'NERDTreeFind',     'NERDTreeFind'],
    \ [' !', 'No hilight',        ":noh\<cr>"],
    \ ['.!', 'Do last command',   '@:'],
    \ ['l',  'Open URL',          'gx'],
  \ ]],
  \ ["\t:", 'Tools', [
    \ ['c', 'cmd.exe',      "call open#cmd()"],
    \ ['b', 'bash',         "call open#bash()"],
    \ ['d', 'File directory', "call open#curdir()"],
    \ ['r', 'Reopen vim',   "call open#reopen()"],
    \ ['e', 'Explorer',     "call open#explorer(expand('%:p'))"],
    \ ['.', 'File under cursor', "call open#cur_file()"],
    \ [',', 'Bash', has('nvim') ? 'winc s | term bash': 'terminal bash'],
  \ ]],
\ ))
```

More documents: [Popup's doc](./doc/popup.txt)

## 为菜单绑定按键
```viml
nmap <expr><m-f> popup#('file')
nmap <expr><space> popup#('util')
" 只为特定的buffer绑定
nmap <buffer><expr><m-,> popup#('mdutil')
```

## 重复最后一个命令
```viml
map <expr><m-.> popup#last()
```
