vim9script

def AtStart()
  if ! exists('g:exruler.at_start') || g:exruler.at_start !=# 0
    exruler#Init()
  endif
enddef

augroup exruler_atstart
  au!
  au VimEnter * AtStart()
augroup END

