;;; -*- lexical-binding: t -*-

(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-style '(1 . 1))
(blink-cursor-mode -1)

(setq ring-bell-function #'ignore
      make-backup-files nil
      confirm-kill-emacs 'yes-or-no-p
      require-final-newline t
      frame-title-format "GNU Emacs")
(setq-default indent-tabs-mode nil)

(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(pixel-scroll-precision-mode 1)

(when (member "Iosevka" (font-family-list))
  (set-face-attribute 'default nil :font "Iosevka" :height 140))

(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(setq use-package-always-ensure t)

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror)

(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-define-key 'normal 'global (kbd "C-.") nil)
  (evil-define-key 'normal 'global (kbd "M-.") nil)
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package general
  :demand t
  :config
  (general-evil-setup 'short)
  (general-create-definer my-leader
    :keymaps 'override
    :states '(emacs normal visual motion insert)
    :non-normal-prefix "C-SPC"
    :prefix "SPC")
  (my-leader "b k" 'kill-current-buffer)
  (general-def minibuffer-local-map "<escape>" 'abort-recursive-edit))

(use-package anzu
  :init (global-anzu-mode))

(use-package apheleia
  :config
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "--preview"
          "--stdin-filename" filepath "-"))
  (setf (alist-get 'ruff-fix apheleia-formatters)
        '("ruff" "check" "--fix-only" "--exit-zero"
          "--stdin-filename" filepath "-"))
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-fix ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-fix ruff)
        (alist-get 'web-mode apheleia-mode-alist) 'prettier)
  (apheleia-global-mode +1))

(use-package consult
  :general
  (my-leader "f g" 'consult-ripgrep))

(use-package corfu
  :init
  (setq corfu-auto t)
  (global-corfu-mode))

(use-package dired
  :ensure nil
  :general
  (my-leader "d" 'dired-jump)
  :config
  (setq dired-kill-when-opening-new-dired-buffer t))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-percent-position nil
        doom-modeline-check-simple-format t
        doom-modeline-icon nil
        doom-modeline-hud t
        doom-modeline-buffer-encoding 'nondefault))

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

(use-package eglot
  :ensure nil
  :hook ((python-base-mode js-base-mode) . eglot-ensure))

(use-package embark
  :general
  ("C-." 'embark-act)
  ("M-." 'embark-dwim)
  ("C-o" 'embark-export))

(use-package embark-consult)

(use-package evil-anzu
  :demand t)

(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package magit
  :general
  (my-leader "g g" 'magit
             "g l" 'magit-log-buffer-file
             "g b" 'magit-blame-addition)
  :config
  (setq magit-save-repository-buffers 'dontask))

(use-package marginalia
  :init (marginalia-mode))

(use-package markdown-mode)

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic)))

(use-package org
  :ensure nil
  :bind ("C-c c" . org-capture)
  :general
  (nmap org-mode-map "TAB" 'org-cycle)
  :preface
  (defun my/find-or-create-org-heading (topic)
    "Move point to top-level heading TOPIC, creating it at end of file if missing."
    (goto-char (point-min))
    (if (re-search-forward (format "^\\* %s$" (regexp-quote topic)) nil t)
        (beginning-of-line)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert "* " topic "\n")
      (forward-line -1)))
  :config
  (setq org-directory "~/org"
        org-startup-folded t
        org-capture-templates
        '(("l" "Learning note" entry
           (file+function "notes.org"
                          (lambda ()
                            (my/find-or-create-org-heading
                             (read-string "Topic: "))))
           "* %^{Title}\n%U\n%?")
          ("j" "Journal entry" entry
           (file+olp+datetree "journal.org")
           "* %U %?\n"))))

(use-package popper
  :bind (("C-<dead-grave>"   . popper-toggle)
         ("M-<dead-grave>"   . popper-cycle)
         ("C-M-<dead-grave>" . popper-toggle-type))
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1))

(use-package project
  :ensure nil
  :general
  (my-leader "p" project-prefix-map))

(use-package python
  :ensure nil
  :hook (python-base-mode . my/setup-python)
  :preface
  (defun my/setup-python ()
    (setq-local forward-sexp-function nil)))

(use-package solaire-mode
  :config
  (solaire-global-mode t))

(use-package terraform-mode
  :custom (terraform-indent-level 4))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package vertico
  :init (vertico-mode))

(use-package web-mode
  :mode ("\\.html\\'" . web-mode)
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-attr-indent-offset 2
        web-mode-attr-value-indent-offset 2))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t))

(use-package whitespace
  :ensure nil
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-style '(face tab-mark tabs trailing)))
