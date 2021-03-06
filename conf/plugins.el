;;; plugins.el --- main plugins configuration        -*- lexical-binding: t; -*-

;; Author: CryptoManiac <cryptomaniac.512@gmail.com>
;; Keywords: lisp

;;; Commentary:

;; This file contains my plugins configuration, requirements and hooks

;;; Code:

(use-package package-utils
    :ensure t)

(use-package nord-theme
    :ensure t
    :config
    (custom-set-variables
     '(nord-comment-brightness 10))
    (load-theme 'nord t))

(use-package evil
    :ensure t
    :config
    (evil-mode t)
    (evil-define-motion evil-tide-jump-to-definition ()
      :jump t
      :type exclusive
      (tide-jump-to-definition))
    (evil-define-motion evil-tide-jump-to-implementation ()
      :jump t
      :type exclusive
      (tide-jump-to-implementation))
    (define-key evil-normal-state-map "/" 'counsel-grep-or-swiper)
    (evil-add-command-properties #'racer-find-definition :jump t)
    (evil-add-command-properties #'racer-find-definition-other-window :jump t)
    (use-package evil-surround
	:ensure t
	:config
	(global-evil-surround-mode t))
    (use-package evil-leader
	:ensure t
	:config
	(global-evil-leader-mode t)
	(evil-leader/set-leader "'")
	(evil-leader/set-key "i" 'counsel-imenu)
	(evil-leader/set-key "sl" 'sort-lines)
	(evil-leader/set-key-for-mode 'python-mode
	    "D" 'xref-find-definitions-other-window
	    "d" 'xref-find-definitions
	    "G" 'elpy-goto-assignment-other-window
	    "g" 'elpy-goto-assignment
	    "k" 'elpy-doc
	    "n" 'elpy-occur-definitions
	    "r" 'elpy-refactor)
	(evil-leader/set-key-for-mode 'elisp-mode
	    "D" 'xref-find-definitions-other-window
	    "d" 'xref-find-definitions
	    "n" 'xref-find-references)
	(evil-leader/set-key-for-mode 'rust-mode
	    "d" 'racer-find-definition
	    "D" 'racer-find-definition-other-window
	    "k" 'racer-describe)
	(evil-leader/set-key-for-mode 'elm-mode
	    "k" 'elm-oracle-doc-at-point
	    "K" 'elm-oracle-type-at-point)
	(evil-leader/set-key-for-mode 'typescript-mode
	    "d" 'evil-tide-jump-to-definition
	    "t" 'evil-tide-jump-to-implementation
	    "k" 'tide-documentation-at-point
	    "n" 'tide-references
	    "r" 'tide-refactor
	    "R" 'tide-rename-symbol)
	(evil-leader/set-key-for-mode 'js2-mode
	    "d" 'evil-tide-jump-to-definition
	    "t" 'evil-tide-jump-to-implementation
	    "k" 'tide-documentation-at-point
	    "n" 'tide-references
	    "r" 'tide-refactor
	    "R" 'tide-rename-symbol)
	(evil-leader/set-key-for-mode 'web-mode
	    "d" 'evil-tide-jump-to-definition
	    "t" 'evil-tide-jump-to-implementation
	    "k" 'tide-documentation-at-point
	    "n" 'tide-references
	    "r" 'tide-refactor
	    "R" 'tide-rename-symbol)))

(use-package elpy
    :ensure t
    :config
    (elpy-enable)
    (setq elpy-rpc-backend "jedi")
    (remove-hook 'elpy-modules 'elpy-module-flymake)
    (remove-hook 'elpy-modules 'elpy-module-highlight-indentation)
    (remove-hook 'elpy-modules 'elpy-module-pyvenv)
    (remove-hook 'elpy-modules 'elpy-module-django))

(use-package virtualenvwrapper
    :ensure t
    :config
    (venv-initialize-interactive-shells)
    (venv-initialize-eshell)
    (setq venv-location "~/Devel/Envs/")
    (custom-set-variables
     '(python-environment-directory "~/Devel/Envs/")))

(use-package py-isort
    :ensure t
    :config
    (defun cm-py-isort-buffer-or-region ()
      "Call py-isort for region or for buffer."
      (interactive)
      (if (region-active-p)
	  (py-isort-region)
	(py-isort-buffer)))
    (add-hook 'python-mode-hook
	      (lambda ()
		(define-key python-mode-map (kbd "M-p M-i") 'cm-py-isort-buffer-or-region))))

(use-package vue-mode
    :ensure t)

(use-package emmet-mode
    :ensure t
    :config
    (add-hook 'sgml-mode-hook 'emmet-mode)
    (add-hook 'vue-html-mode-hook 'emmet-mode)
    (add-hook 'web-mode-hook 'emmet-mode))

(use-package markdown-mode
    :ensure t
    :commands (markdown-mode gfm-mode)
    :mode (("README\\.md\\'" . gfm-mode)
	   ("\\.md\\'" . markdown-mode)
	   ("\\.markdown\\'" . markdown-mode))
    :init (setq markdown-command "multimarkdown"))

(use-package yaml-mode
    :ensure t)

(use-package json-mode
    :ensure t)

(use-package toml-mode
    :ensure t)

(use-package sass-mode
    :ensure t)

(use-package rust-mode
    :ensure t
    :config
    (use-package racer
	:ensure t
	:config
	(add-hook 'rust-mode-hook #'racer-mode)
	(add-hook 'racer-mode-hook #'eldoc-mode)
	(add-hook 'racer-mode-hook #'company-mode)

	(defun racer-complete-at-point ()
	  "Complete the symbol at point."
	  (let* ((ppss (syntax-ppss))
		 (in-string (nth 3 ppss))
		 (in-comment (nth 4 ppss)))
	    (when (and
		   (not in-string)
		   (or (not in-comment) racer-complete-in-comments))
	      (let* ((bounds (bounds-of-thing-at-point 'symbol))
		     (beg (or (car bounds) (point)))
		     (end (or (cdr bounds) (point))))
		(list beg end
		      (completion-table-dynamic #'racer-complete)
		      :annotation-function #'racer-complete--annotation
		      :company-prefix-length (racer-complete--prefix-p beg end)
		      :company-docsig #'racer-complete--docsig
		      :company-doc-buffer #'racer--describe
		      :company-location #'racer-complete--location))))))
    (use-package flycheck-rust
	:ensure t
	:config
	(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)))

(use-package dockerfile-mode
    :ensure t)

(use-package js2-mode
    :ensure t
    :config
    (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode)))

(use-package tide
    :ensure t
    :config
    (add-hook 'typescript-mode-hook #'setup-tide-mode)
    (add-hook 'js2-mode-hook #'setup-tide-mode))

(use-package web-mode
    :ensure t
    :config
    (flycheck-add-mode 'typescript-tslint 'web-mode)
    (flycheck-add-mode 'javascript-eslint 'web-mode)

    (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
    (add-hook 'web-mode-hook
	      (lambda ()
		(when (string-equal "tsx" (file-name-extension buffer-file-name))
		  (define-key web-mode-map (kbd "C-c C-f") 'eslint-fix)
		  (setup-tide-mode))))

    (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
    (add-hook 'web-mode-hook
	      (lambda ()
		(when (string-equal "jsx" (file-name-extension buffer-file-name))
		  (setup-tide-mode)
		  (define-key web-mode-map (kbd "C-c C-f") 'eslint-fix)
		  (setq flycheck-disabled-checkers '(tsx-tide))))))

(use-package elm-mode
    :ensure t
    :config
    (add-to-list 'company-backends 'company-elm)
    (setq elm-format-on-save t)
    (use-package flycheck-elm
	:ensure t
	:config
	(flycheck-elm-setup))
    (add-hook 'elm-mode-hook
	      (lambda ()
		(define-key elm-mode-map (kbd "M-p M-i") 'elm-sort-imports))))

(use-package company
    :ensure t
    :config
    (global-company-mode)
    (setq company-idle-delay 0)
    (setq company-tooltip-align-annotations t)
    :bind (("C-x C-o" . company-complete)
	   :map company-active-map
	   ("C-n" . company-select-next)
	   ("C-p" . company-select-previous)
	   ("M-k" . company-show-doc-buffer)
	   ("C-d" . company-show-location)))

(use-package editorconfig
    :ensure t
    :config
    (editorconfig-mode t))

(use-package popwin
    :ensure t
    :config
    (popwin-mode t)
    (push '("*Buffer List*" :position bottom :height 20) popwin:special-display-config)
    (push '("*Completions*" :position bottom :height 24) popwin:special-display-config)
    (push '("*Flycheck errors*" :position bottom :height 24) popwin:special-display-config)
    (push '("*Flycheck error messages*" :position bottom :height 24) popwin:special-display-config)
    (push '("*Help*" :position bottom :height 24) popwin:special-display-config)
    (push '("*Racer Help*" :position bottom :height 20) popwin:special-display-config)
    (push '("*compilation*" :position bottom :height 24) popwin:special-display-config)
    (push '("*pytest*" :position bottom :height 24) popwin:special-display-config)
    (push '("*tide-documentation*" :position bottom :height 20) popwin:special-display-config))

(use-package flycheck
    :ensure t
    :config
    (global-flycheck-mode t))

(use-package yasnippet
    :ensure t
    :config
    (yas-global-mode t)
    (use-package yasnippet-snippets
	:ensure t))

(use-package counsel
    :ensure t
    :config
    (use-package ivy
	:config
      (ivy-mode t)
      (custom-set-variables
       '(ivy-height 15)
       '(ivy-use-virtual-buffers nil)
       '(ivy-use-selectable-prompt t)
       '(enable-recursive-minibuffers))
      (use-package flx
	  :ensure t
	  :config
	  (setq ivy-re-builders-alist
		'((t . ivy--regex-plus)))
	  (setq ivy-initial-inputs-alist nil))
      (use-package ivy-rich
	  :ensure t
	  :config
	  (ivy-set-display-transformer 'ivy-switch-buffer 'ivy-rich-switch-buffer-transformer)
	  (setq ivy-rich-abbreviate-paths t)
	  (setq ivy-rich-switch-buffer-name-max-length 40)
	  (setq ivy-rich-switch-buffer-mode-max-length 20)
	  (setq ivy-rich-switch-buffer-project-max-length 20)
	  (ivy-rich-mode t))
      (use-package wgrep
	  :ensure t)))

(use-package projectile
    :ensure t
    :config
    (projectile-mode t)
    ;; workaround for https://github.com/bbatsov/projectile/issues/1183
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
    (setq projectile-mode-line
	  '(:eval (format " Projectile[%s]"
		   (projectile-project-name))))
    (setq projectile-completion-system 'ivy)
    (use-package counsel-projectile
	:ensure t
	:after counsel
	:config
	(counsel-projectile-mode t)
	(defun counsel-projectile-switch-project-action (project)
	  "Jump to a file or buffer in PROJECT."
	  (let ((projectile-switch-project-action
		 (lambda ()
		   (if (magit-git-repo-p (projectile-project-root))
		       (magit-status)
		     (dired-other-window (projectile-project-root))))))
	    (counsel-projectile-switch-project-by-name project)))))

(use-package magit
    :ensure t
    :config
    (use-package evil-magit
	:ensure t)
    (use-package git-messenger
	:ensure t
	:config
	(custom-set-variables
	 '(git-messenger:show-detail t)
	 '(git-messenger:use-magit-popup t))
	:bind (("C-x p v" . git-messenger:popup-message)
	       :map git-messenger-map
	       ("m" . git-messenger:copy-message))))

(use-package git-link
    :ensure t)

(provide 'plugins)
;;; plugins.el ends here
