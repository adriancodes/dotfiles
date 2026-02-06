;;; config.el -*- lexical-binding: t; -*-
;;; Doom Emacs Configuration (Terminal Mode)
;;;
;;; Copy this file to ~/.doom.d/config.el
;;; After editing, run: ~/.emacs.d/bin/doom sync

;; ============================================
;; User Information
;; ============================================

;; --- SYSTEM DEPENDENCIES CHECKLIST ---
;; To get the most out of this configuration, ensure these are installed:
;;
;; 1. Core Tools:
;;    brew install font-symbols-nerd-font ripgrep fd cmake libtool libvterm node
;;
;; 2. Language Servers (LSP):
;;    Python:     npm install -g pyright
;;    JS/TS:      npm install -g typescript typescript-language-server
;;    Go:         go install golang.org/x/tools/gopls@latest
;;    Rust:       brew install rust-analyzer
;;
;; 3. After installing, run:
;;    ~/.emacs.d/bin/doom sync
;;    ~/.emacs.d/bin/doom doctor
;; -------------------------------------

(setq user-full-name "Adrian Martin"
      user-mail-address "hello@adrianmartin.dev")

;; ============================================
;; Appearance
;; ============================================

;; Theme - choose your favorite
;; Popular options: doom-one, doom-dracula, doom-tokyo-night, doom-nord
;; doom-moonlight, doom-palenight, catppuccin, vscode-dark-plus
;; Theme - doom-one is well-tested and readable
;; vscode-dark-plus can have contrast issues with blue highlights
(setq doom-theme 'catppuccin)

(defvar my/theme-favorites
  '(doom-one doom-tokyo-night doom-dracula doom-nord catppuccin vscode-dark-plus)
  "Curated themes for quick switching.")

(defvar my/theme-cycle-index 0
  "Current index in `my/theme-favorites`.")

(defun my/cycle-theme ()
  "Cycle through `my/theme-favorites`."
  (interactive)
  (setq my/theme-cycle-index
        (mod (1+ my/theme-cycle-index) (length my/theme-favorites)))
  (let ((theme (nth my/theme-cycle-index my/theme-favorites)))
    (if (fboundp 'doom/load-theme)
        (doom/load-theme theme t)
      (load-theme theme t))))

;; Line numbers - relative helps with jumping (e.g., 5j to go down 5 lines)
(setq display-line-numbers-type 'relative)

;; Disable mouse tracking in terminal
(xterm-mouse-mode -1)
(after! xt-mouse (xterm-mouse-mode -1))

;; Prevent Emacs from enabling terminal focus event reporting.
;; Emacs 28+ sends \e[?1004h on startup (via xterm.el) which tells
;; the terminal to send \e[I/\e[O on focus changes. Evil interprets
;; these as "I" (insert) and "O" (open line) keypresses.
(setq xterm-set-window-title nil)
(advice-add 'xterm--init-focus-tracking :override #'ignore)

;; Belt-and-suspenders: also disable it after every possible init hook
(defun my/disable-terminal-focus-tracking ()
  (when (not (display-graphic-p))
    (send-string-to-terminal "\e[?1004l")
    (send-string-to-terminal "\e[?1003l")
    (send-string-to-terminal "\e[?1002l")
    (send-string-to-terminal "\e[?1000l")))

(add-hook 'tty-setup-hook #'my/disable-terminal-focus-tracking)
(add-hook 'after-init-hook #'my/disable-terminal-focus-tracking)
(add-hook 'doom-after-init-hook #'my/disable-terminal-focus-tracking)

;; If any focus sequences still arrive, swallow them silently
(define-key special-event-map [terminal-focus-in] #'ignore)
(define-key special-event-map [terminal-focus-out] #'ignore)
(define-key input-decode-map "\e[I" [terminal-focus-in])
(define-key input-decode-map "\e[O" [terminal-focus-out])
;; Handle SGR mouse sequences that leak through
(define-key input-decode-map "\e[<" [terminal-mouse-event])
(define-key special-event-map [terminal-mouse-event] #'ignore)

;; Smoother scrolling
(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t
      auto-window-vscroll nil)

;; ============================================
;; Startup Behavior
;; ============================================

;; Don't open in split mode - start with a single window
(setq initial-buffer-choice nil)           ; Use Doom dashboard
(setq inhibit-startup-screen nil)          ; Allow Doom dashboard

;; Prevent dired/directory buffers from auto-opening
(setq dired-auto-revert-buffer nil)

;; Ensure we always start with a single window (no splits)
(defun my/startup-single-window ()
  "Ensure we start with a single window."
  (when (> (length (window-list)) 1)
    (delete-other-windows)))

;; window-setup-hook fires after all windows are configured
(add-hook 'window-setup-hook #'my/startup-single-window)

;; Enable 24-bit (truecolor) in terminal Emacs when the terminal supports it.
;; Without this, themes fall back to a 256-color palette where blues look bad.
(when (and (not (display-graphic-p))
           (getenv "COLORTERM")
           (string= (getenv "COLORTERM") "truecolor"))
  (set-terminal-parameter nil 'background-mode 'dark))

;; Fix faces that render as hard-to-read blue in terminal mode
(after! doom-themes
  (custom-set-faces!
    ;; Selection / region highlight
    '(region :background "#3E4451" :extend t)
    ;; Minibuffer / vertico selection
    '(vertico-current :background "#3E4451" :extend t)
    ;; Company tooltip selection
    '(company-tooltip-selection :background "#3E4451")
    ;; Highlight at point
    '(highlight :background "#3E4451")
    ;; Search matches
    '(lazy-highlight :background "#4A4A5A" :foreground "#ABB2BF")
    ;; Isearch current match
    '(isearch :background "#E5C07B" :foreground "#282C34" :weight bold)))

;; ============================================
;; Modeline (Status Bar)
;; ============================================

(after! doom-modeline
  (setq doom-modeline-lsp t
        doom-modeline-github t
        doom-modeline-buffer-file-name-style 'truncate-upto-project
        doom-modeline-time nil
        doom-modeline-vcs-max-length 40))

;; ============================================
;; Treemacs (File Explorer Sidebar)
;; ============================================

(after! treemacs
  (setq treemacs-width 35
        treemacs-position 'left
        treemacs-is-never-other-window t
        treemacs-show-hidden-files t
        treemacs-indentation 2
        treemacs-git-mode 'deferred
        ;; Disable project-follow via variable instead of mode toggle
        treemacs-project-follow-mode nil))

;; ============================================
;; LSP (Language Server Protocol) - Core IDE Features
;; ============================================

(after! lsp-mode
  (setq lsp-idle-delay 0.1
        lsp-log-io nil                          ; Disable logging for performance
        lsp-completion-provider :capf           ; Use built-in completion
        lsp-completion-enable t
        lsp-enable-symbol-highlighting t
        lsp-enable-on-type-formatting t
        lsp-enable-text-document-color t
        lsp-enable-folding t
        lsp-enable-indentation t
        lsp-enable-snippet t
        lsp-headerline-breadcrumb-enable t      ; Show file path breadcrumb
        lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols)
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-modeline-diagnostics-scope :workspace
        lsp-signature-auto-activate t
        lsp-signature-render-documentation t
        lsp-eldoc-enable-hover t
        lsp-eldoc-render-all t))

(after! lsp-ui
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-show-with-mouse nil
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-max-width 80
        lsp-ui-doc-max-height 20
        lsp-ui-doc-include-signature t
        lsp-ui-doc-delay 0.2
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-hover nil          ; Can be noisy
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-update-mode 'line
        lsp-ui-peek-enable t
        lsp-ui-peek-show-directory t))

;; ============================================
;; Completion (Company Mode)
;; ============================================

(after! company
  (setq company-idle-delay 0.1
        company-minimum-prefix-length 1
        company-show-quick-access t
        company-tooltip-limit 10
        company-tooltip-align-annotations t
        company-tooltip-flip-when-above t
        company-dabbrev-downcase nil
        company-dabbrev-ignore-case nil
        company-require-match nil
        company-frontends '(company-pseudo-tooltip-frontend
                           company-echo-metadata-frontend)))

;; ============================================
;; Projectile (Project Management)
;; ============================================

(after! projectile
  (setq projectile-project-search-path '("~/projects" "~/work" "~/code")
        projectile-sort-order 'recently-active
        projectile-enable-caching t
        projectile-indexing-method 'hybrid
        ;; Don't auto-open dired/directory on project switch
        projectile-switch-project-action #'projectile-find-file))

;; ============================================
;; Magit (Git Interface)
;; ============================================

(after! magit
  (setq magit-save-repository-buffers 'dontask
        magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1
        magit-diff-refine-hunk 'all
        magit-revision-show-gravatars '("^Author:     " . "^Commit:     ")))

;; ============================================
;; VTerm (Terminal)
;; ============================================

(after! vterm
  (setq vterm-shell "/bin/zsh"          ; or your preferred shell
        vterm-max-scrollback 10000
        vterm-kill-buffer-on-exit t))

;; ============================================
;; Format on Save
;; ============================================

(setq +format-on-save-enabled-modes
      '(not emacs-lisp-mode    ; elisp formatting can be finicky
            sql-mode           ; too opinionated
            tex-mode           ; latex formatting is complex
            latex-mode))

;; ============================================
;; File Management
;; ============================================

;; Don't create backup files
(setq make-backup-files nil
      auto-save-default t
      create-lockfiles nil)

;; Recent files
(setq recentf-max-saved-items 100)

;; ============================================
;; Which-Key (Keybinding Help)
;; ============================================

(after! which-key
  (setq which-key-idle-delay 0.25
        which-key-idle-secondary-delay 0.05
        which-key-show-early-on-C-h t
        which-key-max-description-length 40
        which-key-allow-imprecise-window-fit t))

;; ============================================
;;  AI Configuration (THE CURSOR MAGIC ✨)
;; ============================================

;; --- GPTel: Multi-provider AI chat ---
(use-package! gptel
  :defer t
  :config
  ;; Claude (Anthropic) - Primary AI
  (setq gptel-model "claude-4-5-sonnet-latest")
  (setq gptel-backend
        (gptel-make-anthropic "Claude"
          :stream t
          :key #'gptel-get-anthropic-key))
  
  ;; OpenAI as fallback
  (gptel-make-openai "ChatGPT"
    :stream t
    :key #'gptel-get-openai-key
    :models '("gpt-5.2" "gpt-5.2-mini" "o3" "o4-mini"))

  ;; Ollama for local models (if you have it installed)
  (gptel-make-ollama "Ollama"
    :stream t
    :models '("llama3.1" "llama3.2" "codellama" "mistral-nemo")))

;; Helper functions to get API keys from auth-source
(defun gptel-get-anthropic-key ()
  "Get Anthropic API key from ~/.authinfo.gpg"
  (let ((found (car (auth-source-search :host "api.anthropic.com"
                                         :require '(:secret)))))
    (if found
        (funcall (plist-get found :secret))
      (error "No Anthropic API key found. Add to ~/.authinfo.gpg:
machine api.anthropic.com login apikey password YOUR-KEY-HERE"))))

(defun gptel-get-openai-key ()
  "Get OpenAI API key from ~/.authinfo.gpg"
  (let ((found (car (auth-source-search :host "api.openai.com"
                                         :require '(:secret)))))
    (if found
        (funcall (plist-get found :secret))
      (error "No OpenAI API key found. Add to ~/.authinfo.gpg:
machine api.openai.com login apikey password YOUR-KEY-HERE"))))

;; --- GitHub Copilot (disabled - language server not installed) ---
;; To re-enable: install with `npm install -g @github/copilot-language-server`
;; then uncomment the block below
;; (use-package! copilot
;;   :hook ((prog-mode . copilot-mode)
;;          (yaml-mode . copilot-mode)
;;          (json-mode . copilot-mode))
;;   :bind (:map copilot-completion-map
;;               ("TAB" . copilot-accept-completion)
;;               ("<tab>" . copilot-accept-completion)
;;               ("C-TAB" . copilot-accept-completion-by-word)
;;               ("C-<tab>" . copilot-accept-completion-by-word)
;;               ("C-n" . copilot-next-completion)
;;               ("C-p" . copilot-previous-completion)
;;               ("C-g" . copilot-clear-overlay))
;;   :config
;;   (setq copilot-indent-offset-warning-disable t
;;         copilot-max-char -1))

;; --- Ellama (Ollama integration) ---
(use-package! ellama
  :defer t
  :init
  (setopt ellama-language "English")
  :config
  (setopt ellama-provider
          (make-llm-ollama
           :chat-model "llama3"
           :embedding-model "llama3")))

;; ============================================
;; Editor Enhancements
;; ============================================

;; Auto-detect indent style
(use-package! dtrt-indent
  :hook (prog-mode . dtrt-indent-mode))

;; Super-save - auto-save on focus loss
(use-package! super-save
  :config
  (setq super-save-auto-save-when-idle t
        super-save-idle-duration 30)
  (super-save-mode +1))

;; Persistent scratch buffer
(use-package! persistent-scratch
  :config
  (persistent-scratch-setup-default))

;; Highlight current symbol
(use-package! highlight-symbol
  :hook (prog-mode . highlight-symbol-mode)
  :config
  (setq highlight-symbol-idle-delay 0.3))

;; Move text up/down
(use-package! move-text
  :config
  (move-text-default-bindings))

;; Rainbow delimiters
(use-package! rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Show colors
(use-package! rainbow-mode
  :hook ((css-mode . rainbow-mode)
         (scss-mode . rainbow-mode)
         (web-mode . rainbow-mode)))

;; ============================================
;;  Keybindings (Terminal-compatible)
;; ============================================

;; Quick-access bindings under C-c prefix
;; Note: Standard Emacs bindings already cover save (C-x C-s),
;; undo (C-/), copy (M-w), paste (C-y), cut (C-w), select all (C-x h)
(map! "C-c f" #'+default/search-buffer        ; search in buffer
      "C-c F" #'+default/search-project        ; search project
      "C-c p" #'projectile-find-file           ; find file in project
      "C-c i" #'consult-imenu                  ; symbols in file
      "C-c e" #'+treemacs/toggle               ; file explorer
      "C-c P" #'execute-extended-command        ; command palette
      "C-c b" #'switch-to-buffer               ; switch buffer
      "C-c d" #'mc/mark-next-like-this         ; select next occurrence
      "C-c L" #'mc/mark-all-like-this          ; select all occurrences
      "C-c D" #'my/duplicate-line              ; duplicate line
      "M-,"   #'doom/open-private-config        ; open config
      "M-["   #'previous-buffer                ; previous buffer
      "M-]"   #'next-buffer)                   ; next buffer

;; Leader key bindings (Space menu - Doom's command palette)
(map! :leader
      ;; Top-level quick actions
      :desc "Find file in project" "SPC" #'projectile-find-file
      :desc "M-x" ":" #'execute-extended-command
      :desc "Show all commands" "?" #'which-key-show-top-level
      :desc "Find file" "." #'find-file
      :desc "Switch buffer" "," #'switch-to-buffer
      :desc "Search project" "/" #'+default/search-project

      ;; AI commands (A prefix - capital A to avoid conflict with Doom's SPC a)
      (:prefix ("A" . "AI")
       :desc "AI Chat" "c" #'gptel
       :desc "AI Menu" "m" #'gptel-menu
       :desc "Send to AI" "s" #'gptel-send
       :desc "AI Rewrite" "r" #'gptel-rewrite
       :desc "Ellama chat" "e" #'ellama-chat)

      ;; Buffer operations
      (:prefix ("b" . "buffer")
       :desc "Switch buffer" "b" #'switch-to-buffer
       :desc "Kill buffer" "d" #'kill-current-buffer
       :desc "Next buffer" "n" #'next-buffer
       :desc "Previous buffer" "p" #'previous-buffer
       :desc "Save buffer" "s" #'save-buffer
       :desc "Revert buffer" "r" #'revert-buffer
       :desc "New buffer" "N" #'+default/new-buffer)

      ;; Code operations
      (:prefix ("c" . "code")
       :desc "Format buffer" "f" #'+format/buffer
       :desc "Format region" "F" #'+format/region
       :desc "Rename symbol" "r" #'lsp-rename
       :desc "Code actions" "a" #'lsp-execute-code-action
       :desc "Go to definition" "d" #'lsp-find-definition
       :desc "Go to declaration" "D" #'lsp-find-declaration
       :desc "Find references" "R" #'lsp-find-references
       :desc "Find implementations" "i" #'lsp-find-implementation
       :desc "Peek definition" "p" #'lsp-ui-peek-find-definitions
       :desc "Show documentation" "k" #'lsp-describe-thing-at-point
       :desc "Organize imports" "o" #'lsp-organize-imports
       :desc "Errors list" "x" #'lsp-treemacs-errors-list
       :desc "Symbols" "s" #'lsp-treemacs-symbols)

      ;; File operations
      (:prefix ("f" . "file")
       :desc "Find file" "f" #'find-file
       :desc "Recent files" "r" #'recentf-open-files
       :desc "Save file" "s" #'save-buffer
       :desc "Save as" "S" #'write-file
       :desc "Delete file" "D" #'doom/delete-this-file
       :desc "Rename file" "R" #'doom/move-this-file
       :desc "Copy file" "c" #'doom/copy-this-file
       :desc "Find in config" "p" #'doom/find-file-in-private-config
       :desc "Open config" "P" #'doom/open-private-config)

      ;; Git operations
      (:prefix ("g" . "git")
       :desc "Status" "g" #'magit-status
       :desc "Blame" "b" #'magit-blame
       :desc "Log" "l" #'magit-log
       :desc "Diff" "d" #'magit-diff
       :desc "Fetch" "f" #'magit-fetch
       :desc "Pull" "p" #'magit-pull
       :desc "Push" "P" #'magit-push
       :desc "Commit" "c" #'magit-commit
       :desc "Stage file" "s" #'magit-stage-file
       :desc "Unstage file" "u" #'magit-unstage-file
       :desc "Time machine" "t" #'git-timemachine
       :desc "Browse remote" "B" #'browse-at-remote)

      ;; Insert
      (:prefix ("i" . "insert")
       :desc "Snippet" "s" #'yas-insert-snippet
       :desc "Emoji" "e" #'emoji-search
       :desc "From clipboard" "y" #'yank)

      ;; Open
      (:prefix ("o" . "open")
       :desc "Treemacs" "p" #'+treemacs/toggle
       :desc "Terminal" "t" #'+vterm/toggle
       :desc "Terminal here" "T" #'+vterm/here
       :desc "Eshell" "e" #'+eshell/toggle
       :desc "Dired" "d" #'dired-jump
       :desc "Org agenda" "a" #'org-agenda
       :desc "Calendar" "c" #'calendar)

      ;; Project operations
      (:prefix ("p" . "project")
       :desc "Find file" "f" #'projectile-find-file
       :desc "Find dir" "d" #'projectile-find-dir
       :desc "Switch project" "p" #'projectile-switch-project
       :desc "Search project" "s" #'+default/search-project
       :desc "Replace in project" "r" #'projectile-replace
       :desc "Run command" "!" #'projectile-run-shell-command-in-root
       :desc "Compile" "c" #'projectile-compile-project
       :desc "Test" "t" #'projectile-test-project
       :desc "Add project" "a" #'projectile-add-known-project
       :desc "Remove project" "R" #'projectile-remove-known-project
       :desc "Invalidate cache" "i" #'projectile-invalidate-cache)

      ;; Quit/restart
      (:prefix ("q" . "quit")
       :desc "Quit" "q" #'save-buffers-kill-terminal
       :desc "Restart" "r" #'doom/restart
       :desc "Restart & restore" "R" #'doom/restart-and-restore)

      ;; Help
      (:prefix ("h" . "help")
       :desc "Describe bindings" "b" #'describe-bindings
       :desc "Keybindings cheatsheet" "K" #'my/open-keybindings-cheatsheet)

      ;; Search
      (:prefix ("s" . "search")
       :desc "Search buffer" "s" #'+default/search-buffer
       :desc "Search project" "p" #'+default/search-project
       :desc "Search directory" "d" #'+default/search-other-cwd
       :desc "Jump to symbol" "i" #'imenu
       :desc "Lookup online" "o" #'+lookup/online
       :desc "Dictionary" "D" #'+lookup/dictionary-definition)

      ;; Toggle
      (:prefix ("t" . "toggle")
       :desc "Line numbers" "l" #'display-line-numbers-mode
       :desc "Word wrap" "w" #'+word-wrap-mode
       :desc "Zen mode" "z" #'+zen/toggle
       :desc "Treemacs" "t" #'+treemacs/toggle
       :desc "Cycle theme" "c" #'my/cycle-theme
       :desc "Theme" "T" #'consult-theme
       :desc "Read only" "r" #'read-only-mode)

      ;; Window management
      (:prefix ("w" . "window")
       :desc "Split vertical" "v" #'split-window-right
       :desc "Split horizontal" "s" #'split-window-below
       :desc "Delete window" "d" #'delete-window
       :desc "Delete other windows" "m" #'delete-other-windows
       :desc "Maximize window" "M" #'doom/window-maximize-buffer
       :desc "Window left" "h" #'windmove-left
       :desc "Window down" "j" #'windmove-down
       :desc "Window up" "k" #'windmove-up
       :desc "Window right" "l" #'windmove-right
       :desc "Swap windows" "r" #'ace-swap-window
       :desc "Increase width" ">" #'enlarge-window-horizontally
       :desc "Decrease width" "<" #'shrink-window-horizontally
       :desc "Balance windows" "=" #'balance-windows))

;; ============================================
;; Language-Specific Settings
;; ============================================

;; Python
(after! python
  (setq python-shell-interpreter "python3"))

;; JavaScript/TypeScript
(after! js2-mode
  (setq js2-basic-offset 2
        js-indent-level 2))

;; Tree-sitter native modes (Emacs 29+)
(after! js-ts-mode
  (setq js-ts-mode-indent-offset 2))

(after! typescript-mode
  (setq typescript-indent-level 2))

(after! typescript-ts-mode
  (setq typescript-ts-mode-indent-offset 2))

(after! tsx-ts-mode
  (setq tsx-ts-mode-indent-offset 2))

;; Web (HTML/CSS)
(after! web-mode
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2))

;; Rust
(after! rustic
  (setq rustic-format-on-save t))

;; Go
(after! go-mode
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save))

;; ============================================
;; Performance Tweaks
;; ============================================

;; Faster startup
(setq gc-cons-threshold (* 100 1024 1024)  ; 100MB during GC
      read-process-output-max (* 3 1024 1024)  ; 3MB for LSP
      lsp-idle-delay 0.1)

;; Better scrolling performance
(setq fast-but-imprecise-scrolling t
      jit-lock-defer-time 0)

;; ============================================
;; Custom Functions
;; ============================================

(defun my/open-keybindings-cheatsheet ()
  "Open the keybindings cheatsheet from Doom's private dir."
  (interactive)
  (let ((path (expand-file-name "KEYBINDINGS-CHEATSHEET.md" doom-private-dir)))
    (if (file-exists-p path)
        (find-file path)
      (user-error "Cheatsheet not found: %s" path))))

(defun my/open-terminal-in-project-root ()
  "Open terminal in project root."
  (interactive)
  (let ((default-directory (or (projectile-project-root) default-directory)))
    (+vterm/here nil)))

(defun my/duplicate-line ()
  "Duplicate the current line."
  (interactive)
  (let ((text (buffer-substring (line-beginning-position) (line-end-position))))
    (end-of-line)
    (newline)
    (insert text)))

;; ============================================
;; Final Message
;; ============================================

(message "Doom Emacs ready (terminal mode) | C-c for quick keys | C-c P for command palette")
