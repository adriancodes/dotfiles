;; -*- no-byte-compile: t; -*-
;;; packages.el --- Additional packages for Cursor-like experience
;;;
;;; Copy this file to ~/.doom.d/packages.el
;;; After editing, run: ~/.emacs.d/bin/doom sync

;; ============================================
;; AI Integration (The Cursor Magic ✨)
;; ============================================

;; Claude Code IDE integration
(package! claude-code-ide
  :recipe (:host github :repo "manzaltu/claude-code-ide.el"))

;; ChatGPT Shell - alternative chat interface
(package! chatgpt-shell)

;; Ellama - for local LLM support (Ollama)
(package! ellama)

;; ============================================
;; Editor Enhancements
;; ============================================

;; Better search/replace with visual feedback
(package! visual-regexp)
(package! visual-regexp-steroids)

;; Move text up/down easily
(package! move-text)

;; Highlight symbol under cursor (like VS Code)
(package! highlight-symbol)

;; Better parentheses highlighting
(package! rainbow-delimiters)

;; Show color codes as colors
(package! rainbow-mode)

;; Distraction-free writing
(package! olivetti)

;; ============================================
;; Git Enhancements
;; ============================================

;; Show git blame inline
(package! git-timemachine)

;; GitHub/GitLab browse from Emacs
(package! browse-at-remote)

;; ============================================
;; Project/File Management
;; ============================================

;; Fuzzy file finder enhancements
(package! consult-projectile)

;; Improved dired experience
(package! dired-single)
(package! all-the-icons-dired)

;; ============================================
;; Code Quality
;; ============================================

;; Auto-detect indent style
(package! dtrt-indent)

;; ============================================
;; Language-Specific
;; ============================================

;; Better Markdown support
(package! markdown-toc)

;; YAML folding
(package! yaml-pro)

;; ============================================
;; Quality of Life
;; ============================================

;; Better help system
(package! helpful)
(package! marginalia)

;; Persistent scratch buffer
(package! persistent-scratch)

;; Auto-save improvements
(package! super-save)

;; ============================================
;; Themes (Optional - pick your favorite)
;; ============================================

;; Popular VS Code-inspired themes
(package! vscode-dark-plus-theme)
(package! catppuccin-theme)
(package! modus-themes)
(package! ef-themes)

;; ============================================
;; Note: Some packages you might also want
;; (uncomment if needed)
;; ============================================

;; (package! obsidian)        ; Obsidian vault integration
;; (package! org-roam-ui)     ; Visual graph for org-roam
;;(package! notion)        ; Notion integration (not available)
;; (package! leetcode)        ; Practice leetcode in Emacs
