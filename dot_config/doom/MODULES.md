# Doom Emacs Modules & Packages Reference

Your configuration enables specific Doom modules (in `init.el`) and additional
packages (in `packages.el`). This document explains what each one does, why it's
there, and how to use it.

---

## Part 1: Doom Modules (init.el)

Doom modules are curated bundles of packages and configuration. Each one is
listed under a category (`:completion`, `:ui`, etc.) and can have flags like
`+lsp` or `+tree-sitter` that enable extra features.

---

### :completion

#### `company`
**What:** Code completion popup that appears as you type.
**How it works:** When you pause while typing in a code buffer, a dropdown
appears with suggestions from your language server, buffer words, snippets, etc.
**Key commands:**
- Completions appear automatically (0.1s delay in your config)
- `C-n` / `C-p` to navigate suggestions
- `RET` to accept
- `C-g` to dismiss

#### `(vertico +icons)`
**What:** Modern minibuffer completion UI. This is what you see when you press
`SPC` and start typing commands, or when searching for files/buffers.
**How it works:** Replaces the default Emacs minibuffer with a vertical
completion list. The `+icons` flag adds file-type icons next to results.
**Key commands:**
- `C-n` / `C-p` to navigate up/down in the list
- Type to filter results (fuzzy matching)
- `RET` to select
- Used by: `SPC SPC` (find file), `SPC ,` (switch buffer), `SPC :` (M-x), etc.

---

### :ui

#### `doom`
**What:** Doom's theme engine and base UI configuration. Loads your chosen theme
(`catppuccin` in your config) and provides the `doom-themes` package.

#### `doom-dashboard`
**What:** The startup screen you see when opening Emacs without a file. Shows
recent files, projects, and a Doom logo.
**Key commands:**
- Press `r` for recent files from the dashboard
- Press `p` to open a project

#### `doom-quit`
**What:** Shows a fun/sarcastic confirmation message when you try to quit Emacs.
Prevents accidental exits.

#### `(emoji +unicode)`
**What:** Emoji support. `+unicode` adds extended Unicode character insertion.
**Key commands:**
- `SPC i e` -- search and insert emoji

#### `hl-todo`
**What:** Highlights special comment keywords in code files.
**Highlights these words:**
- `TODO` -- yellow
- `FIXME` -- red
- `HACK` -- orange
- `NOTE` -- green
- `DEPRECATED` -- grey
- `BUG` -- red

#### `indent-guides`
**What:** Shows thin vertical lines at each indentation level so you can visually
track code nesting. Especially useful for deeply nested Python, YAML, etc.

#### `modeline`
**What:** The status bar at the bottom of each window. Shows:
- Current evil mode state (NORMAL, INSERT, VISUAL)
- File name (truncated to project-relative path)
- Git branch and status
- LSP diagnostics (errors/warnings count)
- Line/column number
- File encoding

#### `nav-flash`
**What:** Briefly flashes the cursor line after large jumps (like `gg`, `G`,
searching, or jumping to definitions) so you don't lose your place.

#### `ophints`
**What:** Shows visual hints during operations. For example, when you yank text,
the yanked region briefly highlights so you can see exactly what was copied.

#### `(popup +defaults)`
**What:** Manages how temporary windows (popups) appear. Without this, help
buffers, compilation output, etc. would take over your screen. `+defaults`
provides sensible sizing and placement rules.

#### `(treemacs +lsp)`
**What:** File explorer sidebar (like VS Code's file tree).
`+lsp` adds language-server integration (shows errors/warnings on files).
**Key commands:**
- `SPC o p` -- toggle treemacs
- `SPC t t` -- also toggles treemacs
- Inside treemacs: `RET` to open file, `o` for options, `q` to close

#### `unicode`
**What:** Extended Unicode support. Ensures special characters, symbols, and
non-Latin scripts render correctly.

#### `vc-gutter`
**What:** Shows git diff indicators in the left gutter of code files:
- Green bar = added lines
- Red bar = deleted lines
- Yellow bar = modified lines

#### `(window-select +numbers)`
**What:** Quick window switching. `+numbers` shows a number overlay on each
window when you trigger window selection.
**Key commands:**
- `SPC w w` -- select window by number
- Numbers appear in each window; press the number to jump there

#### `workspaces`
**What:** Workspace management -- like virtual desktops for your buffers. Each
workspace has its own set of open buffers. Great for switching between projects.
**Key commands:**
- `SPC TAB n` -- new workspace
- `SPC TAB d` -- delete workspace
- `SPC TAB TAB` -- switch workspace
- `SPC TAB 1-9` -- jump to workspace by number

#### `zen`
**What:** Distraction-free editing mode. Centers the buffer, hides the modeline,
and increases margins for focused writing.
**Key commands:**
- `SPC t z` -- toggle zen mode

---

### :editor

#### `(evil +everywhere)`
**What:** Vim keybindings everywhere. This is why you can use `h/j/k/l`,
`dd`, `yy`, visual mode, etc. `+everywhere` ensures vim bindings work in
every buffer, not just code files (also in help, magit, dired, etc.).
**This is the foundation of your entire editing experience.**

#### `file-templates`
**What:** Auto-populates new files with templates. When you create a new
`.py` file, it inserts a basic Python header; new `.sh` files get a shebang
line; new `.org` files get a title block, etc.

#### `fold`
**What:** Code folding support (collapse/expand blocks of code).
**Key commands:**
- `za` -- toggle fold at cursor
- `zc` -- close fold
- `zo` -- open fold
- `zM` -- close all folds
- `zR` -- open all folds

#### `(format +onsave)`
**What:** Auto-formats code using external formatters. `+onsave` runs the
formatter every time you save.
**Formatters used:**
- Python: `black` or `yapf`
- JavaScript/TypeScript: `prettier`
- Go: `gofmt` / `goimports`
- Rust: `rustfmt`
- HTML/CSS: `prettier`

Your config excludes emacs-lisp, SQL, and LaTeX from auto-formatting.

#### `multiple-cursors`
**What:** Edit multiple places at once (like Cmd+D in VS Code).
**Key commands:**
- `C-c d` -- mark next occurrence of word/selection
- `C-c L` -- mark ALL occurrences
- `C-g` to exit multi-cursor mode
- While active, edits happen at all cursor positions simultaneously

#### `snippets`
**What:** Code snippet expansion. Type a short trigger and expand it into a
full code template with tab stops.
**Key commands:**
- `SPC i s` -- insert snippet (browse available snippets)
- Type trigger word then `TAB` to expand
- After expansion, `TAB` moves between fill-in fields

#### `word-wrap`
**What:** Soft line wrapping for long lines. Lines wrap visually at the window
edge without inserting actual newlines in the file.
**Key commands:**
- `SPC t w` -- toggle word wrap

---

### :emacs

#### `(dired +icons)`
**What:** Built-in file manager. Opens directory listings you can navigate,
rename files in, copy, move, etc. `+icons` shows file-type icons.
**Key commands:**
- `SPC o d` -- open dired
- Inside dired: `RET` to open, `d` to mark for deletion, `R` to rename,
  `C` to copy, `x` to execute marked operations

#### `electric`
**What:** Smart auto-pairing and indentation. Automatically inserts matching
brackets, quotes, and parentheses. Adjusts indentation when you type.

#### `(ibuffer +icons)`
**What:** Better buffer list. Shows all open buffers with file size, mode,
and project information. `+icons` adds file-type icons.
**Key commands:**
- `SPC b i` -- open ibuffer (or use `C-x C-b`)

#### `so-long`
**What:** Handles files with extremely long lines (like minified JS/CSS).
Automatically disables expensive features to keep Emacs responsive when
opening such files.

#### `undo`
**What:** Better undo system (undo-fu). Provides proper linear undo/redo
instead of Emacs's default tree-based undo.
**Key commands:**
- `u` -- undo (in normal mode)
- `C-r` -- redo (in normal mode)

#### `vc`
**What:** Version control integration. Provides base git awareness for Emacs --
tracking which files are modified, added, or untracked.

---

### :term

#### `vterm`
**What:** Best-in-class terminal emulator inside Emacs. Runs a real terminal
(not a dumb shell) so you can use tmux, htop, etc. inside Emacs.
**Key commands:**
- `SPC o t` -- toggle terminal popup
- `SPC o T` -- open terminal in current directory
- Inside vterm: `C-c C-t` to enter "copy mode" (normal vim keys work)

---

### :checkers

#### `syntax`
**What:** Real-time error checking (flycheck). Shows squiggly underlines for
errors and warnings as you type. Works with LSP, compilers, and linters.
**Key commands:**
- `SPC c x` -- show errors list
- Errors shown inline via LSP sideline
- `]d` / `[d` -- jump to next/previous diagnostic

#### `(spell +flyspell)`
**What:** Spell checking. `+flyspell` checks spelling as you type (underlines
misspelled words). Active in comments, strings, and text modes.
**Key commands:**
- `z =` -- suggest corrections for word at cursor
- `]s` / `[s` -- jump to next/previous misspelling

---

### :tools

#### `(debugger +lsp)`
**What:** Debugging support via DAP (Debug Adapter Protocol). `+lsp` integrates
with your language server for breakpoint-aware debugging.
**Key commands:**
- `SPC d d` -- start debugger
- `SPC d b` -- toggle breakpoint
- `SPC d n` -- step over
- `SPC d i` -- step into
- `SPC d o` -- step out
- `SPC d c` -- continue

#### `direnv`
**What:** Per-project environment variables. If a project has a `.envrc` file,
direnv automatically loads those environment variables when you open files in
that project. Great for managing different Python virtualenvs, Node versions, etc.

#### `docker`
**What:** Docker support. Edit Dockerfiles with syntax highlighting, manage
containers and images from within Emacs.
**Key commands:**
- Opens docker management via `docker` command

#### `editorconfig`
**What:** Reads `.editorconfig` files and applies their settings (indent size,
tab/spaces, line endings, etc.). Ensures your editor respects the project's
coding standards automatically.

#### `(eval +overlay)`
**What:** Run code inline and see results. `+overlay` shows evaluation results
as overlays next to the code rather than in a separate buffer.
**Key commands:**
- `g r` -- evaluate region/selection
- Results appear inline, temporarily

#### `(lookup +dictionary +docsets)`
**What:** Documentation lookup. Jump to definitions, find references, look up
documentation. `+dictionary` adds dictionary/thesaurus lookup. `+docsets` adds
Dash/Zeal docset integration.
**Key commands:**
- `K` -- show documentation at cursor
- `gd` -- go to definition
- `SPC s D` -- dictionary lookup
- `SPC s o` -- search online

#### `(lsp +peek)`
**What:** Language Server Protocol -- this is the backbone of IDE features.
Provides code completion, go-to-definition, find references, rename symbol,
diagnostics, code actions, etc. `+peek` adds inline peek windows.
**Requires language servers installed:**
- Python: `pyright`
- JS/TS: `typescript-language-server`
- Go: `gopls`
- Rust: `rust-analyzer`
- See the system dependencies checklist at top of config.el

#### `(magit +forge)`
**What:** The best git interface available. Full git operations through a
keyboard-driven UI. `+forge` adds GitHub/GitLab integration (view issues,
PRs, create PRs, etc. from within Emacs).
**Key commands:**
- `SPC g g` -- open magit status (the main entry point)
- See the "Inside Magit Status" section in COMMANDS.md for details
- Forge commands available under `@` in magit

#### `make`
**What:** Makefile support. Syntax highlighting for Makefiles plus the ability
to run make targets.
**Key commands:**
- `SPC p c` -- compile project (runs `make` by default)

#### `pdf`
**What:** PDF viewing inside Emacs using `pdf-tools`. View PDFs with search,
annotations, and outline navigation.

#### `taskrunner`
**What:** Discovers and runs project tasks from npm scripts, Makefiles,
Cargo.toml, etc. Provides a unified interface for running project commands.
**Key commands:**
- `SPC p t` -- run project test task
- `SPC p c` -- run project compile task

#### `tree-sitter`
**What:** Better syntax highlighting and code understanding using tree-sitter
parsers. Parses code into an AST (abstract syntax tree) for more accurate
highlighting than regex-based approaches. Also enables structural code
navigation and text objects.

---

### :os

#### `(:if IS-MAC macos)`
**What:** macOS-specific improvements. Only loaded on macOS. Handles clipboard
integration, path setup, and macOS-specific behavior.

---

### :lang (Language Support)

Each language module provides: syntax highlighting, indentation, language
server integration (`+lsp`), tree-sitter parsing (`+tree-sitter`), and
language-specific commands.

#### `(clojure +lsp +tree-sitter)`
**What:** Clojure/ClojureScript development. REPL integration, structural
editing, paredit/smartparens for S-expressions.
**LSP server:** clojure-lsp

#### `emacs-lisp`
**What:** Always needed -- it's the language Emacs and Doom are written in.
Provides evaluation, documentation lookup, and debugging for Elisp.
**Key commands:**
- `C-x C-e` -- evaluate expression before cursor
- `SPC m e b` -- evaluate buffer

#### `(go +lsp +tree-sitter)`
**What:** Go development. Auto-formatting with goimports on save, test running,
struct tag management.
**LSP server:** gopls
**Config note:** Your config sets `gofmt-command` to `goimports` (auto-manages
import statements).

#### `(json +lsp +tree-sitter)`
**What:** JSON editing with validation, formatting, and path display.
**LSP server:** vscode-json-languageserver

#### `(javascript +lsp +tree-sitter)`
**What:** JavaScript development. JSX support, npm integration, and
formatting with prettier.
**LSP server:** typescript-language-server
**Config note:** Your config sets 2-space indentation.

#### `(typescript +lsp +tree-sitter)`
**What:** TypeScript development. Type checking, refactoring, and TSX support.
**LSP server:** typescript-language-server
**Config note:** Your config sets 2-space indentation.

#### `(markdown +grip)`
**What:** Markdown editing with live preview. `+grip` uses GitHub's rendering
API for preview (requires `grip` Python package).
**Key commands:**
- `SPC m p` -- preview markdown

#### `(org +pretty +roam2 +journal +present)`
**What:** Org-mode -- the note-taking, planning, and document authoring
powerhouse of Emacs.
- `+pretty` -- prettifies org syntax (headings, lists, etc.)
- `+roam2` -- org-roam for Zettelkasten-style linked notes (builds a knowledge
  graph from your notes)
- `+journal` -- daily journaling
- `+present` -- turn org documents into presentations
**Key commands:**
- `SPC o a` -- org agenda
- `SPC n r f` -- find org-roam node
- `SPC n r i` -- insert org-roam link
- `SPC n j j` -- new journal entry

#### `(python +lsp +pyright +tree-sitter)`
**What:** Python development with full IDE support. `+pyright` uses Microsoft's
Pyright type checker as the language server (fast, accurate).
**LSP server:** pyright
**Config note:** Your config sets `python3` as the shell interpreter.

#### `rest`
**What:** REST client inside Emacs. Write HTTP requests in `.http` or
`.restclient` files and execute them to see responses.
**Key commands:**
- `C-c C-c` in a restclient buffer to send request

#### `(rust +lsp +tree-sitter)`
**What:** Rust development. Cargo integration, inline type hints, auto-format
with rustfmt on save.
**LSP server:** rust-analyzer
**Config note:** Your config enables `rustic-format-on-save`.

#### `(sh +lsp +tree-sitter)`
**What:** Shell script editing (bash, zsh, sh). Shellcheck integration for
linting.
**LSP server:** bash-language-server

#### `(web +lsp +tree-sitter)`
**What:** HTML/CSS development. Uses `web-mode` for mixed-content files
(HTML with embedded JS/CSS). Emmet abbreviation expansion.
**Config note:** Your config sets 2-space indentation for markup, CSS, and code.
**Key commands:**
- `C-j` -- expand Emmet abbreviation (e.g., `div.container>ul>li*3`)

#### `(yaml +lsp)`
**What:** YAML editing with validation and schema support. Handles
Kubernetes manifests, CI configs, Docker Compose, etc.
**LSP server:** yaml-language-server

---

### :config

#### `(default +bindings +smartparens)`
**What:** Doom's default configuration. `+bindings` sets up all the `SPC`
leader key bindings. `+smartparens` enables auto-pairing of brackets,
parentheses, quotes, etc. **You almost always want this enabled.**

---

## Part 2: Additional Packages (packages.el)

These are extra packages installed on top of Doom's module system.

---

### AI Integration

#### `gptel`
**What:** Multi-provider AI chat interface. Supports Claude (Anthropic),
ChatGPT (OpenAI), and local models via Ollama. The primary AI tool in your
setup.
**Setup:** API keys stored in `~/.authinfo.gpg`
(see config.el for the exact format).
**Your config:** Claude (claude-4-5-sonnet) is the default, with ChatGPT and
Ollama as alternatives.
**Key commands:**
- `SPC a c` -- open AI chat buffer
- `SPC a a` -- AI menu (change model, options)
- `SPC a s` -- send region/buffer to AI
- `SPC a r` -- AI rewrite selection

#### `chatgpt-shell`
**What:** Alternative chat interface focused on ChatGPT. Provides a shell-like
interaction with the AI.

#### `ellama`
**What:** Local LLM support via Ollama. If you have Ollama running locally,
this lets you use local models for AI chat, code completion, and text
generation without sending data to external APIs.
**Your config:** Set to use `llama3` model.
**Key commands:**
- `SPC a e` -- open ellama chat

---

### Editor Enhancements

#### `visual-regexp` + `visual-regexp-steroids`
**What:** Better search-and-replace with live visual feedback. As you type
your regex pattern, matches highlight in the buffer in real-time. `steroids`
adds Python-style regex syntax.
**Key commands:**
- `M-x vr/replace` -- visual replace
- `M-x vr/query-replace` -- visual replace with confirmation

#### `move-text`
**What:** Move lines or regions up and down with keyboard shortcuts.
**Key commands:**
- `M-up` -- move line/region up
- `M-down` -- move line/region down

#### `highlight-symbol`
**What:** Automatically highlights all occurrences of the symbol under your
cursor (like VS Code). Helps you see where a variable or function is used
without searching.
**Your config:** 0.3s delay before highlighting.

#### `rainbow-delimiters`
**What:** Colors matching parentheses, brackets, and braces in different
colors so you can visually match nesting levels. Essential for Lisp, but
useful in any language with deep nesting.

#### `rainbow-mode`
**What:** Shows color codes as their actual colors in CSS/SCSS/web files.
For example, `#ff0000` gets a red background, `rgb(0,128,0)` gets green.
**Your config:** Active in CSS, SCSS, and web modes.

#### `olivetti`
**What:** Centers buffer content with wide margins for a distraction-free
writing experience. Often used alongside zen mode.

---

### Git Enhancements

#### `git-timemachine`
**What:** Browse through previous versions of a file interactively. Step
forward and back through git history for the current file.
**Key commands:**
- `SPC g t` -- start time machine on current file
- Inside time machine: `p` previous version, `n` next version, `q` quit

#### `browse-at-remote`
**What:** Open the current file/line on GitHub, GitLab, or Bitbucket in
your browser. Useful for sharing links to specific code.
**Key commands:**
- `SPC g B` -- browse current file on remote

---

### Project/File Management

#### `consult-projectile`
**What:** Enhances projectile (project management) with consult's fuzzy
matching UI. Provides richer file/project switching with previews.

#### `dired-single`
**What:** Makes dired reuse the same buffer when navigating directories
instead of opening a new buffer for each directory. Prevents buffer
proliferation.

#### `all-the-icons-dired`
**What:** Adds file-type icons in dired directory listings. Makes it easier
to visually identify file types.

---

### Code Quality

#### `dtrt-indent`
**What:** Automatically detects the indentation style (tabs vs spaces, indent
width) of existing files and adjusts Emacs settings to match. Prevents you
from accidentally mixing tabs and spaces in someone else's project.
**Your config:** Active in all programming modes.

---

### Language-Specific

#### `markdown-toc`
**What:** Generates and updates a table of contents in Markdown files based
on headings.
**Key commands:**
- `M-x markdown-toc-generate-toc` -- insert/update TOC

#### `yaml-pro`
**What:** Enhanced YAML editing with structural folding, path display (shows
the full YAML path at cursor), and smart editing. Useful for large
Kubernetes manifests or CI configs.

---

### Quality of Life

#### `helpful`
**What:** Better help buffers. When you look up a function or variable,
`helpful` shows more context: source code, references, callees, and
customization options.
**Key commands:**
- `SPC h f` -- describe function (uses helpful)
- `SPC h v` -- describe variable (uses helpful)

#### `marginalia`
**What:** Adds annotations to minibuffer completions. When browsing commands,
files, or buffers, you see extra information like documentation strings,
file sizes, key bindings, etc. next to each candidate.

#### `persistent-scratch`
**What:** Saves the `*scratch*` buffer between Emacs sessions. Normally the
scratch buffer is lost when you quit. This preserves your notes and
scratch code.

#### `super-save`
**What:** Auto-saves files when you switch buffers, switch windows, or when
Emacs loses focus.
**Your config:** Also saves after 30 seconds of idle time.

---

### Themes

These are color themes you can switch between:

| Package | Description |
|---------|-------------|
| `vscode-dark-plus-theme` | VS Code's default dark theme |
| `catppuccin-theme` | Pastel dark theme (your current theme) |
| `modus-themes` | Highly accessible themes (WCAG AAA contrast) |
| `ef-themes` | Elegant, colorful themes by the modus author |

**Switch themes:**
- `SPC t c` -- cycle through favorites (doom-one, doom-tokyo-night,
  doom-dracula, doom-nord, catppuccin, vscode-dark-plus)
- `SPC t T` -- browse and preview all installed themes

---

## Part 3: Quick Setup Checklist

To get everything working, you need these external tools:

### Required
```bash
# Core tools
brew install ripgrep fd cmake libtool libvterm node

# Nerd font (for icons in terminal)
brew install font-symbols-nerd-font
```

### Language Servers (install as needed)
```bash
# Python
npm install -g pyright

# JavaScript / TypeScript
npm install -g typescript typescript-language-server

# Go
go install golang.org/x/tools/gopls@latest

# Rust
brew install rust-analyzer

# Bash
npm install -g bash-language-server

# YAML
npm install -g yaml-language-server

# JSON
npm install -g vscode-json-languageserver

# HTML/CSS
npm install -g vscode-html-languageserver-bin vscode-css-languageserver-bin
```

### AI Setup
```bash
# For gptel (AI chat) - store API keys in ~/.authinfo.gpg:
# machine api.anthropic.com login apikey password sk-ant-YOUR-KEY
# machine api.openai.com login apikey password sk-YOUR-KEY

# For ellama (local AI) - install Ollama:
# brew install ollama
# ollama pull llama3
```

### After installing
```bash
~/.emacs.d/bin/doom sync
~/.emacs.d/bin/doom doctor   # checks for missing dependencies
```
