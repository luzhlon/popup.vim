" =============================================================================
" Filename:     plugin/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2017/7/31
" =============================================================================

let g:popup_loaded = 1

if !exists('g:popup')
    let g:popup = {}
endif

if !has_key(g:popup, 'upkey')
    let g:popup.upkey = "\<c-h>"
endif

if !has_key(g:popup, 'arrow')
    let g:popup.arrow = ' -> '
endif

