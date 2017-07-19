# popup.vim

popup.vim可以让vim在底部弹出你自己定义的菜单，并通过按键触发相应的命令。

演示视频：

![](https://raw.githubusercontent.com/luzhlon/gif/master/popup.gif)

## 添加菜单示例

### 添加到顶级菜单

```viml
call popup#add('file', '文件',
    \['n', '新建', ":conf ene\<cr>"],
    \['o', '打开', ":browse confirm e\<cr>"],
    \['s', '保存', ":w\<cr>"],
    \['d', '关闭', ":QuitBuffer\<cr>"],
    \['x', '退出', ":confirm qa\<cr>"])
```

### 多级菜单

```viml
let sub = [['/', '斜杠反斜杠', [
              \['x', '反斜杠转义    ' , ':s/\\/\\\\/g'."\<cr>"],
              \['c', '反斜杠消除    ' , ':s/\\\\/\\/g'."\<cr>"],
              \['a', '斜杠 → 反斜杠 ' , ':s/\//\\/g'."\<cr>"],
              \['b', '反斜杠 → 斜杠 ' , ':s/\\/\//g'."\<cr>"]]],
          \['c', '中文标点  ', [
              \['m', '冒号', ":s:/：/:/g\<cr>"],
              \['q', '括号', ":s:/（\\(.\\{-}\\)）/\1/g\<cr>"]]],
          \['x', '个数替换  ', ":s/\<c-r>//\\=repeat('-', len(submatch(0)))"],
          \['s', '空白字符  ', [
              \['i', '制表符 → 空格 ' , ":s/\t/\\=repeat(' ',\&ts)/g\<cr>"],
              \['l', '消除空行      ' , ":g/^$/del\<cr>"],
              \['s', '消除行尾空白  ' , printf(':s/\s*%s*$%s',"\<c-v>\<c-m>","\<cr>")],
              \['m', '消除行尾回车符' , ":s/\<c-v>\<c-m>$/\<cr>"]]],
          \[';', '行末加分号' , ':g! /\(\(\/\/.\{-}\)\|[{};]\|\(else\)\)$/norm A;'."\<cr>"]]
let align = [['=', '等号对齐', ":Tabularize /=\<cr>"],
           \ [':', '冒号对齐', ":Tabularize /:\<cr>"],
           \ [',', '逗号对齐', ":Tabularize /,\<cr>"],
           \ ['e', '其他对齐', ":Tabularize /"]]
let util = [
        \['l', '打开链接' , 'gx'],
        \['s', '常用替换' , sub],
        \['a', '常用对齐' , align],
        \['e', '编辑VIMRC', ":e $MYVIMRC\<cr>"],
        \['c', '复制文件名' , ":let @+ = expand('%')\<cr>"]]
call popup#add('util', 'Util', util)
```

###  为当前buffer添加菜单

ftplugin/markdown.vim：

```viml
call popup#addl('mdutil', 'Util4Markdown',
    \['d', '生成Docx',  "w|!pandoc -f markdown -t docx %:p -o %:p:r.docx"],
    \['h', '生成Html',  "w|!pandoc -f markdown -t html %:p -o %:p:r.html"],
    \['o', '显示Toc ' , ":Toc\<cr>"],
    \['m', '表格对齐' , ":TableFormat\<cr>"],
    \[',', '任务列表' , ":TaskList\<cr>"],
    \['f', '跳转到锚' , "yiw/<span id=\"\<c-r>\"\">"])
call popup#addl('insert', '插入',
    \['b', '插入粗体' , "****\<left>\<left>"],
    \['i', '插入斜体' , "**\<left>"],
    \['s', '插入Task' , "* []\<left>"],
    \['/', '插入注释' , "<!---->\<esc>2h"],
    \['l', '插入链接' , "[]()\<left>"],
    \['a', '插入锚点' , "<span id=\"\">\<esc>2h"])
```

### Funcref && lambda表达式

```viml
call popup#add('insert', '插入',
    \['t', '日期  ', {->strftime('%Y/%b/%d')}],
    \['f', '文件名', {->expand('%')}],
    \['m', '模式行', "vim: set "])
```

## 为菜单绑定按键

```viml
nmap <expr><m-f> Popup('file')
nmap <expr><space> Popup('util')
" 只为特定的buffer绑定
nmap <buffer><expr><m-,> Popup('mdutil')
```

## 重复最后一个命令

```viml
map <expr><m-.> popup#last()
```

## 推荐配置

查看我的配置： https://github.com/luzhlon/.vim/tree/dev/config/popup.vim
