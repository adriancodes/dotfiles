;;; init.el -*- lexical-binding: t; -*-
;;; Doom Emacs Configuration (Terminal Mode)
;;;
;;; After editing, run: ~/.emacs.d/bin/doom sync

(doom! :input
       ;;bidi              ; (tfel ot thgir) תירבעב שמתשהל
       ;;chinese
       ;;japanese
       ;;layout            ; auie,teletonmd instead of qwerty

       :completion
       company              ; Code completion popup
       ;;helm              ; the *other* search engine
       ;;ido               ; the other *other* search engine
       ;;ivy               ; a search engine
       (vertico +icons)      ; Modern completion UI (like VS Code command palette)

       :ui
       ;;deft              ; notes
       doom                ; doom's beautiful themes
       doom-dashboard      ; nice startup screen       
       doom-quit           ; confirm quit
       (emoji +unicode)    ; 🙂
       hl-todo             ; highlight TODO/FIXME/NOTE
       ;;hydra
       indent-guides       ; show indentation guides
       ;;ligatures          ; pretty symbols (GUI only)
       ;;minimap           ; a map for the code
       modeline            ; snazzy, Atom-inspired modeline
       nav-flash           ; blink cursor after big jumps
       ;;neotree           ; file tree (use treemacs instead)
       ophints             ; visual hints for operations
       (popup +defaults)   ; tame sudden windows
       ;;tabs              ; FIXME: tabs for window management
       (treemacs +lsp)     ; file explorer sidebar
       unicode             ; extended unicode support
       vc-gutter            ; git diff in gutter
       (window-select +numbers) ; quick window switching
       workspaces          ; workspace management (like IDE tabs)
       zen                 ; distraction-free mode

       :editor
       (evil +everywhere)  ; vim keybindings everywhere
       file-templates      ; auto-populate new files
       fold                ; code folding
       (format +onsave)    ; auto-format code
       ;;god               ; run Emacs commands without modifier keys
       ;;lispy             ; vim for lisp
       multiple-cursors    ; edit many places at once (Cmd+D behavior)
       ;;objed             ; text object editing
       ;;parinfer          ; turn parens into python
       ;;rotate-text       ; cycle region text
       snippets            ; code snippets
       word-wrap           ; soft line wrapping

       :emacs
       (dired +icons)      ; file manager
       electric            ; smart pairs and indentation
       (ibuffer +icons)    ; better buffer list
       so-long             ; handle files with extremely long lines
       undo                ; better undo system
       vc                  ; version control integration

       :term
       ;;eshell            ; elisp shell
       ;;shell             ; standard shell
       ;;term              ; basic terminal
       vterm               ; best-in-class terminal

       :checkers
       syntax              ; real-time error checking (flycheck)
       (spell +flyspell)   ; spell checking
       ;;grammar           ; grammar checking

       :tools
       ;;ansible
       ;;biblio            ; bibliography
       (debugger +lsp)     ; debugging support
       direnv              ; per-project env vars
       docker              ; docker support
       editorconfig        ; .editorconfig support
       ;;ein               ; jupyter notebooks
       (eval +overlay)     ; run code, show results
       ;;gist
       (lookup +dictionary ; documentation lookup
               +docsets)
       (lsp +peek)         ; Language Server Protocol (CRITICAL for IDE features)
       (magit +forge)      ; best git interface + GitHub/GitLab integration
       make                ; Makefile support
       ;;pass              ; password manager
       pdf                 ; PDF viewing
       ;;prodigy           ; process manager
       ;;rgb               ; color preview/picker (GUI only)
       taskrunner          ; task runner for npm/make/etc.
       ;;terraform
       tree-sitter         ; better syntax highlighting
       ;;tmux
       ;;upload            ; remote file editing

       :os
       (:if IS-MAC macos)  ; macOS-specific improvements
       ;;tty              ; terminal emacs improvements (causes mouse escape code issues)

       :lang
       ;;agda
       ;;beancount
       ;;(cc +lsp)         ; C/C++
       (clojure +lsp +tree-sitter)
       ;;common-lisp
       ;;coq
       ;;crystal
       ;;csharp
       ;;data
       ;;(dart +flutter)
       ;;dhall
       ;;elixir
       ;;elm
       emacs-lisp          ; always needed for Emacs config
       ;;erlang
       ;;ess               ; R
       ;;factor
       ;;faust
       ;;fortran
       ;;fsharp
       ;;fstar
       ;;gdscript
       (go +lsp +tree-sitter)
       ;;(graphql +lsp)
       ;;(haskell +lsp)
       ;;hy
       ;;idris
       (json +lsp +tree-sitter)
       ;;(java +lsp)
       (javascript +lsp +tree-sitter)
       (typescript +lsp +tree-sitter)
       ;;julia
       ;;kotlin
       ;;latex
       ;;lean
       ;;ledger
       ;;lua
       (markdown +grip)    ; markdown with live preview
       ;;nim
       ;;nix
       ;;ocaml
       (org +pretty        ; note-taking/planning powerhouse
            +roam2
            +journal
            +present)
       ;;php
       ;;plantuml
       ;;purescript
       (python +lsp        ; Python with full IDE support
               +pyright
               +tree-sitter)
       ;;qt
       ;;racket
       ;;raku
       rest                ; REST client in Emacs
       ;;rst
       ;;(ruby +rails +lsp)
       (rust +lsp +tree-sitter)
       ;;scala
       ;;(scheme +guile)
       (sh +lsp +tree-sitter)
       ;;sml
       ;;solidity
       ;;swift
       ;;terra
       (web +lsp +tree-sitter)  ; HTML/CSS
       (yaml +lsp)
       ;;zig

       :email
       ;;(mu4e +org +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       :app
       ;;calendar
       ;;emms
       ;;everywhere        ; emacs anywhere
       ;;irc
       ;;(rss +org)
       ;;twitter

       :config
       ;;literate
       (default +bindings +smartparens))
