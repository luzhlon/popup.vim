" =============================================================================
" Filename:     plugin/popup.vim
" Author:       luzhlon
" Function:     Popup a menu with a user-defined keymap
" Last Change:  2019-03-28
" =============================================================================

let g:popup = {}
let g:popup_loaded = 1

fun! s:leave_cmdline()
    if !v:event['abort']
        let g:popup.last = [getcmdline(), ':']
    endif
endf

au CmdLineLeave : call <sid>leave_cmdline()
