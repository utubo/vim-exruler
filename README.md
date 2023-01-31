# vim-exruler

## INTRODUCTION

vim-exruler is a Vim plugin powerfull(?) ruler.

<img width="600" src="https://user-images.githubusercontent.com/6848636/215660395-64e0d920-f365-4444-8405-4ec1852990ee.png">

## USAGE
### Require
- vim9script

### Install
- Example of `.vimrc`
  ```vim
  vim9script
  ⋮
  dein#add('utubo/vim-exruler')
  ⋮
  g:exruler = {}
  # require nerd fonts
  g:exruler.head = "\ue0bc"
  g:exruler.tail = "\ue0be"
  g:exruler.sep = "\ue0bc"
  g:exruler.sub = ["\ue0b9", "\ue0bb"]
  ```

## INTERFACE

### API
#### `exruler#Update()`
Update ruler.

### VARIABLES
#### `g:exruler`
`g:exruler` is dictionaly.  

- `at_start`  
  number.  
  `0`: disable exruler at VimEnter.  
  `1`: enable exruler at VimEnter.  
  `default` is `1`.  
- `head`  
  the char of left of ruler.
- `tail`  
  the char of right of ruler.
- `sep`  
  the char of the separator of the mode.
- `sub`  
  the char of the sub-separators.  
  as [<left side>, <right side>]
  default is [`|`, `|`]
- `format`  
  the format of ruler.  
  see `:help ruler`.  
  Specials for vim-exruler
  ```
  | -   sub-separator
  ```
  defailt is `%t %m%r%=%| %{&fenc} %{&ff} %| %4l:%-2c`
- `mode`  
  the names of mode.  
  see g:exruler.mode

#### `g:exruler.mode`
see `:help mode()`.

```vim
# default
g:exruler.mode = {
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
  '*':  '*', # for unknown mode.
  'NC': '-'  # for not-current windows.
}
```

### COLORS
the mode colors.

|Hilight group      |Default color                |
|-------------------|-----------------------------|
|ExRuler            |StatusLine                   |
|ExRulerNormal      |ToolBarButton                |
|ExRulerVisual      |Visual                       |
|ExRulerVisualLine  |VisualNOS                    |
|ExRulerVisualBlock |link to ExRulerVisualLine    |
|ExRulerSelect      |DiffChange                   |
|ExRulerSelectLine  |link to ExRulerSelect        |
|ExRulerSelectBlock |link to ExRulerSelect        |
|ExRulerInsert      |DiffAdd                      |
|ExRulerReplace     |DiffChange                   |
|ExRulerCommand     |WildMenu                     |
|ExRulerPrompt      |Search                       |
|ExRulerTerm        |StatusLineTerm               |
|ExRulerShell       |StatusLineTermNC             |
|ExRulerModeNC      |StatusLineNC for not-current windows. |
|ExRulerOther       |link to ExRulerModeNC for unknown mode. |

