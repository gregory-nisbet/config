;; Emacs.
(load-theme 'wombat)

(recentf-mode +1)
(winner-mode +1)

(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'y-or-n-p)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;(package-refresh-contents)
;;(package-install 'dumb-jump)

(require 'god-mode)
(require 'evil)
(require 'dumb-jump)

(add-hook 'xref-backend-functions #'dumber-jump-xref-activate)

;; (require 'evil)

;; This is not too bad. In the default keymap it turns on evil.
;; (global-set-key (kbd "C-z") #'evil-mode)

;; (define-key evil-normal-state-map (kbd "M-.") nil)

(defun god-mode-force-on ()
  (interactive)
  (god-mode-all +1)
  (god-local-mode +1))

(defun god-mode-force-off ()
  (interactive)
  (god-mode-all -1)
  (god-local-mode -1))

(global-set-key (kbd "M-c") #'god-mode-force-off)
;; delete is also inconvenient
(global-set-key (kbd "M-j") #'backward-delete-char-untabify)
(global-set-key (kbd "M-k") #'god-mode-force-on)
;; feels a little weird to bring in all of evil just for this
;; but whatever.
(global-set-key (kbd "C-%") #'evil-jump-item)

(global-set-key (kbd "C-c .") #'godef-jump)

(define-key god-local-mode-map (kbd "h") #'left-char)
(define-key god-local-mode-map (kbd "j") #'next-line)
(define-key god-local-mode-map (kbd "k") #'previous-line)
(define-key god-local-mode-map (kbd "l") #'right-char)
(define-key god-local-mode-map (kbd "i") #'god-mode-all)
(define-key god-local-mode-map (kbd "f") #'forward-word)
(define-key god-local-mode-map (kbd "b") #'backward-word)
(define-key god-local-mode-map (kbd "u") #'scroll-down-command)
(define-key god-local-mode-map (kbd "v") #'scroll-up-command)
