;; Disable GUI elements
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq ring-bell-function #'ignore)
(setq make-backup-files nil)
(set-fringe-style '(1 . 1))
(blink-cursor-mode -1)
(setq require-final-newline t)
(setq-default indent-tabs-mode nil)

(savehist-mode 1)
(recentf-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(pixel-scroll-precision-mode 1)

(require 'package)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(setq custom-file "~/.config/emacs/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

(use-package evil
  :demand
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-define-key 'normal 'global (kbd "C-.") nil)
  (evil-define-key 'normal 'global (kbd "M-.") nil)
  (evil-mode 1))

(use-package solaire-mode
  :config
  (solaire-global-mode t))

(use-package doom-themes
  :config
  (load-theme 'doom-one t))

(use-package general
  :demand t
  :preface
  (general-evil-setup 'short)

  (general-create-definer
    my-leader
    :keymaps 'override
    :states '(emacs normal visual motion insert)
    :non-normal-prefix "C-SPC"
    :prefix "SPC"))

(use-package project
  :general
  (my-leader "p" project-prefix-map))

(use-package dired
  :ensure nil
  :config
  (setq dired-kill-when-opening-new-dired-buffer t)
  :general
  (my-leader "d" 'dired-jump))

(use-package embark-consult)

(use-package embark
  :general
  ("C-." 'embark-act)
  ("M-." 'embark-dwim)
  ("C-o" 'embark-export))

(use-package vertico
  :init
  (vertico-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-percent-position nil)
  (setq doom-modeline-check-simple-format t)
  (setq doom-modeline-icon nil)
  (setq doom-modeline-hud t)
  (setq doom-modeline-buffer-encoding 'nondefault))

(when (member "Iosevka" (font-family-list))
  (set-face-attribute 'default nil :font "Iosevka" :height 140))

(use-package diredfl
  :hook (dired-mode . diredfl-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  :demand t)

(use-package marginalia
  :init
  (marginalia-mode))

(define-key minibuffer-local-map (kbd "<escape>") 'abort-recursive-edit)

(use-package magit
  :config
  (setq magit-save-repository-buffers 'dontask)
  :general
  (my-leader "g g" 'magit))

(use-package consult
  :general
  (my-leader "f g" 'consult-ripgrep))

(evil-define-key 'normal org-mode-map (kbd "TAB") 'org-cycle)

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

(use-package flymake-collection
  :ensure t)

(add-hook 'js-mode-hook 'eglot-ensure)
(add-hook 'js-ts-mode-hook 'eglot-ensure)

(defun my/setup-python ()
  (setq-local forward-sexp-function nil))

(add-hook 'python-base-mode-hook #'my/setup-python)
(add-hook 'python-base-mode-hook #'eglot-ensure)

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(setq org-startup-folded t)
(setq org-confirm-babel-evaluate nil)
(setq org-babel-python-command "python3")

(setq org-latex-create-formula-image-program 'dvisvgm)

(setq org-directory "~/org")

(defun my/find-or-create-org-heading (topic)
  "Move point to top-level heading TOPIC, creating it at end of file if missing."
  (goto-char (point-min))
  (if (re-search-forward (format "^\\* %s$" (regexp-quote topic)) nil t)
      (beginning-of-line)
    (goto-char (point-max))
    (unless (bolp) (insert "\n"))
    (insert "* " topic "\n")
    (forward-line -1)))

(setq org-capture-templates
      '(("l" "Learning note" entry
         (file+function "~/org/notes.org"
                        (lambda ()
                          (my/find-or-create-org-heading
                           (read-string "Topic: "))))
         "* %^{Title}\n%U\n%?")
        ("j" "Journal entry" entry
         (file+olp+datetree "~/org/journal.org")
         "* %U %?\n")))

(use-package corfu
  :init
  (setq corfu-auto t)
  (global-corfu-mode))

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; Without this line it will try to use the old eglot version that came with my version of emacs.
(use-package eglot)

;; Set frame title, to remove ugly pop-os suffix
(setq frame-title-format "GNU Emacs")


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

(use-package web-mode
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-attr-indent-offset 2
        web-mode-attr-value-indent-offset 2)
  :mode ("\\.html\\'" . web-mode))

(global-set-key (kbd "C-c c") 'org-capture)
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

(use-package ox-hugo
  :ensure t
  :pin melpa
  :after ox)

(use-package popper
  :ensure t
  :init
  (setq popper-reference-buffers
        '("\\*Messages\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode
          compilation-mode))
  (popper-mode +1)
  (popper-echo-mode +1)
  :config
  (global-set-key (kbd "C-<dead-grave>") 'popper-toggle)
  (global-set-key (kbd "M-<dead-grave>") 'popper-cycle)
  (global-set-key (kbd "C-M-<dead-grave>") 'popper-toggle-type))

(use-package anzu
  :init (global-anzu-mode))

(use-package evil-anzu
  :demand t)

(use-package whitespace
  :hook (prog-mode . whitespace-mode)
  :config
  (setq whitespace-style '(face tab-mark tabs trailing)))

(use-package wgrep
  :ensure t
  :config
  (setq wgrep-auto-save-buffer t))

(use-package terraform-mode
  :custom (terraform-indent-level 4))

(use-package markdown-mode
  :ensure t)
