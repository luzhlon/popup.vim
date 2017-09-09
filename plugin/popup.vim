" =============================================================================
" Filename:     plugin/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/7/31
" =============================================================================

fun! Popup(k)
    return popup#popup(a:k)
endf

let g:popup_loaded = 1

if !exists('g:popup#arrow')
    let g:popup#arrow = ' -> '
endif
if !exists('g:popup#upkey')
    let g:popup#upkey = "\<bs>"
endif
