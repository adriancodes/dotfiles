# Doom Emacs Command Reference

Your config uses Evil mode (vim keybindings) with Doom Emacs.
All `SPC` commands work in **normal mode** only.
`C-c` and `C-x` commands work in **any mode**.

---

## 1. Everyday Essentials

### Modes
| Key         | Action                              |
|-------------|-------------------------------------|
| `i`         | Enter insert mode (type text)       |
| `Esc`       | Return to normal mode               |
| `v`         | Visual mode (select characters)     |
| `V`         | Visual line mode (select full lines)|
| `C-v`       | Visual block mode (select columns)  |

### Save, Quit, Undo
| Key         | Action                              |
|-------------|-------------------------------------|
| `:w`        | Save file                           |
| `:q`        | Quit                                |
| `:wq`       | Save and quit                       |
| `:q!`       | Quit without saving                 |
| `u`         | Undo                                |
| `C-r`       | Redo                                |
| `SPC b s`   | Save buffer                         |
| `SPC q q`   | Quit Emacs                          |

### Copy, Cut, Paste
| Key         | Action                              |
|-------------|-------------------------------------|
| `yy`        | Copy (yank) current line            |
| `3yy`       | Copy 3 lines                        |
| `yw`        | Copy word                           |
| `y$`        | Copy to end of line                 |
| `dd`        | Cut (delete) current line           |
| `3dd`       | Cut 3 lines                         |
| `dw`        | Cut word                            |
| `d$` or `D` | Cut to end of line                  |
| `x`         | Cut single character                |
| `p`         | Paste after cursor                  |
| `P`         | Paste before cursor                 |
| `"0p`       | Paste last yanked text (not deleted)|

### Navigation
| Key           | Action                            |
|---------------|-----------------------------------|
| `h/j/k/l`    | Left / down / up / right          |
| `w`           | Next word start                   |
| `b`           | Previous word start               |
| `e`           | End of word                       |
| `0`           | Beginning of line                 |
| `$`           | End of line                       |
| `^`           | First non-blank character         |
| `gg`          | Top of file                       |
| `G`           | Bottom of file                    |
| `:42`         | Go to line 42                     |
| `42gg`        | Go to line 42                     |
| `5j`          | Move 5 lines down                 |
| `5k`          | Move 5 lines up                   |
| `{`           | Previous paragraph/blank line     |
| `}`           | Next paragraph/blank line         |
| `%`           | Jump to matching bracket          |
| `C-o`         | Jump back (previous location)     |
| `C-i`         | Jump forward                      |
| `*`           | Search word under cursor forward  |
| `#`           | Search word under cursor backward |

### Search and Replace
| Key           | Action                            |
|---------------|-----------------------------------|
| `/pattern`    | Search forward                    |
| `?pattern`    | Search backward                   |
| `n`           | Next search match                 |
| `N`           | Previous search match             |
| `:%s/old/new/g` | Replace all in file             |
| `:%s/old/new/gc`| Replace all with confirmation   |
| `:s/old/new/g`  | Replace all in current line     |

### Editing
| Key           | Action                            |
|---------------|-----------------------------------|
| `i`           | Insert before cursor              |
| `a`           | Insert after cursor               |
| `I`           | Insert at line beginning          |
| `A`           | Insert at line end                |
| `o`           | New line below, enter insert      |
| `O`           | New line above, enter insert      |
| `r`           | Replace single character          |
| `R`           | Enter replace mode                |
| `cw`          | Change word (delete + insert)     |
| `cc`          | Change entire line                |
| `c$` or `C`   | Change to end of line             |
| `ci"`         | Change inside quotes              |
| `ci(`         | Change inside parentheses         |
| `ci{`         | Change inside braces              |
| `cit`         | Change inside HTML tag            |
| `di"`         | Delete inside quotes              |
| `da"`         | Delete around quotes (incl. quotes)|
| `>>`          | Indent line                       |
| `<<`          | Unindent line                     |
| `==`          | Auto-indent line                  |
| `J`           | Join line below to current        |
| `~`           | Toggle case of character          |
| `gU{motion}`  | Uppercase (e.g., `gUw` = word)    |
| `gu{motion}`  | Lowercase                         |
| `.`           | Repeat last command               |

### Visual Mode Operations
| Key           | Action                            |
|---------------|-----------------------------------|
| `v` then move | Select characters                 |
| `V` then move | Select lines                      |
| `y`           | Yank (copy) selection             |
| `d`           | Delete (cut) selection            |
| `c`           | Change selection (delete + insert)|
| `>`           | Indent selection                  |
| `<`           | Unindent selection                |
| `=`           | Auto-indent selection             |
| `U`           | Uppercase selection               |
| `u`           | Lowercase selection               |
| `gv`          | Re-select last visual selection   |

---

## 2. Windows (Splits)

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC w v`     | Split vertical (side by side)     |
| `SPC w s`     | Split horizontal (top/bottom)     |
| `SPC w d`     | Close current window              |
| `SPC w m`     | Close all other windows           |
| `SPC w M`     | Maximize current window           |
| `SPC w h`     | Move to window left               |
| `SPC w j`     | Move to window below              |
| `SPC w k`     | Move to window above              |
| `SPC w l`     | Move to window right              |
| `SPC w r`     | Swap windows                      |
| `SPC w =`     | Balance window sizes              |
| `SPC w >`     | Increase window width             |
| `SPC w <`     | Decrease window width             |
| `C-x 1`       | Close all other windows           |
| `C-x 2`       | Split horizontal                  |
| `C-x 3`       | Split vertical                    |
| `C-x 0`       | Close current window              |

---

## 3. Buffers (Open Files)

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC b b`     | Switch buffer                     |
| `SPC b d`     | Kill (close) buffer               |
| `SPC b n`     | Next buffer                       |
| `SPC b p`     | Previous buffer                   |
| `SPC b s`     | Save buffer                       |
| `SPC b r`     | Revert buffer (reload from disk)  |
| `SPC b N`     | New empty buffer                  |
| `SPC ,`       | Switch buffer (shortcut)          |
| `M-[`         | Previous buffer                   |
| `M-]`         | Next buffer                       |

---

## 4. Files

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC .`       | Find file (browse)                |
| `SPC f f`     | Find file                         |
| `SPC f r`     | Recent files                      |
| `SPC f s`     | Save file                         |
| `SPC f S`     | Save as (new name)                |
| `SPC f D`     | Delete this file                  |
| `SPC f R`     | Rename/move this file             |
| `SPC f c`     | Copy this file                    |
| `SPC f P`     | Open Doom config                  |
| `SPC f p`     | Find file in Doom config          |

---

## 5. Project

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC SPC`     | Find file in project              |
| `SPC p f`     | Find file in project              |
| `SPC p p`     | Switch project                    |
| `SPC p s`     | Search text in project (ripgrep)  |
| `SPC p r`     | Find and replace in project       |
| `SPC p d`     | Find directory in project         |
| `SPC p !`     | Run shell command in project root |
| `SPC p c`     | Compile project                   |
| `SPC p t`     | Run project tests                 |
| `SPC p i`     | Invalidate project cache          |

---

## 6. Search

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC /`       | Search in project (ripgrep)       |
| `SPC s s`     | Search in current buffer          |
| `SPC s p`     | Search in project                 |
| `SPC s d`     | Search in directory               |
| `SPC s i`     | Jump to symbol (function/class)   |
| `SPC s o`     | Search online                     |
| `C-c f`       | Search in buffer                  |
| `C-c F`       | Search in project                 |

---

## 7. Code / LSP (works in code files with language server)

| Key           | Action                            |
|---------------|-----------------------------------|
| `K`           | Show documentation at cursor      |
| `gd`          | Go to definition                  |
| `SPC c d`     | Go to definition                  |
| `SPC c D`     | Go to declaration                 |
| `SPC c R`     | Find all references               |
| `SPC c i`     | Find implementations              |
| `SPC c r`     | Rename symbol                     |
| `SPC c a`     | Code actions (quick fixes)        |
| `SPC c f`     | Format buffer                     |
| `SPC c F`     | Format selection                  |
| `SPC c k`     | Show documentation                |
| `SPC c o`     | Organize imports                  |
| `SPC c x`     | Show errors list                  |
| `SPC c s`     | Show symbols in file              |
| `SPC c p`     | Peek definition (inline preview)  |

---

## 8. Git

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC g g`     | Magit status (full git interface) |
| `SPC g b`     | Git blame (who changed each line) |
| `SPC g l`     | Git log                           |
| `SPC g d`     | Git diff                          |
| `SPC g f`     | Git fetch                         |
| `SPC g p`     | Git pull                          |
| `SPC g P`     | Git push                          |
| `SPC g c`     | Git commit                        |
| `SPC g s`     | Stage current file                |
| `SPC g u`     | Unstage current file              |
| `SPC g t`     | Time machine (browse file history)|
| `SPC g B`     | Browse file on GitHub/GitLab      |

### Inside Magit Status (`SPC g g`)
| Key   | Action                                  |
|-------|-----------------------------------------|
| `s`   | Stage file or hunk                      |
| `u`   | Unstage file or hunk                    |
| `c c` | Start commit (type message, `C-c C-c` to confirm) |
| `P p` | Push                                    |
| `F p` | Pull                                    |
| `b b` | Switch branch                           |
| `b c` | Create new branch                       |
| `l l` | Show log                                |
| `d d` | Show diff                               |
| `q`   | Quit magit                              |
| `g`   | Refresh                                 |
| `TAB` | Expand/collapse section                 |

---

## 9. AI

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC a c`     | Open AI chat (gptel)              |
| `SPC a a`     | AI menu (change model, options)   |
| `SPC a s`     | Send region/buffer to AI          |
| `SPC a r`     | AI rewrite selection              |
| `SPC a e`     | Ellama chat (local LLM)          |

---

## 10. Open / Toggle

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC o p`     | Toggle treemacs (file explorer)   |
| `SPC o t`     | Toggle terminal (vterm)           |
| `SPC o T`     | Open terminal here                |
| `SPC o d`     | Open dired (file manager)         |
| `SPC o a`     | Open org agenda                   |
| `SPC t l`     | Toggle line numbers               |
| `SPC t w`     | Toggle word wrap                  |
| `SPC t z`     | Toggle zen mode                   |
| `SPC t t`     | Toggle treemacs                   |
| `SPC t c`     | Cycle through favorite themes     |
| `SPC t T`     | Choose any theme                  |
| `SPC t r`     | Toggle read-only mode             |

---

## 11. Multiple Cursors

| Key           | Action                            |
|---------------|-----------------------------------|
| `C-c d`       | Mark next occurrence of selection |
| `C-c L`       | Mark ALL occurrences              |
| `C-c D`       | Duplicate current line            |

---

## 12. Folding (Code Collapse)

| Key           | Action                            |
|---------------|-----------------------------------|
| `za`          | Toggle fold at cursor             |
| `zc`          | Close fold                        |
| `zo`          | Open fold                         |
| `zM`          | Close all folds                   |
| `zR`          | Open all folds                    |

---

## 13. Help

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC ?`       | Show all keybindings              |
| `SPC :`       | Run any command by name (M-x)     |
| `SPC h b`     | Describe all bindings             |
| `SPC h K`     | Open keybindings cheatsheet       |
| `SPC h d h`   | Doom help documentation           |
| `SPC h k`     | Describe what a key does          |
| `SPC h f`     | Describe a function               |
| `SPC h v`     | Describe a variable               |

---

## 14. Workspaces

| Key           | Action                            |
|---------------|-----------------------------------|
| `SPC TAB n`   | New workspace                     |
| `SPC TAB d`   | Delete workspace                  |
| `SPC TAB TAB` | Switch workspace                  |
| `SPC TAB [`   | Previous workspace                |
| `SPC TAB ]`   | Next workspace                    |
| `SPC TAB 1-9` | Switch to workspace by number     |

---

## 15. Quick Access (C-c prefix, works in insert mode)

| Key       | Action                                |
|-----------|---------------------------------------|
| `C-c f`   | Search in buffer                      |
| `C-c F`   | Search in project                     |
| `C-c p`   | Find file in project                  |
| `C-c i`   | Jump to symbol                        |
| `C-c e`   | Toggle file explorer                  |
| `C-c P`   | Command palette (M-x)                 |
| `C-c b`   | Switch buffer                         |
| `C-c d`   | Mark next occurrence                  |
| `C-c L`   | Mark all occurrences                  |
| `C-c D`   | Duplicate line                        |
| `M-,`     | Open Doom config                      |
| `M-[`     | Previous buffer                       |
| `M-]`     | Next buffer                           |

---

## 16. Emacs Fundamentals (C-x prefix)

These are built-in Emacs commands that always work:

| Key           | Action                            |
|---------------|-----------------------------------|
| `C-x C-s`    | Save file                         |
| `C-x C-c`    | Quit Emacs                        |
| `C-x C-f`    | Find/open file                    |
| `C-x b`      | Switch buffer                     |
| `C-x k`      | Kill buffer                       |
| `C-x u`      | Undo                              |
| `C-x h`      | Select all                        |
| `C-x 1`      | Close other windows               |
| `C-x 2`      | Split horizontal                  |
| `C-x 3`      | Split vertical                    |
| `C-x 0`      | Close current window              |
| `C-x o`      | Switch to other window            |

---

## Tips

- **Press `SPC` and wait** -- which-key shows all available commands
- **Relative line numbers** tell you how many `j`/`k` to press
- **`.` (dot)** repeats your last editing command
- **`u`** undoes, and you can undo many times
- **In insert mode**, `C-c` and `C-x` bindings still work
- **`:` in normal mode** opens the command line for ex commands
