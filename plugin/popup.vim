" =============================================================================
" Filename:     plugin/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/2/16
" =============================================================================

fun! Popup(k)
    return popup#popup(a:k)
endf
