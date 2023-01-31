vim9script

# Utils
def NVL(val: any, default: any): any
  return empty(val) ? default : val
enddef

def GetFgBg(name: string): any
  const id = hlID(name)->synIDtrans()
  var fg = NVL(synIDattr(id, 'fg#'), 'NONE')
  var bg = NVL(synIDattr(id, 'bg#'), 'NONE')
  if has('gui')
    # Bug?
    fg = fg =~# '^[0-9]' ? 'NONE' : fg
    bg = bg =~# '^[0-9]' ? 'NONE' : bg
  endif
  if synIDattr(id, 'reverse') ==# '1'
    return { fg: bg, bg: fg }
  else
    return { fg: fg, bg: bg }
  endif
enddef

def HasStatusLine(): bool
  return &laststatus ==# 2 || &laststatus ==# 1 && winnr('$') > 1 || winnr() !=# winnr('999j')
enddef

def HeadId(normal: string, statusline: string, term: string): string
  return HasStatusLine() ? &bt ==# 'terminal' ? term : statusline : normal
enddef

def NewWinVal(): any
  const r_n = HasStatusLine() ? ' ' : g:exruler.tail
  return { n_x: '', s_x: '', t_x: '', x: '', x_r: '', n_m: '', m: '', m_r: '', r_n: r_n }
enddef

# Const
const colors = {
  #       Name                  Default link
  '_':  ['ExRuler',            'StatusLine'],
  n:    ['ExRulerNormal',      'ToolBarButton'],
  v:    ['ExRulerVisual',      'Visual'],
  V:    ['ExRulerVisualLine',  'VisualNOS'],
  '^V': ['ExRulerVisualBlock', 'VisualNOS'],
  s:    ['ExRulerSelect',      'DiffChange'],
  S:    ['ExRulerSelectLine',  'DiffChange'],
  '^S': ['ExRulerSelectBlock', 'DiffChange'],
  i:    ['ExRulerInsert',      'DiffAdd'],
  R:    ['ExRulerReplace',     'DiffChange'],
  c:    ['ExRulerCommand',     'DiffDelete'],
  r:    ['ExRulerPrompt',      'Search'],
  t:    ['ExRulerTerm',        'StatusLineTermNC'],
  '!':  ['ExRulerShell',       'StatusLineTermNC'],
  '*':  ['ExRulerOther',       'StatusLineNC'],
  'NC': ['ExRulerModeNC',      'StatusLineNC'],
}

# Main
export def Init()
  const override = get(g:, 'exruler', {})
  g:exruler = {
    width: 999,
    head: ' ',
    tail: ' ',
    sep: ' ',
    sub: ['|', '|'],
    format: '%t %m%r%=%| %{&fenc} %{&ff} %| %4l:%-2c',
    mode: {
      n:    'N',
      v:    'V',
      V:    'VL',
      '^V': 'VB',
      s:    'S',
      S:    'SL',
      '^S': 'SB',
      i:    'I',
      R:    'R',
      c:    'C',
      r:    'P',
      t:    'T',
      '!':  '!',
      '*':  '*',
      'NC': '-',
    },
  }
  g:exruler->extend(override)

  augroup exruler
    au ColorScheme * silent! exruler#Update()
    au WinScrolled * silent! exruler#UpdateFormat()
    au WinLeave * silent! exruler#ClearMode()
    au ModeChanged,WinEnter * silent! exruler#UpdateMode()
  augroup End

  Update()
  set ruler laststatus=0
enddef

def GetMode(): string
  var m = mode()[0]
  if m ==# "\<C-v>"
    return '^V'
  elseif m ==# "\<C-s>"
    return '^S'
  elseif ! g:exruler.mode->has_key(m)
    return '*'
  else
    return m
  endif
enddef

export def Update()
  for [k,v] in colors->items()
    execute $'silent! hi link {v[0]} {v[1]}'
  endfor
  UpdateColor()
  UpdateFormat()
  UpdateMode()
enddef

export def UpdateColor()
  const e = GetFgBg('ExRuler')
  const c = GetFgBg('ExRulerModeNC')
  const n = GetFgBg('Normal')
  const s = GetFgBg('StatusLineNC')
  const t = GetFgBg('StatusLineTermNC')
  const last_id = matchlist(g:exruler.format, '^.*%#\([^#]\+\)#')
  const l = empty(last_id) ? e : GetFgBg(last_id[1])
  const x = has('gui') ? 'gui' : 'cterm'
  silent! execute $'silent! hi ExRuler_n_x {x}fg={n.bg} {x}bg={e.bg}'
  silent! execute $'hi ExRuler_s_x {x}fg={s.bg} {x}bg={e.bg}'
  silent! execute $'hi ExRuler_t_x {x}fg={t.bg} {x}bg={e.bg}'
  silent! execute $'hi ExRuler_x_r {x}fg={c.bg} {x}bg={e.bg}'
  silent! execute $'hi! ExRulerR    {x}fg={n.bg} {x}bg={l.bg}'
enddef

export def UpdateMode()
  const md = GetMode()
  const mc = colors[md][0]
  const head = GetFgBg(HeadId('Normal', 'StatusLine', 'StatusLineTerm'))
  const mode = GetFgBg(mc)
  const exru = GetFgBg('ExRuler')
  const r_style = g:exruler.sep ==# ' ' ? 'reverse' : 'NONE'
  const x = has('gui') ? 'gui' : 'cterm'
  silent! execute $'hi ExRuler_n_m {x}fg={head.bg} {x}bg={mode.bg}'
  silent! execute $'hi ExRuler_m_r {x}fg={mode.bg} {x}bg={exru.bg} {x}={r_style}'
  silent! execute $'hi! link ExRulerMode {mc}'
  w:exruler = NewWinVal()
  w:exruler.m = g:exruler.mode[md]
  w:exruler.n_m = g:exruler.head
  w:exruler.m_r = g:exruler.sep
enddef

export def ClearMode()
  w:exruler = NewWinVal()
  w:exruler.x = g:exruler.mode.NC
  w:exruler[HeadId('n_x', 's_x', 't_x')] = g:exruler.head
  w:exruler[HeadId('x_r', 'x_r', 'x_r')] = g:exruler.sep
enddef

export def UpdateFormat()
  w:exruler = get(w:, 'exruler', NewWinVal())
  const width = g:exruler.width ==# 0 ? '' : $'{max([1, min([&columns / 2, g:exruler.width])])}'
  var format = g:exruler.format
        ->substitute('%bufinfo', '%{exruler#BufInfo()}', 'g')
  var lt_rt = format->split('%=')
  format = lt_rt[0]->substitute('%|', '%{exruler.sub[0]}', 'g') ..
    '%=' ..
    get(lt_rt, 1, '')->substitute('%|', '%{exruler.sub[1]}', 'g')
  if g:exruler.sep ==# ' '
    format = ' ' .. format
  endif
  &rulerformat = printf('%%%s(%s%%)',
    width,
    # Mode
    '%#ExRuler_n_m#%{w:exruler.n_m}' ..
    '%#ExRulerMode#%{w:exruler.m}' ..
    '%#ExRuler_m_r#%{w:exruler.m_r}' ..
    # ModeNC
    '%#ExRuler_n_x#%{w:exruler.n_x}' ..
    '%#ExRuler_s_x#%{w:exruler.s_x}' ..
    '%#ExRuler_t_x#%{w:exruler.t_x}' ..
    '%#ExRulerModeNC#%{w:exruler.x}' ..
    '%#ExRuler_x_r#%{w:exruler.x_r}' ..
    '%#ExRuler#%<' ..
    format ..
    '%#ExRulerR#%{w:exruler.r_n}'
  )
enddef

