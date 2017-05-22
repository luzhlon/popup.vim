# popup.vim
popup.vim可以让vim在底部弹出你自己定义的菜单，并通过按键触发相应的命令。

演示视频：
![](https://raw.githubusercontent.com/luzhlon/gif/master/popup.gif)

## 添加菜单示例
```viml
call popup#add('file', '文件',
    \['n', '新建', ":conf ene\<cr>"],
    \['o', '打开', ":browse confirm e\<cr>"],
    \['s', '保存', ":w\<cr>"],
    \['d', '关闭', ":QuitBuffer\<cr>"],
    \['x', '退出', ":confirm qa\<cr>"])
```

## 为菜单绑定按键
```viml
nmap <expr><m-f> Popup('file')
nmap <expr><m-w> Popup('window')
```

## 重复最后一个命令
```viml
map <expr><m-.>     popup#last()
```

## 推荐配置
查看我的配置： https://github.com/luzhlon/.vim/tree/master/plugin/popup

其中有一些命令来自我的另一个插件[util.vim](https://github.com/luzhlon/util.vim)
