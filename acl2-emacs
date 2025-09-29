#!/bin/sh
":"; exec emacs -nw -q --load "$0" "$@"

;; Some creature comforts.
(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'y-or-n-p)

;; Some other basic creature comforts.
(recentf-mode +1)
(winner-mode +1)

;; might be controversial, makes emacs behave rather differently.
;; It is a reasonable choice for a vi(m) user though, since hjkl
;; behave the same way as vi.
;;
;; Still to do:
;; 1) % emulation.
;; 2) incorporate ACL2 indentation rules, they're different from the
;;    emacs defaults.
(defun postinit()
  (global-set-key (kbd "M-SPC") #'dabbrev-expand)

  (defun god-mode-force-on ()
    (interactive)
    (god-mode-all +1)
    (god-local-mode +1))

  (defun god-mode-force-off ()
    (interactive)
    (god-mode-all -1)
    (god-local-mode -1))

  (defun matching-parenthesis ()
    "emulate % in vi(m)."
    (interactive)
    (call-interactively #'backward-list))
  
  ;; Some of these keybindings are redundant and some of them are
  ;; unusable in a terminal emulator. That's fine none of them are a
  ;; load-bearing wall.
  (global-set-key (kbd "M-c") #'god-mode-force-off)
  ;; delete is also inconvenient
  (global-set-key (kbd "M-j") #'backward-delete-char-untabify)
  (global-set-key (kbd "M-k") #'god-mode-force-on)
  (global-set-key (kbd "C-,") #'previous-line)
  (global-set-key (kbd "C-.") #'repeat)
  (global-set-key (kbd "C-;") #'backward-delete-char-untabify)
  (global-set-key (kbd "C-S-k") #'kill-line)
  (global-set-key (kbd "C-S-j") #'join-line)
  ;; (global-set-key (kbd "C-%") #'matching-parenthesis)

  ;; On my keyboard, the left and right arrow keys are somewhat bad,
  ;; so let's use C-c j and C-c k do navigate buffers.
  (global-set-key (kbd "C-c j") #'previous-buffer)
  (global-set-key (kbd "C-c k") #'next-buffer)
  
  (define-key god-local-mode-map (kbd "h") #'left-char)
  (define-key god-local-mode-map (kbd "j") #'next-line)
  (define-key god-local-mode-map (kbd "k") #'previous-line)
  (define-key god-local-mode-map (kbd "l") #'right-char)
  (define-key god-local-mode-map (kbd "i") #'god-mode-all)
  (define-key god-local-mode-map (kbd "f") #'forward-word)
  (define-key god-local-mode-map (kbd "b") #'backward-word)
  (define-key god-local-mode-map (kbd "u") #'scroll-down-command)
  (define-key god-local-mode-map (kbd "v") #'scroll-up-command)

)



(progn

;; Copyright (C) 2013 Chris Done
;; Copyright (C) 2013 Magnar Sveen
;; Copyright (C) 2013 Rüdiger Sonderfeld
;; Copyright (C) 2013 Dillon Kearns
;; Copyright (C) 2013 Fabián Ezequiel Gallina
;; Copyright (C) 2020 Akhil Wali

;; Author: Chris Done <chrisdone@gmail.com>
;; URL: https://github.com/emacsorphanage/god-mode
;; Version: 2.18.0
;; Package-Requires: ((emacs "26.3"))

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Global minor mode for entering Emacs commands without modifier keys.

;;; Code:

(require 'cl-lib)

(add-hook 'after-change-major-mode-hook 'god-mode-maybe-activate)

(defvar god-local-mode-paused nil)
(make-variable-buffer-local 'god-local-mode-paused)

;; DEPRECATED
(defvaralias 'god-mod-alist 'god-mode-alist
  "Alias of `god-mode-alist' for backward compatibility.
Use `god-mode-alist' instead.")
(make-obsolete 'god-mod-alist 'god-mode-alist "2.16.1")

(defcustom god-mode-alist
  '((nil . "C-")
    ("g" . "M-")
    ("G" . "C-M-"))
  "List of keys and their associated modifer."
  :group 'god
  :type '(alist))

(defcustom god-literal-key
  "SPC"
  "The key used for literal interpretation."
  :group 'god
  :type 'string)

(defcustom god-exempt-major-modes
  '(Custom-mode
    Info-mode
    ag-mode
    calculator-mode
    calendar-mode
    cider-test-report-mode
    compilation-mode
    debugger-mode
    dired-mode
    edebug-mode
    ediff-mode
    eww-mode
    geben-breakpoint-list-mode
    git-commit-mode                     ; For versions prior to Magit 2.1.0
    grep-mode
    ibuffer-mode
    magit-popup-mode
    org-agenda-mode
    pdf-outline-buffer-mode
    recentf-dialog-mode
    sldb-mode
    sly-db-mode
    vc-annotate-mode
    wdired-mode)
  "List of major modes that should not start with `god-local-mode' enabled."
  :group 'god
  :type '(repeat symbol))

(defcustom god-exempt-predicates
  (list #'god-exempt-mode-p
        #'god-comint-mode-p
        #'god-git-commit-mode-p
        #'god-view-mode-p
        #'god-special-mode-p)
  "List of predicates checked before enabling `god-local-mode'.
All predicates must return nil for `god-local-mode' to start."
  :group 'god
  :type '(repeat function))

(defcustom god-mode-enable-function-key-translation t
  "Enables translation of function keys to use modifier keys.
For example, if this variable is non-nil, then entering `<f5>'
in God mode will be translated to `C-<f5>'."
  :group 'god
  :type 'boolean)

(defcustom god-mode-lighter-string
  "God"
  "String displayed on the mode line when God mode is active.
Set it to nil if you don't want a mode line indicator."
  :group 'god
  :type '(choice string (const :tag "None" nil)))

(defface god-mode-lighter
  '((t))
  "Face for God mode's lighter."
  :group 'god)

(defun god-mode-make-f-key (n &optional shift)
  "Get the event for numbered function key N, with shift status SHIFT.
For example, calling with arguments 5 and t yields the symbol `S-f5'."
  (intern (format "%sf%d" (if shift "S-" "") n)))

(defvar god-local-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map t)
    (define-key map [remap self-insert-command] 'god-mode-self-insert)
    (let ((i ?\s))
      (while (< i 256)
        (define-key map (vector i) 'god-mode-self-insert)
        (setq i (1+ i))))
    (when god-mode-enable-function-key-translation
      (dotimes (i 35)
        (define-key map (vector (god-mode-make-f-key (1+ i))) 'god-mode-self-insert)
        (define-key map (vector (god-mode-make-f-key (1+ i) t)) 'god-mode-self-insert)))
    (define-key map (kbd "DEL") nil)
    (define-key map (kbd "C-h k") #'god-mode-describe-key)
    map))

;;;###autoload
(define-minor-mode god-local-mode
  "Minor mode for running commands."
  :init-value nil
  :lighter (god-mode-lighter-string
            ((" "
             (:propertize god-mode-lighter-string face god-mode-lighter))))
  :keymap god-local-mode-map
  (if god-local-mode
      (run-hooks 'god-mode-enabled-hook)
    (run-hooks 'god-mode-disabled-hook)))

(defun god-local-mode-pause ()
  "Pause `god-local-mode' if it is enabled.
See also `god-local-mode-resume'."
  (when god-local-mode
    (god-local-mode -1)
    (setq god-local-mode-paused t)))

(defun god-local-mode-resume ()
  "Re-enable `god-local-mode'.
If it was not active when `god-local-mode-pause' was called, nothing happens."
  (when (bound-and-true-p god-local-mode-paused)
    (setq god-local-mode-paused nil)
    (god-local-mode 1)))

(defvar god-global-mode nil
  "Enable `god-local-mode' on all buffers.")

(defvar god-literal-sequence nil
  "Toggled when `god-literal-key' is pressed in a command sequence.")

;;;###autoload
(defun god-mode ()
  "Toggle global `god-local-mode'."
  (interactive)
  (setq god-global-mode (not god-global-mode))
  (if god-global-mode
      (god-local-mode 1)
    (god-local-mode -1)))

;;;###autoload
(defun god-mode-all (&optional arg)
  "Toggle `god-local-mode' in all buffers.

Toggle the mode if ARG is nil. If ARG is non-nil, enable the mode
if ARG is zero or a positive number, or disable the mode if ARG
is a negative number."
  (interactive)
  (let ((new-status
	 (cond
	  ((null arg) (if (bound-and-true-p god-local-mode) -1 1))
	  ((> 0 arg) -1)
	  (t 1))))
    (setq god-global-mode t)
    (mapc (lambda (buffer)
            (with-current-buffer buffer
              (god-mode-activate new-status)))
          (buffer-list))
    (setq god-global-mode (= new-status 1))))

(defun god-mode-maybe-universal-argument-more ()
  "If `god-local-mode' is enabled, call `universal-argument-more'."
  (interactive)
  (if god-local-mode
      (call-interactively #'universal-argument-more)
    (let ((binding (god-mode-lookup-command "u")))
      (if (commandp binding t)
          (call-interactively binding)
        (execute-kbd-macro binding)))))

(define-key universal-argument-map (kbd "u")
  #'god-mode-maybe-universal-argument-more)

(defun god-mode-self-insert ()
  "Handle self-insert keys."
  (interactive)
  (let* ((initial-key (aref (this-command-keys-vector)
                            (- (length (this-command-keys-vector)) 1)))
         (binding (god-mode-lookup-key-sequence initial-key)))
    (when binding
      ;; For now, set the shift-translation status only for alphabetic keys.
      (when (god-mode-upper-p initial-key)
        (setq this-command-keys-shift-translated t))
      (setq this-original-command binding)
      (setq this-command binding)
      ;; `real-this-command' is used by emacs to populate
      ;; `last-repeatable-command', which is used by `repeat'.
      (setq real-this-command binding)
      (setq god-literal-sequence nil)
      (if (commandp binding t)
          (call-interactively binding)
        (execute-kbd-macro binding)))))

(defun god-mode-upper-p (key)
  "Check if KEY is an upper case character not present in `god-mode-alist'."
  (and (characterp key)
       (not (member (char-to-string key) (mapcar #'car god-mode-alist)))
       (>= key ?A)
       (<= key ?Z)))

(defun god-mode-lookup-key-sequence (&optional key key-string-so-far)
  "Lookup the command for the given KEY (or the next keypress, if KEY is nil).
This function sometimes recurses.
KEY-STRING-SO-FAR should be nil for the first call in the sequence."
  (interactive)
  (let ((sanitized-key
         (god-mode-sanitized-key-string
          (or key (read-event key-string-so-far)))))
    (god-mode-lookup-command
     (god-key-string-after-consuming-key sanitized-key key-string-so-far))))

(defvar god-mode-sanitized-key-alist
  (append
   '((tab . "TAB")
     (?\  . "SPC")
     (left . "<left>")
     (right . "<right>")
     (up . "<up>")
     (down . "<down>")
     (prior . "<prior>")
     (next . "<next>")
     (backspace . "DEL")
     ;; FIXME delete key is not picked up `god-mode-self-insert'.
     (delete . "<delete>")
     (return . "RET")
     (S-iso-lefttab . "<S-iso-lefttab>")
     ;; Use key code for S-SPC
     (33554464 . "S-SPC")
     (S-left . "S-<left>")
     (S-right . "S-<right>")
     (S-up . "S-<up>")
     (S-down . "S-<down>")
     (S-backspace . "<S-backspace>")
     (S-delete . "<S-delete>")
     (S-return . "<S-return>"))
   ;; f1..f35 and S-f1..S-f35
   (cl-mapcan (lambda (i)
                (list (cons (god-mode-make-f-key i)   (format "<f%d>" i))
                      (cons (god-mode-make-f-key i t) (format "S-<f%d>" i))))
              (number-sequence 1 35)))
  "Association list mapping special events to their textual representations.")

(defun god-mode-sanitized-key-string (key)
  "Convert any special events in KEY to textual representation."
  (or (cdr (assq key god-mode-sanitized-key-alist))
      (char-to-string key)))

(defun god-mode-help-char-dispatch (_help-key key-string-so-far)
  "Invokes `prefix-help-command' by entering the key sequence KEY-STRING-SO-FAR
followed by the `help-char' key.
HELP-KEY contains the key that caused `god-mode-help-char-dispatch' to be called
from the command loop."
  ;; Adding an element (t . key) to `unread-command-events' will add key to
  ;; the current command's key sequence.
  (setq unread-command-events
        (cl-loop for key in (append (read-kbd-macro key-string-so-far t)
                                    (list help-char))
                 collect (cons t key)))
  ;; Return nil so that `god-mode-lookup-command' doesn't perform any action.
  nil)

(defun god-key-string-after-consuming-key (key key-string-so-far)
  "Interpret god-mode special keys for KEY.
Consumes more keys if appropriate.
Appends to key sequence KEY-STRING-SO-FAR."
  (let ((modifier "")
        (next-key (lambda () (god-mode-sanitized-key-string (read-event key-string-so-far)))))
    (message key-string-so-far)
    (when key-string-so-far ; Don't check for `god-literal-key' with the first key.
      (while (string= key god-literal-key)
        (setq god-literal-sequence (not god-literal-sequence)
              key (funcall next-key))))
    (unless god-literal-sequence
      (let ((modifier-lookup (and (stringp key) (assoc key god-mode-alist))))
        (if modifier-lookup
            (setq modifier (cdr modifier-lookup)
                  key (funcall next-key))
          (setq modifier (cdr (assoc nil god-mode-alist))))))
    (if (and key-string-so-far (string= key (format "%c" help-char)))
        (god-mode-help-char-dispatch key key-string-so-far)
      (when (and (= (length key) 1)
                 (string= (get-char-code-property (aref key 0) 'general-category) "Lu")
                 ;; If C- is part of the modifier, S- needs to be given
                 ;; in order to distinguish the uppercase from the
                 ;; lowercase bindings. If C- is not in the modifier,
                 ;; then emacs natively treats uppercase differently
                 ;; from lowercase, and the S- modifier should not be
                 ;; supplied.
                 (string-prefix-p "C-" modifier))
        (setq modifier (concat modifier "S-")))
      (if key-string-so-far
          (concat key-string-so-far " " modifier key)
        (concat modifier key)))))

(defun god-mode-lookup-command (key-string)
  "Execute extended keymaps in KEY-STRING, or call it if it is a command."
  (when key-string
    (let* ((key-vector (read-kbd-macro key-string t))
           (binding (key-binding key-vector)))
      (cond ((commandp binding)
             (setq last-command-event (aref key-vector (- (length key-vector) 1)))
             binding)
            ((keymapp binding)
             (god-mode-lookup-key-sequence nil key-string))
            (:else
             (error "God: Unknown key binding for `%s`" key-string))))))

;;;###autoload
(defun god-mode-maybe-activate (&optional status)
  "Activate `god-local-mode' on individual buffers when appropriate.
STATUS is passed as an argument to `god-mode-activate'."
  (when (not (minibufferp))
    (god-mode-activate status)))

(defun god-mode-activate (&optional status)
  "Activate `god-local-mode' on individual buffers when appropriate.
STATUS is passed as an argument to `god-local-mode'."
  (when (and god-global-mode
             (god-passes-predicates-p))
    (god-local-mode (if status status 1))))

(defun god-exempt-mode-p ()
  "Return non-nil if `major-mode' is exempt.
Members of the `god-exempt-major-modes' list are exempt."
  (memq major-mode god-exempt-major-modes))

(defun god-mode-child-of-p (mode parent-mode)
  "Return non-nil if MODE is derived from PARENT-MODE."
  (let ((parent (get mode 'derived-mode-parent)))
    (cond ((eq parent parent-mode))
          ((not (null parent))
           (god-mode-child-of-p parent parent-mode))
          (t nil))))

(defun god-comint-mode-p ()
  "Return non-nil if `major-mode' is derived from `comint-mode'."
  (god-mode-child-of-p major-mode 'comint-mode))

(defun god-special-mode-p ()
  "Return non-nil if `major-mode' is special or derived from `special-mode'."
  (eq (get major-mode 'mode-class) 'special))

(defun god-view-mode-p ()
  "Return non-nil if variable `view-mode' is non-nil in current buffer."
  view-mode)

(defun god-git-commit-mode-p ()
  "Return non-nil if a `git-commit-mode' will be enabled in this buffer."
  (and (bound-and-true-p global-git-commit-mode)
       ;; `git-commit-filename-regexp' defined in the same library as
       ;; `global-git-commit-mode'.  Expression above maybe evaluated
       ;; to true because of autoload cookie.  So we perform
       ;; additional check.
       (boundp 'git-commit-filename-regexp)
       buffer-file-name
       (string-match-p git-commit-filename-regexp buffer-file-name)))

(defun god-passes-predicates-p ()
  "Return non-nil if all `god-exempt-predicates' return nil."
  (not
   (catch 'disable
     (let ((preds god-exempt-predicates))
       (while preds
         (when (funcall (car preds))
           (throw 'disable t))
         (setq preds (cdr preds)))))))

;;;###autoload
(defun god-execute-with-current-bindings (&optional called-interactively)
  "Execute a single command from God mode, preserving current keybindings.

This command activates God mode temporarily, and deactivates God
mode as soon as the next command is run.  Prefix arguments do not
count as commands for this purpose, and do not cause God mode to
exit.  Moreover, any prefix argument that exists at the time of
this command's invocation is passed along to the next command.

Unlike normal use of God mode, this command makes available all
keybindings that were active at the time of its invocation,
including keybindings that are normally invisible to God mode,
such as those in `emulation-mode-map-alists' or text overlay
properties.  This makes it suitable for use with packages like
Evil that utilize such higher-priority keymaps.  (See Info
node `(elisp)Active Keymaps' for technical details on keymap
precedence.  For an alternative to this command, check out the
evil-god-state package, available on MELPA.)

This command has no effect when called from within God mode.

For interactive use only.  CALLED-INTERACTIVELY is a dummy
parameter to help enforce this restriction."
  (interactive "d")
  (if called-interactively
      (unless god-local-mode
        (message "Switched to God mode for the next command ...")
        (letrec ((caller this-command)
                 (buffer (current-buffer))
                 (cleanup
                  (lambda ()
                    ;; Perform cleanup in original buffer even if the command
                    ;; switched buffers.
                    (if (buffer-live-p buffer)
                        (with-current-buffer buffer
                          (unwind-protect (god-local-mode 0)
                            (remove-hook 'post-command-hook post-hook)))
                      (remove-hook 'post-command-hook post-hook))))
                 (kill-transient-map
                  (set-transient-map
                   god-local-mode-map 'god-prefix-command-p cleanup))
                 (post-hook
                  (lambda ()
                    (unless (and
                             (eq this-command caller)
                             ;; If we've entered the minibuffer, this implies
                             ;; a non-prefix command was run, even if
                             ;; `this-command' has not changed.  For example,
                             ;; `execute-extended-command' behaves this way.
                             (not (window-minibuffer-p)))
                      (funcall kill-transient-map)))))
          (add-hook 'post-command-hook post-hook)
          ;; Pass the current prefix argument along to the next command.
          (setq prefix-arg current-prefix-arg)
          ;; Technically we don't need to activate God mode since the
          ;; transient keymap is already in place, but it's useful to provide
          ;; a mode line lighter and run any hook functions the user has set
          ;; up.  This could be made configurable in the future.
          (god-local-mode 1)))
    (error "This function should only be called interactively")))

(defun god-prefix-command-p ()
  "Return non-nil if the current command is a \"prefix\" command.
This includes prefix arguments and any other command that should
be ignored by `god-execute-with-current-bindings'."
  (memq this-command '(god-mode-self-insert
                       digit-argument
                       negative-argument
                       universal-argument
                       universal-argument-more)))


(defvar god-latest-described-command nil
  "The latest command recorded by `god-mode-describe-key'.")

(defun god-mode--help-fn-describe-function (_arg)
  "Insert information about `god-mode' key-bindings for the described function.
The argument _ARG is ignored: it's only needed because all hooks in
`help-fns-describe-function-functions' take the function-name as argument.
But in our case it's redundant"
  (insert
   (format-message "\n  %s\n  %s%s\n  %s%s%s\n\n"
                   "(`god-local-mode' is enabled. "
                   " The given key-sequence: "
                   (god-mode-get-described-key-seq)
                   " corresponds to this key-binding: "
                   (if (> emacs-major-version 27)
                       (help--key-description-fontified
                        god-latest-described-command)
                     god-latest-described-command)
                   ")")))

(defun god-mode-get-described-key-seq ()
  "Return the keys that were pressed after `god-mode-describe-key' was called."
  (let* ((latest-keys (recent-keys 'include-cmds))
         (latest-describe-key-index
          (cl-position '(nil . god-mode-self-insert)
                       latest-keys :from-end t :test #'equal))
         (start-index (+ 3 latest-describe-key-index))
         (key-sequence (key-description (seq-subseq latest-keys start-index))))
    (if (> emacs-major-version 27)
        (propertize key-sequence
                    'font-lock-face 'help-key-binding
                    'face 'help-key-binding)
      key-sequence)))

(defun god-mode-describe-key ()
  "Describe a key-sequence as interpreted by `god-mode'.
Prompt for a key sequence, use `god-mode-lookup-key-sequence' to translate it
into the appropriate command, and use `describe-function' to describe it"
  (interactive)
  (message "Describe the following god-mode key: ")
  (advice-add #'god-mode-lookup-command :filter-args
              (lambda (key-string)
                (setq god-latest-described-command key-string)))
  ;; use unwind-protect, and remove the advice / hook in the unwind forms
  (unwind-protect
      (let ((command
             ;; if the key is not recognized by god-mode,
             ;; we will pass it to the regular `describe-key'
             (condition-case err
                 (god-mode-lookup-key-sequence)
               (wrong-type-argument
                ;; due to how errors are passed,
                ;; we do not have enough information
                ;; to pass menu items
                (if (not (equal (cddr err) '((menu-bar))))
                    (describe-key (vector (caddr err))))))))
        (if command
            (progn
              (add-hook 'help-fns-describe-function-functions
                        #'god-mode--help-fn-describe-function)
              (describe-function command))))
    ;; unwind forms:
    (advice-remove #'god-mode-lookup-command
                   (lambda (key-string)
                     (setq god-latest-described-command key-string)))
    (remove-hook 'help-fns-describe-function-functions
                 #'god-mode--help-fn-describe-function)))

(provide 'god-mode)

;;; god-mode.el ends here

)


(progn


;;; god-mode-isearch.el --- God mode behaviour for isearch  -*- lexical-binding: t; -*-

;; Copyright (C) 2014 Chris Done
;; Copyright (C) 2020 Akhil Wali

;; Author: Chris Done <chrisdone@gmail.com>
;; URL: https://github.com/emacsorphanage/god-mode
;; Version: 2.18.0
;; Package-Requires: ((emacs "26.3"))

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Global minor mode for entering Emacs commands without modifier keys.

;;; Code:

;; Recommended use:

;; (define-key isearch-mode-map (kbd "<escape>") 'god-mode-isearch-activate)
;; (define-key god-mode-isearch-map (kbd "<escape>") 'god-mode-isearch-disable)

(defvar god-mode-isearch-map
  (let ((map (copy-keymap isearch-mode-map)))
    (define-key map (kbd "s") 'isearch-repeat-forward)
    (define-key map (kbd "r") 'isearch-repeat-backward)
    (define-key map (kbd "w") 'isearch-yank-word-or-char)
    map)
  "Keymap for modal isearch.")

(defun god-mode-isearch-activate ()
  "Activate God mode in the isearch buffer."
  (interactive)
  (setq overriding-terminal-local-map god-mode-isearch-map))

(defun god-mode-isearch-disable ()
  "Deactivate God mode in the isearch buffer."
  (interactive)
  (setq overriding-terminal-local-map isearch-mode-map))

(provide 'god-mode-isearch)

;;; god-mode-isearch.el ends here

)



(progn

 ;; ACL2 Version 8.6 -- A Computational Logic for Applicative Common Lisp
 ;; Copyright (C) 2024, Regents of the University of Texas

 ;; This version of ACL2 is a descendent of ACL2 Version 1.9, Copyright
 ;; (C) 1997 Computational Logic, Inc.  See the documentation topic NOTE-2-0.

 ;; This program is free software; you can redistribute it and/or modify
 ;; it under the terms of the LICENSE file distributed with ACL2.

 ;; This program is distributed in the hope that it will be useful,
 ;; but WITHOUT ANY WARRANTY; without even the implied warranty of
 ;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ;; LICENSE file in the main ACL2 source directory for more details.

 ;; Written by:  Matt Kaufmann               and J Strother Moore
 ;; email:       Kaufmann@cs.utexas.edu      and Moore@cs.utexas.edu
 ;; Department of Computer Science
 ;; University of Texas at Austin
 ;; Austin, TX 78712 U.S.A.

;;; This file contains some emacs stuff for ACL2 users.  It is intended
;;; to work both with GNU Emacs and XEmacs.

;;; Suggestion: look at the final section, "Some other features you may want."

;;;; CONTENTS OF THIS FILE

;;;; Here we summarize the functionality offered by this file.  In many cases,
;;;; lower-level details may be found later in the file where the functionality
;;;; is actually provided.

;;; General shell stuff
 ;; Starts up a shell buffer, *shell*.
 ;; "meta-x new-shell" starts new shell buffers *shell-1*, *shell-2*, ....
 ;; "control-x k" redefined to avoid accidentally killing shell buffer.
 ;; "control-t e" sends the current form to the shell buffer.
 ;; "control-t b" switches to the shell buffer.
 ;; "control-t c" sets the shell buffer (initially, *shell*) to the current
 ;;      buffer
 ;; "control-t control-e" sends the current form to the shell buffer,
 ;;      but in a different window.  If the shell buffer is already
 ;;      visible in some window, use that window.  Otherwise, use the
 ;;      "other window" as defined by Emacs (see the Emacs
 ;;      documentation for `other-window').
 ;; "control-d" is redefined in shell/telnet buffers to avoid ending process.
 ;; "meta-p" and "meta-n" cycle backward/forward doing command completion in
 ;;      shell/telnet buffers.
 ;; "control-<RETURN>" sets shell/telnet directory buffer to current directory.
;;; From current buffer to shell buffer
 ;; "control-t l" prints appropriate ACL2 LD form to the end of the shell
 ;;      buffer, to cause evaluation of the active region in the current
 ;;      buffer.
 ;; "control-t control-l" prints just as above, but inhibits output and proofs;
 ;;      can easily be edited to inhibit only one or the other
 ;; "control-t u" puts an appropriate :ubt at the end of the shell buffer, based
 ;;      on the event in which you are currently standing.
;;; Some editing commands
 ;; "meta-x find-unbalanced-parentheses" locates unbalanced parentheses.
 ;; "control-t a" puts line with cursor at bottom of window.
 ;; "control-t <TAB>" completes filename in any buffer.
 ;; "control-t control-v" scrolls half as far as "control-v".
 ;; "control-t v" scrolls half as far as "meta-v".
 ;; "control-t s" searches forward non-interactively, with string supplied in
 ;;      minibuffer, case-sensitive
 ;; "control-t control-s":  like "control-t s" above, but case-insensitive (at
 ;;      least by default).
 ;; "control-meta-q" indents s-expression even when not in lisp-mode.
 ;; "control-t control-p" executes "meta-x up-list", moving to end of enclosing
 ;;      s-expression.
 ;; "control-t p" compares the current form with one obtained with
 ;;      meta-. (see below for more details).
 ;; "control-t w" does "meta-x compare-windows" (see emacs documentation,
 ;;      "control-h f compare-windows", for more info).
 ;; "control-t q" is like "control-t w" above, but ignores whitespace (and case
 ;;      too, with a positive prefix argument).
 ;; Lisp mode comes up with auto-fill mode on, right margin set at column 79,
 ;;      tabs interpreted using spaces, and a single ";" comment staying on the
 ;;      left margin (search for lisp-mode-hook below).
 ;;      If X Windows is being run, then font-lock-mode is also turned on,
 ;;      which causes Emacs to color text in .lisp files.  If you don't want
 ;;      colors in .lisp files, put this in your .emacs file after the load of
 ;;      "emacs-acl2.el":
 ;;      (if (equal window-system 'x)
 ;;          (remove-hook 'lisp-mode-hook '(lambda () (font-lock-mode 1))))
 ;; "meta-x visit-acl2-tags-table" sets the current tag table to the one in the
 ;;      ACL2 source directory.
 ;; "meta-," is defined to be tags-loop-continue, which is how it has
 ;;      traditionally been defined by Emacs but might be defined
 ;;      differently in some versions of Emacs 25 (and perhaps later).
 ;;      NOTE:
 ;;      Put (setq *preserve-tags-loop-continue* t) in your .emacs
 ;;      file before loading the present file, if you want to avoid
 ;;      redefining "meta-,".
 ;; "control-t f" fills format strings; see documentation for more info
 ;;      ("control-h f fill-format-string").
 ;; "control-t control-f" buries the current buffer (puts it on the bottom of
 ;;      the buffer stack, out of the way, without killing the buffer)
;;; ACL2 proof-tree support
 ;; NOTE: This works by default if you install the ACL2 community books, as
 ;;       most ACL2 users do, in the books/ directory of your ACL2
 ;;       distribution.  Otherwise, you will need to set the variable
 ;;       *acl2-interface-dir* to a directory string containing a file
 ;;       top-start-shell-acl2.el that defines the functions start-proof-tree
 ;;       and start-proof-tree-noninteractive in emacs.  For user-level
 ;;       documentation provided in the ACL2 community books implementation,
 ;;       see the following file included there:
 ;;       books/interface/emacs/PROOF-TREE-EMACS.txt
 ;; "meta-x start-proof-tree" starts proof-tree tracking in the current buffer
 ;;      (where ACL2 is running).  See ACL2 documentation for PROOF-TREE for
 ;;      more information.
 ;; Function start-proof-tree-noninteractive (see below) can be used to start
 ;;      proof-trees when emacs starts up; see below.
;;; Run ACL2 as inferior process
 ;; NOTE: This works by default if you install the ACL2 community books.
 ;;       Otherwise, see the NOTE above on "ACL2 proof-tree support".
 ;; "meta-x run-acl2" starts up acl2 as an inferior process in emacs.  You may
 ;;      have better luck simply issuing your ACL2 command in an ordinary
 ;;      (emacs) shell.
;;; ACL2 proof-builder support
 ;; "control-t d" prints an appropriate DV command at the end of the current
 ;;      buffer, suitable for diving to subexpression after printing with
 ;;      proof-builder "th" or "p" command and then positioning cursor on that
 ;;      subexpression.  See ACL2 documentation for PROOF-BUILDER.
 ;; "control-t control-d" is like "control-t d" above, but for DIVE instead
 ;;      (used with "pp" instead of "p")
;;; Load other tools
 ;; Support for Dynamic Monitoring of Rewrites (dmr)
 ;;   "control-t 1" to start dmr, "control-t 2" to stop dmr
 ;; Support for ACL2-Doc browser
 ;;   "control-t g" to start the ACL2-Doc browser
 ;; Support for xdoc-link-mode, used by acl2+books XDOC manual
;;; Miscellaneous
 ;; "meta-x acl2-info" brings up ACL2 documentation in pleasant emacs-info
 ;;      format.
 ;; "meta-x date" prints the current date and time (commented out).
 ;; "control-meta-l" swaps top buffer with next-to-top buffer (same as
 ;;      "control-x b <RETURN>").
 ;; "control-t" is a prefix for other commands
 ;; "control-t control-t" transposes characters (formerly "control-t")
 ;; Other features:
 ;;   Turn on time/mail display on mode line.
 ;;   Disable a few commands.
 ;;   Calls of case, case!, case-match, and dolist will indent like
 ;;      calls of defun.
;;; Some other features you may want (these are commented out by default):
 ;; Turn off menu bar.
 ;; Turn off emacs auto-save feature.
 ;; Start an abbrev table.
 ;; Avoid getting two windows, for example with control-x control-b.
 ;; Modify whitespace to ignore with "control-t q" (see above).
 ;; Turn on version control.
 ;; Arrange for "control-meta-l" to work as above even in rmail mode.
 ;; If time and "mail" displays icons, this may turn them into ascii.
 ;; Get TeX-style quotes with meta-".
 ;; Debug emacs errors with backtrace and recursive edit.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; EDIT THIS SECTION!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Edit the following to point to your ACL2 source directory.  This is not
;;; necessary, however, if this file is located in the emacs/ subdirectory of the
;;; ACL2 source directory (as is the case when it is distributed).
;;; Example:
;;; (defvar *acl2-sources-dir* "/u/acl2/v2-9/acl2-sources/")

;;; It is tempting to add the following code.  But we want the user to
;;; manage re-binding *acl2-sources-dir*, say by putting the following
;;; form in the .emacs file in front of the load of the present file.
;;; (if (boundp '*acl2-sources-dir*)
;;;     (makunbound '*acl2-sources-dir*))
 (defvar *acl2-sources-dir*)

;;; Attempt to set *acl2-sources-dir*.
;;; WARNING: If you change this form, then also change the same form in
;;; acl2-doc.el.
 (if (and (not (boundp '*acl2-sources-dir*))
          (file-name-absolute-p load-file-name))
     (let ((pattern (if (string-match "[\\]" load-file-name)
			"\[^\\]+\\*$"
                      "/[^/]+/*$"))
           (dir (file-name-directory load-file-name)))
       (let ((posn (string-match pattern dir)))
         (if posn
             (setq *acl2-sources-dir*
                   (substring dir 0 (1+ posn)))))))

;;; The following causes, for every event, the event name to be given
;;; the same color (in font-lock mode) as when defun is called.  If you
;;; don't like it, first copy this form into your .emacs file after the
;;; form that loads this emacs-acl2.el, and then change
;;; font-lock-add-keywords to font-lock-remove-keywords.  Because of the
;;; use of package prefixes in forms like (fty::deflist ...), we
;;; include a patch provided with permission from Keshav Kini that
;;; allows such package prefixes.  (Note that fty::deflist and
;;; std::deflist are different symbols, so they can't both be imported
;;; from the "ACL2" package.)

 (font-lock-add-keywords
  'lisp-mode
  '(("(\\(def\\w*\\)\\_>\\s *\\(\\(?:\\sw\\|\\s_\\)+\\)?"
     (1 font-lock-keyword-face nil t)
     (2 font-lock-function-name-face nil t))
    ("(\\(defattach\\|defevaluator\||defrefinement\\)\\_>\\s *\\(\\(?:\\sw\\|\\s_\\)+\\)?\\s *\\(\\(?:\\sw\\|\\s_\\)+\\)?"
     (1 font-lock-keyword-face nil t)
     (2 font-lock-function-name-face nil t)
     (3 font-lock-function-name-face nil t))
    ("(\\(comp\\|encapsulate\\|partial-encapsulate\\|in-theory\\|in-arithmetic-theory\\|include-book\\|local\\)\\>"
     . 1)
    ("(\\(make-event\\|memoize\\|unmemoize\\|mutual-recursion\\|profile\\|prog[^ \t]*\\)\\>"
     . 1)
    ("(\\(set-body\\|table\\|theory-invariant\\)\\>"
     . 1)
    ("(\\(value-triple\\|verify-guards\\|verify-termination\\)\\>"
     . 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Control-t keymap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defvar ctl-t-keymap)

 (when (not (boundp 'ctl-t-keymap))

;;; Warning: Keep this in sync with the introduction of ctl-t-keymap in
;;; acl2-doc.el.

;;; This trick probably came from Bob Boyer, to define a new keymap; so now
;;; control-t is the first character of a complex command.
   (setq ctl-t-keymap (make-sparse-keymap))
   (define-key (current-global-map) "\C-T" ctl-t-keymap)

;;; Control-t t now transposes characters, instead of the former control-t.
   (define-key ctl-t-keymap "\C-T" 'transpose-chars)
   (define-key ctl-t-keymap "\C-t" 'transpose-chars)
   )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; General shell stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; If you don't want to start up a shell when emacs starts but you load
;;; the present file emacs-acl2.el in your .emacs file, then put the
;;; following in your ~/.emacs file above the form that loads the
;;; present file:
;;;
;;; (defvar acl2-skip-shell nil)
;;; (setq acl2-skip-shell t)
;;;

 (defvar acl2-skip-shell nil)

;;; Start up a shell.  This also loads in comint-mode, used below.
 (if (not acl2-skip-shell)
     (shell)
;;; Otherwise load the shell package in case it's used somewhere.
   (load "shell"))

;;; Do meta-x new-shell to start a new shell.
 (defvar latest-shell-number 0)
 (load "shell")
 (defun new-shell ()
   "Start up a shell in a new buffer *shell-n*, where n is the
least positive integer for which buffer *shell-n* does not
currently exist and has never been created by this function."
   (interactive)
   (setq latest-shell-number (+ 1 latest-shell-number))
   (while (get-buffer (concat "*shell-"
			      (number-to-string latest-shell-number)
			      "*"))
     (setq latest-shell-number (+ 1 latest-shell-number)))
   (shell (concat "*shell-"
                  (number-to-string latest-shell-number)
                  "*")))

;;; Avoid killing shell buffers by accident:
 (defun kill-buffer-without-process (name)
   "Kill a buffer unless there's a process associated with it."
   (interactive
    (let (val
          (default-name (buffer-name (current-buffer)))
          (table
           (mapcar (function (lambda (x) (cons (buffer-name x) x))) (buffer-list))))
      (setq val (completing-read (format "Kill buffer: (default: %s) "
                                         default-name)
                                 table
                                 nil
                                 t))
      (list (if (equal val "")
		default-name val))))
   (if (get-buffer-process name)
       (error "Process is active in the indicated buffer.  Use meta-x kill-buffer instead.")
     (kill-buffer name)))

 (define-key (current-global-map) "\C-Xk" 'kill-buffer-without-process)

;;; Variable *acl2-shell* is the name of the "ACL2 shell", the buffer to which
;;; forms are written by various commands defined in this file.  Control-t c
;;; (defined below) changes the ACL2 buffer.
 (defvar *acl2-shell* "*shell*")

;;; Set the ACL2 shell to the current buffer.
 (define-key ctl-t-keymap "c" 'set-shell-buffer)
 (defun set-shell-buffer ()
   (interactive)
   (setq *acl2-shell* (buffer-name (current-buffer)))
   (message "Setting the ACL2 shell to buffer %s" *acl2-shell*)
   *acl2-shell*)

;;; Change to the ACL2 shell.
 (define-key ctl-t-keymap "b" 'switch-to-shell)
 (defun switch-to-shell ()
   (interactive)
   (let ((buf (get-buffer *acl2-shell*)))
     (unless buf
       (error "Nonexistent *acl2-shell* buffer: %s" *acl2-shell*))
     (switch-to-buffer buf)))

;;; Send the current form to the ACL2 shell.  Here, the "current form" is the one
;;; starting with the immediately preceding left parenthesis in column 0.  (It is
;;; OK to stand on that parenthesis as well.)
 (define-key ctl-t-keymap "e" 'enter-theorem)
 (define-key ctl-t-keymap "\C-e" 'enter-theorem-elsewhere)

;;; Old version (before v2-8) hardwires in the use of *shell*.
;;;(defalias 'enter-theorem
;;;  (read-kbd-macro
;;;   "C-e C-M-a NUL C-M-f ESC w C-x b *shell* RET M-> C-y"))

;;; Versions after v3-4 allow us to open up ACL2 scopes.
;;; See the documentation for enter-theorem.
;;; This code is relatively less tested; please send bug reports
;;; to the ACL2 implementors or contribute fixes.

 (defun acl2-scope-start-p ()
   (looking-at
    "(encapsulate[ \t]*\\(;;.*\\)?\n[ \t\n]*()[ \t]*;; start lemmas for"))

 (defun acl2-beginning-of-def ()
;;; See the documentation for enter-theorem.  We return nil unless we go
;;; to a preceding package marker, #!pkg, in which case we return t.
   (let ((saved-point (point))
         (ans nil))
     (end-of-line)
     (beginning-of-defun)
     (let ((temp-point (point)))
       (cond ((not (equal temp-point (point-min)))
              (forward-line -1)
              (cond ((looking-at "#!")
                     (setq ans t))
                    (t (goto-char temp-point))))))
     (cond ((acl2-scope-start-p)
            (goto-char saved-point)
            (if (not (looking-at "("))
		(backward-up-list))
            (let ((scope-p (acl2-scope-start-p)))
              (or scope-p
                  (progn (while (not scope-p)
                           (setq saved-point (point))
                           (backward-up-list)
                           (setq scope-p (acl2-scope-start-p)))
                         (goto-char saved-point))))))
     ans))

 (defun acl2-current-form-string (&optional ignore-pkg-marker)
   (save-excursion
     (end-of-line)
     (let ((temp (acl2-beginning-of-def)))
       (let ((beg (point)))
         (if (and temp (not ignore-pkg-marker))
             (forward-line 1))
         (forward-sexp)
         (buffer-substring beg (point))))))

 (defvar *acl2-insert-pats*

   '(:not ".*%[ ]*$" ".*$[ ]*$" "^$")

;;;; Another good default might be this "positive" list -- instead of
;;;; ruling out shell prompts as done just above, here we allow only
;;;; lines with known Lisp or ACL2 prompts.

;;; '(".*>[ ]*$"             ; ACL2, GCL, CLISP, LispWorks, CCL debugger
;;;   ".*[?] $"              ; CCL
;;;   ".*): $"               ; Allegro CL
;;;   ".*] $"                ; SBCL debugger
;;;   ".*[*] $"              ; CMUCL, SBCL
;;;  )

   "A list of regular expressions for enter-theorem-fn to allow on the
current line or, if the car is :not -- e.g., (:not \".*%[ ]*$\" \".*$[
]*$\" \"^$\") -- patterns to disallow.")

 (defun enter-theorem-fn (elsewhere)
   (let* ((str (acl2-current-form-string))
          (buf (get-buffer *acl2-shell*))
          (win (if elsewhere
                   (get-buffer-window buf)
                 (selected-window)))
          (patterns *acl2-insert-pats*))
     (unless buf
       (error "Nonexistent *acl2-shell* buffer: %s" *acl2-shell*))
;;; Go to the *acl2-shell* buffer
     (push-mark)
     (if win
         (select-window win)
       (other-window 1))
     (switch-to-buffer buf)
     (goto-char (point-max))
;;; Check that there is a process in the buffer
     (unless (get-buffer-process buf)
       (error "Error: This buffer has no process!"))
;;; Check that we have a valid prompt at which to place the form.
     (save-excursion
       (forward-line 0)
       (cond
	((null patterns))         ; nothing to check
	((eq (car patterns) :not) ; prompt must not match any of the regexps
         (while (setq patterns (cdr patterns))
           (when (looking-at (car patterns))
             (error "Error: Detected non-ACL2 prompt, matching \"%s\"; see *acl2-insert-pats*"
                    (car patterns)))))
	(t                      ; prompt must match one of the regexeps
         (let ((flg nil))
           (while patterns
             (cond ((looking-at (car patterns))
                    (setq flg t)
                    (setq patterns nil))
                   (t (setq patterns (cdr patterns)))))
           (or flg
               (error "Error: Couldn't detect ACL2 prompt; see *acl2-insert-pats*"))))))
;;; Insert the form
     (insert str)))

 (defun enter-theorem ()

   "Normally just insert the last top-level form starting at or before
the cursor, where a \"top-level\" form is one starting with a left
parenthesis on the left margin.  If that form is preceded by a line
starting with #!pkg-name, then that line is included in the inserted
string.

However, if that form is an ACL2 scope -- an encapsulate with empty
signature followed by \";; start lemmas for \" -- then first move up
if necessary to a left parenthesis, and then keep moving up until
hitting a \"top-level form\", i.e., either an ACL2 scope (in the above
sense) or else a form immediately under an ACL2 scope.  You can open a
scope with control-t o."

   (interactive)
   (enter-theorem-fn nil))

 (defun enter-theorem-elsewhere ()
   (interactive)
   (enter-theorem-fn t))

 (defun event-name ()
   (save-excursion
     (let ((beg (point)))
       (forward-sexp)
       (let ((pair (read-from-string (buffer-substring beg (point)))))
         (let ((expr (car pair)))
           (if (and (consp expr)
                    (consp (cdr expr)))
               (cadr expr)
             (error "Not in an event!")))))))

 (defun acl2-open-scope ()

   "Open a superior encapsulate that defines an ACL2 scope for the
current top-level form.  See the documentation for enter-theorem."

   (interactive)
   (save-excursion
     (acl2-beginning-of-def)
     (let ((name (event-name)))
       (beginning-of-line)
       (open-line 2)
       (lisp-indent-line)
       (insert "(encapsulate\n")
       (lisp-indent-line)
       (insert (format
		"() ;; start lemmas for %s"
		(or name "anonymous event")))
       (forward-sexp)
       (let ((end (point)))
         (backward-sexp)
         (insert " ")
         (indent-rigidly (point) end 1))
       (forward-sexp)
       (end-of-line)
       (open-line 1)
       (forward-line 1)
       (insert ")")
       (lisp-indent-line))))

 (define-key ctl-t-keymap "o" 'acl2-open-scope)

;;; The following avoids killing a process with control-d in the shell
;;; buffer, by reverting \C-d to whatever it was before comint-mode-map
;;; modified its binding.  Thanks to Keshav Kini for this suggestion (in
;;; place of our earlier solution of rebinding \C-d to delete-char).
 (define-key comint-mode-map "\C-d" nil)

;;; The following only seems necessary in gnu.
 (define-key comint-mode-map "\C-\M-l" 'c-m-l)

;;; Allow use of meta-p and meta-n for command completion.  Multiple
;;; meta-p/meta-n commands cycle backward/forward through previous matching
;;; commands.
;;; See also emacs lisp source file lisp/comint.el.
 (define-key comint-mode-map "\ep" 'comint-previous-matching-input-from-input)
 (define-key comint-mode-map "\en" 'comint-next-matching-input-from-input)

;;; Bind control-<RETURN> to the command that brings the current buffer's
;;; directory back to what it is supposed to be.
 (define-key global-map "\C-\M-M" 'shell-resync-dirs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Write region to shell
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; The next forms support control-t l (ell), which writes the current region to
;;; file "./temp-emacs-file.lsp" and puts an appropriate LD command in the shell
;;; buffer.

 (defvar *shell-temp-file-name* "temp-emacs-file.lsp")

 (if (boundp '*shell-temp-file-directory*)
     (makunbound '*shell-temp-file-directory*))
 (defvar *shell-temp-file-directory*)

 (defun set-shell-temp-file-directory ()
   (setq *shell-temp-file-directory*
         "./"))

 (defun shell-temp-file-name ()
   (expand-file-name *shell-temp-file-name* (set-shell-temp-file-directory)))

 (defun write-region-for-shell (beg end)
   "Writes the current region to the shell temp file, with the header
   string at the top and the footer string at the bottom and <return>
   separating each.
   Assumes beg < end."
   (let ((flg (buffer-modified-p)))
     (save-excursion
       (goto-char beg)
       (write-region beg end (shell-temp-file-name)))
     (set-buffer-modified-p flg)))

 (defun send-region-to-shell (message)
   "Writes the current region to the shell temp file and then puts one at the
   end of the ACL2 shell buffer, ready to submit that file."
   (unless (get-buffer *acl2-shell*)
     (error "Nonexistent *acl2-shell* buffer: %s" *acl2-shell*))
   (let ((beg (min (point) (mark)))
         (end (max (point) (mark))))
     (write-region-for-shell beg end)
     (switch-to-buffer *acl2-shell*)
     (goto-char (point-max))
     (insert message)))

 (defun acl2-load ()
   "Writes the current region to the shell temp file and then puts the cursor
   at the end of the ACL2 shell buffer, ready to execute an ld."
   (interactive)
;;; mark the current defun if there is no mark.
   (when (not mark-active)
     (mark-defun))
   (send-region-to-shell
    (concat (format
             ";; Ready to execute ACL2-LOAD -- hit <RETURN> when ready\n")
            (format "(acl2::ld \"%s\" :LD-PRE-EVAL-PRINT acl2::t :ld-error-action :return)"
                    (shell-temp-file-name)))))

 (defun acl2-load-inhibited ()
   "Writes the current region to the shell temp file and then puts the cursor
   at the end of the ACL2 shell buffer, ready to execute an ld with output
   inhibited and proofs skipped."
   (interactive)
;;; mark the current defun if there is no mark.
   (when (not mark-active)
     (mark-defun))
   (send-region-to-shell
    (concat (format
             ";; Ready to execute ACL2-LOAD -- hit <RETURN> when ready\n")
            (format "(acl2::with-output :off :all (acl2::ld \"%s\" :ld-error-action :return :ld-skip-proofsp t))"
                    (shell-temp-file-name)))))

 (define-key ctl-t-keymap "l" 'acl2-load)
 (define-key ctl-t-keymap "\C-l" 'acl2-load-inhibited)

 (defun acl2-event-name (form allow-local)
   (and (consp form)
	(let ((hd (car form))
              name)
          (cond ((eq hd 'encapsulate)
                 (let ((form-list (cdr (cdr form))))
                   (while form-list
                     (setq name (acl2-event-name (car form-list) nil))
                     (if name
                         (setq form-list nil) ; exit loop
                       (setq form-list (cdr form-list))))))
		((eq hd 'progn)
                 (let ((form-list (cdr form)))
                   (while form-list
                     (setq name (acl2-event-name (car form-list) allow-local))
                     (if name
                         (setq form-list nil) ; exit loop
                       (setq form-list (cdr form-list))))))
		((eq hd 'local)
                 (and allow-local
                      (setq name (acl2-event-name (car (cdr form)) t))))
		(t (setq name (and (consp (cdr form))
                                   (car (cdr form))))))
          (and (symbolp name)
               name))))

 (defun acl2-undo ()
   "Undoes back through the current event.  Current weaknesses: Doesn't
work for encapsulate or progn, and is ignorant of packages."
   (interactive)
   (unless (get-buffer *acl2-shell*)
     (error "Nonexistent *acl2-shell* buffer: %s" *acl2-shell*))
   (let ((name (acl2-event-name
		(car (read-from-string (acl2-current-form-string t)))
		t)))
     (cond (name (switch-to-buffer *acl2-shell*)
                 (goto-char (point-max))
                 (insert (format ":ubt! %s" name)))
           (t (error "ERROR: Unable to find event name for undoing.")))))

 (define-key ctl-t-keymap "u" 'acl2-undo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Some editing commands
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Contributed by Bill Bevier:
 (defun find-unbalanced-parentheses ()
   "Finds parenthesis mismatch error in buffer. Reads through all of the
current buffer and tries to find places in which the parentheses do not
balance. Positions point to possible trouble-spots, printing out a message
that says what the trouble appears to be.  This command only finds
one such error; if you suspect more errors, run it again."
   (interactive)
   (let ((saved-point (point)))
     (goto-char (point-min));; Go to start of buffer.
     (let (old-point)
       (setq old-point (point))
       (forward-sexp)
       (while (not (equal (point) old-point))
         (setq old-point (point))
         (forward-sexp)))
     (goto-char saved-point)
     (message "All parentheses appear balanced.")))

 (defun cursor-at-end-and-bottom ()
   "Put cursor at the end of the buffer on the bottom line"
   (interactive)
   (recenter -1))

;;; Control-t Control-a puts current line (line with cursor) at bottom of window:
 (define-key ctl-t-keymap "\C-a" 'cursor-at-end-and-bottom)

;;; Control-t <TAB> completes filename in any buffer:
 (define-key ctl-t-keymap "\t" 'comint-dynamic-complete-filename)

 (defun scroll-up-half ()
   (interactive)
   (scroll-up (/ (window-height) 2)))

 (defun scroll-down-half ()
   (interactive)
   (scroll-down (/ (window-height) 2)))

;;; Like control-v, but only half a screen:
 (define-key ctl-t-keymap "\C-V" 'scroll-up-half)

;;; Like meta-v, but only half a screen:
 (define-key ctl-t-keymap "v" 'scroll-down-half)

 (defun search-forward-with-case (string)
   (interactive "sSearch: ")
   (let ((case-fold-search nil))
     (search-forward string)))

;;; Case-sensitive forward search (i.e., searches forward non-interactively, with
;;; string supplied in minibuffer).
 (define-key ctl-t-keymap "s" 'search-forward-with-case)

;;; Forward search (case-insensitive by default):
 (define-key ctl-t-keymap "\C-s" 'search-forward)

 (define-key (current-global-map) "\C-\M-q" 'indent-sexp)

 (define-key ctl-t-keymap "\C-p" 'up-list)

;;; For the following, set compare-windows-whitespace to something other than "[
;;; \t\n]+"
;;; if desired.
 (defun approx-compare-windows (&optional ignore-case)
   "Compare windows, ignoring whitespace.  If optional argument is supplied,
then also ignore case if that argument is positive, else do not ignore case."
   (interactive "P")
   (if ignore-case
       (let ((compare-ignore-case (> ignore-case 0)))
         (compare-windows "0"))
     (compare-windows "0")))

;;; Set compare-windows-whitespace to something other than "[ \t\n]+"
;;; if desired.  Also consider compare-ignore-case.
 (define-key ctl-t-keymap "w" 'compare-windows)
 (define-key ctl-t-keymap "q" 'approx-compare-windows)

;;; The following keyboard macro compares two forms in a horizontal
;;; split of the current window.  The form in which the cursor resides,
;;; starting with an open parenthesis on the left margin, is compared
;;; (with compare-windows) to the form obtained by meta-. on the cadr of
;;; that form.  For example, if the form is (defun foo ...), then
;;; "control-t p" compares that form with the form produced by running
;;; "meta-." on foo.
 (if (string< emacs-version "25")
     (fset 'compare-acl2-patch
	   [?\C-x ?1 ?\C-n ?\C-e ?\C-\M-a ?\C-x ?2 ?\C-x ?o ?\C-f ?\C-\M-f ?\M-f
		  ?\M-b ?\M-. return ?\C-x ?o ?\C-t ?w])
;;; The Meta-. command changed in Emacs 25.  The resulting Ctl-t p
;;; command can be a bit awkward when there is more than one definition,
;;; but it's very workable with a bit of persistence.
   (fset 'compare-acl2-patch
	 [?\C-x ?1 ?\C-n ?\C-e ?\C-\M-a ?\C-x ?2 ?\C-x ?o ?\C-f ?\C-\M-f ?\M-f
		?\M-b ?\M-. ?\C-x ?o ?\C-t ?w]))
 (define-key ctl-t-keymap "p" 'compare-acl2-patch)

 (defun my-lisp-mode-hook ()
   (setq indent-tabs-mode nil)
   (setq comment-column 0)
   (turn-on-auto-fill)
   )

 (if (not (boundp 'lisp-mode-hook)) (setq lisp-mode-hook nil))
 (add-hook 'lisp-mode-hook 'my-lisp-mode-hook)

;;; Other modes can be put below as well (asm, c++, c, perl, emacs-lisp).
 (if (equal window-system 'x)
     (add-hook 'lisp-mode-hook #'(lambda () (font-lock-mode 1))))

 (defun acl2-sources-dir ()
   (let ((dir
          (if (boundp '*acl2-sources-dir*)
              *acl2-sources-dir*
            (setq *acl2-sources-dir*
                  (expand-file-name
                   (read-file-name
                    "*acl2-sources-dir* (e.g. /u/acl2/v2-9/acl2-sources/): "
                    nil nil t))))))
     (if (or (equal dir "")
             (let ((lastch (aref "abc/" (1- (length "abc/")))))
               (and (not (equal lastch ?/))
                    (not (equal lastch ?\\)))))
         (concat dir
                 (if (and (string-match "[\\]" dir)
                          (not (string-match "/" dir)))
                     "\\"
                   "/"))
       dir)))

 (defun visit-acl2-tags-table ()
   "Visit the tags table for ACL2."
   (interactive)
   (visit-tags-table (concat (acl2-sources-dir) "TAGS")))

 (when (not (and (boundp '*preserve-tags-loop-continue*)
                 *preserve-tags-loop-continue*))
   (define-key (current-global-map) "\M-," 'tags-loop-continue))

;;; Set the right margin (used when auto-fill-mode is on).
 (add-hook 'lisp-mode-hook
           #'(lambda ()
               (setq fill-column 79)))
;;; Formerly: (set-default 'fill-column 79)

;;; The function fill-format-string below probably originated from Bob
;;; Boyer in the early 1990s.  See documentation for fill-format-string.
;;; This is useful both for format and for ACL2's printing functions fmt
;;; and fms.  Enhanced Nov. 2010 by incorporating a version of code from
;;; Jared Davis, so that this works even when the cursor is within the
;;; string rather at the start of it.
 (define-key ctl-t-keymap "f" 'fill-format-string)

 (defun fill-format-string ()

   "Remove the ~<newline>'s from a Lisp format string, and put in new
ones, after any space, in such a way that the next space does not pass
fill-column.  The point (i.e., the cursor) should initially be at the
start of the string or anywhere within the string (but not on the
closing double-quote).  The final position of the cursor is the
beginning of the string that was processed."

   (interactive "")

;;; First move the point to the beginning of the string, if possible.

   (or (and (equal (char-after (point)) ?\")
            (not (equal (char-before (point)) ?\\)))
       (let ((pos (point))
             (not-done t))
         (while not-done
           (if (> pos 0)
               (if (equal (char-after pos) ?\")
                   (if (equal (char-before pos) ?\\)
                       (setq pos (1- pos))
                     (goto-char pos)
                     (setq not-done nil))
                 (setq pos (1- pos)))
             (error "Cannot find beginning of a format string to fill.")))))
   (save-excursion
     (let ((start-point (point))
           (fill (make-string (+ 1 (current-column)) ? )))
       (forward-sexp 1)
       (let ((end-point (point))
             (new-end nil))
         (save-restriction
           (narrow-to-region (+ 1 start-point)
                             (- end-point 1))
           (goto-char (point-min))
           (while (re-search-forward "~\n" nil t)
             (delete-char -2)
             (while (or (looking-at " ")
			(looking-at "\t")
			(looking-at "\n"))
               (delete-char 1)))
           (goto-char (point-max))
           (setq new-end (point)))
         (save-restriction
           (beginning-of-line)
           (narrow-to-region (point)
                             new-end)
           (goto-char (+ 1 start-point))
           (while (re-search-forward "[ \t]" nil t)
             (cond ((next-break-too-far)
                    (insert "~\n")
                    (insert fill)))))))))

 (defun next-break-too-far ()
   (let ((p (point)))
     (cond ((equal (point) (point-max))
            nil)
           (t (cond ((re-search-forward "[ \t\n]" nil t)
                     (prog1
                         (>= (current-column) fill-column)
                       (goto-char p)))
                    (t (goto-char (point-max))
                       (prog1
                           (>= (current-column) fill-column)
                         (goto-char p))))))))

;;; Bury the current buffer, putting it on the bottom of the buffer stack, out of
;;; the way, without killing the buffer).
 (define-key ctl-t-keymap "\C-F" 'bury-buffer)

;;; Make some functions' indentation behave as for defun.
 (put 'case         'lisp-indent-function 'defun)
 (put 'CASE         'lisp-indent-function 'defun)
 (put 'case!        'lisp-indent-function 'defun)
 (put 'CASE!        'lisp-indent-function 'defun)
 (put 'case-match   'lisp-indent-function 'defun)
 (put 'CASE-MATCH   'lisp-indent-function 'defun)
 (put 'dolist       'lisp-indent-function 'defun)
 (put 'DOLIST       'lisp-indent-function 'defun)
 (put 'er@par       'lisp-indent-function 'defun)
 (put 'ER@PAR       'lisp-indent-function 'defun)
 (put 'warning$@par 'lisp-indent-function 'defun)
 (put 'WARNING$@PAR 'lisp-indent-function 'defun)
;;; Jared Davis has contributed the following.  It is tempting to
;;; comment out those that aren't part of ACL2, but rather, are defined
;;; in books, since for those, a given name might have different
;;; reasonable syntax for different books.  However, in practice is
;;; seems unlikely that these will cause problems; if that assumption
;;; turns out to be wrong, perhaps a new Emacs file should be created
;;; for the books, and book-specific forms below should be moved there.
 (put 'B* 'lisp-indent-function 1)
 (put 'b* 'lisp-indent-function 1)
 (put 'ENCAPSULATE       'lisp-indent-function 'defun)
 (put 'encapsulate       'lisp-indent-function 'defun)
 (put 'MV-LET       'lisp-indent-function 'defun)
 (put 'mv-let       'lisp-indent-function 'defun)
 (put 'PATTERN-MATCH       'lisp-indent-function 'defun)
 (put 'pattern-match       'lisp-indent-function 'defun)
 (put 'PATTERN-MATCH-LIST       'lisp-indent-function 'defun)
 (put 'pattern-match-list       'lisp-indent-function 'defun)
 (put 'VERIFY-GUARDS  'lisp-indent-function 'defun)
 (put 'verify-guards  'lisp-indent-function 'defun)
 (put 'VERIFY-TERMINATION  'lisp-indent-function 'defun)
 (put 'verify-termination  'lisp-indent-function 'defun)
 (put 'WITH-ACL2-CHANNELS-BOUND 'lisp-indent-function 'defun)
 (put 'with-acl2-channels-bound 'lisp-indent-function 'defun)
 (put 'WITH-FAST-ALIST      'lisp-indent-function 'defun)
 (put 'with-fast-alist      'lisp-indent-function 'defun)
 (put 'WITH-FAST-ALISTS      'lisp-indent-function 'defun)
 (put 'with-fast-alists      'lisp-indent-function 'defun)
 (put 'WITH-GLOBAL-STOBJ     'lisp-indent-function 'defun)
 (put 'with-global-stobj     'lisp-indent-function 'defun)
 (put 'WITH-LOCAL-STOBJ      'lisp-indent-function 'defun)
 (put 'with-local-stobj      'lisp-indent-function 'defun)
 (put 'WITH-OPEN-FILE 'lisp-indent-function 'defun)
 (put 'with-open-file 'lisp-indent-function 'defun)
 (put 'WITH-OUTPUT 'lisp-indent-function 'defun)
 (put 'with-output 'lisp-indent-function 'defun)
 (put 'WITH-OUTPUT! 'lisp-indent-function 'defun)
 (put 'with-output! 'lisp-indent-function 'defun)
 (put 'WITH-OUTPUT-TO 'lisp-indent-function 'defun)
 (put 'with-output-to 'lisp-indent-function 'defun)
 (put 'WITH-STDOUT 'lisp-indent-function 'defun)
 (put 'with-stdout 'lisp-indent-function 'defun)
;;; Keshav Kini suggested special handling for er-let*; we add the
;;; following, long used by Matt K.
 (put 'er-let* 'lisp-indent-function 1)
 (put 'ER-LET* 'lisp-indent-function 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ACL2 proof-tree support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (if (boundp '*acl2-interface-dir*)
     (makunbound '*acl2-interface-dir*))
 (defvar *acl2-interface-dir*)

 (defun acl2-interface-dir ()
   (if (boundp '*acl2-interface-dir*)
       *acl2-interface-dir*
     (setq *acl2-interface-dir*
;;; common location (i.e., for those who install ACL2 community books in books/):
           (concat (acl2-sources-dir) "books/interface/emacs/"))))

 (autoload 'start-proof-tree
   (concat (acl2-interface-dir) "top-start-shell-acl2")
   "Enable proof tree logging in a prooftree buffer."
   t)

 (autoload 'start-proof-tree-noninteractive
   (concat (acl2-interface-dir) "top-start-shell-acl2")
   "Enable proof tree logging in a prooftree buffer."
   t)

;;; You may find it useful to put some version of the following two forms in your
;;; .emacs file.  It should start a new frame (perhaps after you click in the
;;; initial emacs window) to the side of the first frame, with the "prooftree"
;;; buffer displayed in the new frame.
;;; (start-proof-tree-noninteractive "*shell*")
;;; (cond ((and (eq window-system 'x)
;;;             (fboundp 'x-display-pixel-width)
;;;             (= (x-display-pixel-width) 2048) ; for a wide monitor
;;;             )
;;;        (delete-other-windows)
;;;        (if (boundp 'emacs-startup-hook) ; false in xemacs
;;;            (push 'new-prooftree-frame emacs-startup-hook))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Run ACL2 as inferior process in emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; You may have better luck simply issuing your ACL2 command in an ordinary
;;; (emacs) shell.  But in case anyone wants to try this:

 (autoload 'run-acl2
   (concat *acl2-interface-dir* "top-start-inferior-acl2")
   "Open communication between acl2 running in shell and prooftree."
   t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; ACL2 proof-builder support
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Insert  DV  command that gets to subexpression at the cursor.
;;; This is for use with the P and TH commands.
 (define-key ctl-t-keymap "d" 'dv-manual)

;;; Insert DIVE command that gets to subexpression at the cursor.
;;; This is for use with the PP command.
 (define-key ctl-t-keymap "\C-d" 'dive-manual)

;;; The rest of the functions in this section support \C-t d and \C-t \C-d.

 (defvar *acl2-pc-dive-syntax-table* nil)

 (defun maybe-set-acl2-pc-dive-syntax-table ()
   (cond ((null *acl2-pc-dive-syntax-table*)
          (setq *acl2-pc-dive-syntax-table*
		(copy-syntax-table (syntax-table)))
          (modify-syntax-entry ?- "w" *acl2-pc-dive-syntax-table*)
          (modify-syntax-entry ?: "w" *acl2-pc-dive-syntax-table*)
          (modify-syntax-entry ?_ "w" *acl2-pc-dive-syntax-table*)
          (modify-syntax-entry ?+ "w" *acl2-pc-dive-syntax-table*)
          (modify-syntax-entry ?* "w" *acl2-pc-dive-syntax-table*)
          (modify-syntax-entry ?. "w" *acl2-pc-dive-syntax-table*)
          *acl2-pc-dive-syntax-table*)))

 (defun dive-manual ()
   "Returns the 0-based address of the current s-expression inside
the expression beginning at the margin, assuming that the point
is properly inside the margin (otherwise causes an error), then
moves to the end of the buffer and plops down the appropriate DIVE
command for the proof-builder.  Causes an error if one is already
at the top."
   (interactive)
   (let ((addr (find-address)))
     (goto-char (point-max))
     (if (null addr)
         (error "Null address.")
       (insert (prin1-to-string (cons 'dive addr))))))

 (defun dv-manual ()
   "Returns the 0-based address of the current s-expression inside
the expression beginning at the margin, assuming that the point
is properly inside the margin (otherwise causes an error), then
moves to the end of the buffer and plops down the appropriate DV
command for the proof-builder. Causes an error if one is already at the top."
   (interactive)
   (let ((addr (find-address)))
     (goto-char (point-max))
     (if (null addr)
         (error "Null address.")
       (insert (prin1-to-string (cons 'dv addr))))))

 (defun beginning-of-current-defun ()
   "Causes an error if one is already at the beginning of defun, in
the sense of c-m-a"
;;;  (interactive)
   (let ((old-point (point)))
     (end-of-defun)
     (beginning-of-defun)
     (or (not (equal (point) old-point))
         (error "Already at the beginning of the expression."))))

 (defun find-address ()
   "Returns the 0-based address of the current s-expression inside
the expression beginning at the margin.  Leaves one at the original point."
   (maybe-set-acl2-pc-dive-syntax-table)
   (with-syntax-table
       *acl2-pc-dive-syntax-table*
     (let (quit-point old-point result)
       (setq old-point (point))
       (beginning-of-current-defun)
       (setq quit-point (point))
       (goto-char old-point)
       (while (not (equal (point) quit-point))
         (let ((n (move-up-one-level)))
;;; We drop trailing zeros.  It doesn't make sense to dive into a function
;;; symbol, and anyhow, the ACL2 function expand-address ignores trailing zeros.
           (unless (and (null result)
			(equal n 0))
             (setq result (cons n result)))))
       (goto-char old-point)
       result)))

 (defun move-up-one-level ()
   "Like backward-up-list, except that it returns the position
of the current s-expression in the enclosing list"
;;;  (interactive)
   (let (saved-point final-point n)
     (forward-sexp) ; puts us just past the end of current sexp
     (setq saved-point (point))
     (backward-up-list 1)
     (setq final-point (point))
     (forward-char 1)
     (forward-sexp)
     (setq n 0)
     (while (not (equal (point) saved-point))
       (setq n (1+ n))
       (forward-sexp))
     (goto-char final-point)
     n))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Load other tools
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Support for Dynamic Monitoring of Rewrites (dmr)
 (when t


;;; ACL2 Version 8.6 -- A Computational Logic for Applicative Common Lisp
;;; Copyright (C) 2024, Regents of the University of Texas

;;; This version of ACL2 is a descendent of ACL2 Version 1.9, Copyright
;;; (C) 1997 Computational Logic, Inc.  See the documentation topic NOTE-2-0.

;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the LICENSE file distributed with ACL2.

;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; LICENSE file in the main ACL2 source directory for more details.

;;; Written by:  Matt Kaufmann               and J Strother Moore
;;; email:       Kaufmann@cs.utexas.edu      and Moore@cs.utexas.edu
;;; Department of Computer Science
;;; University of Texas at Austin
;;; Austin, TX 78712 U.S.A.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; DOCUMENTATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; This file contains code for real-time monitoring of ACL2 rewrites
;;; (Dynamically Monitoring Rewrites, or "dmr").  This file is automatically
;;; loaded by emacs-acl2.el.

;;; We thank Robert Krug for useful contributions.

;;; To start (or restart) dynamically monitoring rewrites:
;;;   control-t 1
;;; To stop dynamically monitoring rewrites:
;;;   control-t 2
;;;   or just hide the monitoring buffer

;;; See also "User-settable variables" below.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; User-settable dmr variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; The following may be set by the user to any positive number of seconds.
;;; If you set this, consider also setting Common Lisp variable *dmr-interval*.
   (defvar *acl2-timer-display-interval*
     0.10)

   (defvar *dmr-buffer-name*
     (concat "acl2-dmr-" (getenv "USER")))

   (defvar *dmr-file-name*
;;; Keep this in sync with *dmr-file-name* in the ACL2 Common Lisp sources.
     (concat "/tmp/" *dmr-buffer-name*))

;;; See also "Debug" below, for advanced users.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Debug
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   (defvar *dmr-debug-p* nil)
   (defvar *dmr-debug-output* nil)
   (defvar *dmr-debug-output-raw* nil)
   (defun dmr-clear-debug ()
     (interactive)
     (when *dmr-debug-output*
       (setq *dmr-debug-output* nil))
     (when *dmr-debug-output-raw*
       (setq *dmr-debug-output-raw* nil)))
   (defun dmr-write-debug ()
     (insert (format "%S" (reverse *dmr-debug-output*))))
   (defun dmr-write-debug-raw ()
     (insert (format "%S" (reverse *dmr-debug-output-raw*))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   (defvar *dmr-delete-string*

;;; WARNING: Keep this in sync with corresponding ACL2 definition.

     "delete-from-here-to-end-of-buffer")

   (defvar *dmr-delete-string-length*
     (length *dmr-delete-string*))

   (defun acl2-start-of-region-to-be-deleted ()
     (goto-char (point-min))
     (and (search-forward *dmr-delete-string* nil t)
	  (match-beginning 0)))

   (defvar *dmr-previous-string* "")

   (defun dmr-star-lines-to-end ()
     (let ((max-1 (1- (point-max))))
       (while (progn (end-of-line)
		     (< (point) max-1))
	 (forward-char 1) ; past newline
	 (delete-char 1) ; delete space
	 (insert "*"))))

   (defvar *dmr-finished-string*
     "  No proof is in progress.
")

   (defun dmr ()
     (when (file-exists-p *dmr-file-name*)
       (let ((buf (get-buffer-create *dmr-buffer-name*)))
	 (if (get-buffer-window buf) ; Can we see the buffer?
             (with-current-buffer buf
               (let ((saved-point (point)))
		 (insert-file-contents-literally *dmr-file-name* nil nil nil t)
		 (let* ((new-string (buffer-string))
			(max (length new-string)))
                   (if (and (<= *dmr-delete-string-length* max)
                            (equal (substring new-string
                                              0
                                              *dmr-delete-string-length*)
                                   *dmr-delete-string*))

;;; This is the case where the proof has completed, indicated by nothing in the
;;; file before the delete string.

                       (progn (setq new-string *dmr-finished-string*)
                              (delete-region (point-min) (point-max))
                              (insert *dmr-finished-string*)
                              (setq *dmr-previous-string* nil))
                     (let ((common (and *dmr-previous-string*
					(compare-strings
					 new-string 0 max
					 *dmr-previous-string* 0 max))))
                       (if *dmr-debug-p*
                           (setq *dmr-debug-output-raw*
				 (cons (buffer-string) *dmr-debug-output-raw*)))
                       (setq *dmr-previous-string* new-string)
                       (let ((start (acl2-start-of-region-to-be-deleted)))
			 (and start (delete-region start (1+ max))))
                       (if (eq common t) ; very unlikely, given delete marker
                           (progn
                             (if (< saved-point (point-max))
				 (goto-char saved-point)
                               (goto-char (point-max)))
                             (if *dmr-debug-p*
				 (setq *dmr-debug-output*
                                       (cons (buffer-string) *dmr-debug-output*))))
			 (goto-char (if common
					(min (abs common) (point-max))
                                      (point-min)))
			 (beginning-of-line)
			 (if (< (point) (point-max))
                             (delete-char 1))
			 (let ((star-point (point)))
                           (insert "*")
                           (dmr-star-lines-to-end)
                           (if *dmr-debug-p*
                               (setq *dmr-debug-output*
                                     (cons (buffer-string) *dmr-debug-output*)))
                           (if (< saved-point star-point)
                               (goto-char saved-point)
                             (goto-char star-point)))))))))
           (acl2-stop-monitor)))))

   (defvar *dmr-timer* nil)

   (defun acl2-start-monitor ()
     (interactive)
     (when *dmr-timer*

;;; Restart the timer in case *acl2-timer-display-interval* has been changed.

       (cancel-timer *dmr-timer*))
     (setq *dmr-timer* (run-with-timer *acl2-timer-display-interval*
                                       *acl2-timer-display-interval*
                                       'dmr))
     (switch-to-buffer (get-buffer-create *dmr-buffer-name*)))

   (defun acl2-stop-monitor ()
     (interactive)
     (when *dmr-timer*
       (if (string-match "XEmacs" emacs-version)
           (if (fboundp 'delete-itimer)
	       (delete-itimer *dmr-timer*)
	     (error "delete-itimer is unbound;
please contact matthew.j.kaufmann@gmail.com"))
	 (cancel-timer *dmr-timer*))
       (setq *dmr-timer* nil)))

   (defvar ctl-t-keymap)

;;; The following won't be necessary if emacs/emacs-acl2.el is loaded first.
;;; Keep this in sync with that code (the two should be identical).
   (when (not (boundp 'ctl-t-keymap))

;;; This trick probably came from Bob Boyer, to define a new keymap; so now
;;; control-t is the first character of a complex command.
     (setq ctl-t-keymap (make-sparse-keymap))
     (define-key (current-global-map) "\C-T" ctl-t-keymap)

;;; Control-t t now transposes characters, instead of the former control-t.
     (define-key ctl-t-keymap "\C-T" 'transpose-chars)
     (define-key ctl-t-keymap "\C-t" 'transpose-chars)
     )

   (define-key ctl-t-keymap "0" 'dmr-clear-debug)
   (define-key ctl-t-keymap "1" 'acl2-start-monitor)
   (define-key ctl-t-keymap "2" 'acl2-stop-monitor)


   )


;;; Support for ACL2-Doc browser
 (when t




;;; ACL2 Version 8.6 -- A Computational Logic for Applicative Common Lisp
;;; Copyright (C) 2024, Regents of the University of Texas

;;; This version of ACL2 is a descendent of ACL2 Version 1.9, Copyright
;;; (C) 1997 Computational Logic, Inc.  See the documentation topic NOTE-2-0.

;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the LICENSE file distributed with ACL2.

;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; LICENSE file in the main ACL2 source directory for more details.

;;; Written by:  Matt Kaufmann               and J Strother Moore
;;; email:       Kaufmann@cs.utexas.edu      and Moore@cs.utexas.edu
;;; Department of Computer Science
;;; University of Texas at Austin
;;; Austin, TX 78712 U.S.A.

;;; Enhancements for multiple windows (added August 2021) were
;;; initially contributed by Mayank Manjrekar.

;;; This file contains code for browsing ACL2 community book
;;; system/doc/acl2-doc.lisp, which contains the ACL2 system
;;; documentation.

;;; The first two forms are copied from emacs-acl2.el.  Keep them in
;;; sync with the definitions there.

   (defvar *acl2-sources-dir*)

   (defvar *acl2-doc-show-extra*
;;; WARNING: Don't use defv (below) for this.  We don't want to
;;; reinitialize it after downloading an updated manual.
     "\nNOTE: Type D to download the latest version.")

;;; Attempt to set *acl2-sources-dir*.
;;; WARNING: If you change this form, then also change the same form in
;;; emacs-acl2.el.
   (if (and (not (boundp '*acl2-sources-dir*))
            (file-name-absolute-p load-file-name))
       (let ((pattern ; emacs/ and books/emacs/ differ here
              (if (string-match "[\\]" load-file-name)
		  "\[^\\]+\\*$"
		"/[^/]+/*$"))
             (dir (file-name-directory load-file-name)))
	 (let ((posn (string-match pattern dir)))
           (if posn
               (setq *acl2-sources-dir*
                     (substring dir 0 (1+ posn)))))))

   (require 'etags) ; for "/" and "W" commands, e.g., tags-lazy-completion-table

;;; Essay on ACL2-doc Data Structures

;;; Here we briefly summarize some of the main data structures used
;;; below.

;;; *acl2-doc-state*: This variable, initialized in acl2-doc-reset, is a
;;; pair (top-topic-name tuple-list).  Top-topic-name is the name of
;;; the top topic of the manual.  Tuple-list is a list of tuples,
;;; created in acl2-doc-alist-create, read from the rendered.lsp file
;;; but slightly fixed up.  For example, if the manual is the acl2-only
;;; manual, then (car (car (cdr *acl2-doc-state*))) is:
;;;   (&ALLOW-OTHER-KEYS (POINTERS) "See [macro-args].")

;;; (acl2-doc-state-alist): Reset if necessary, then return
;;; (nth 1 *acl2-doc-state*), which is a list of tuples as described
;;; above.

;;; *acl2-doc-history*: a buffer-local list of pairs (cons point tuple),
;;; *where tuple is a member of (acl2-doc-state-alist) and point is the
;;; *position in the topic of that tuple.  This is updated in
;;; *acl2-doc-display.

;;; End of Essay on ACL2-doc Data Structures.

   (defvar *acl2-doc-manual-alist* nil)
   (defvar *acl2-doc-manual-name* ; key into *acl2-doc-manual-alist*
     'combined)
   (defvar *acl2-doc-manual-name-previous* nil)
   (defvar *acl2-doc-short-new-buffer-names* nil)

   (defun acl2-doc-manual-alist-entry (pathname top printname url
						main-tags-file-name
						acl2-tags-file-name)
     (list pathname top printname url main-tags-file-name
           acl2-tags-file-name
           (concat (or (file-name-directory pathname) "") "acl2-doc-search")
           (concat (or (and url (file-name-directory url)) "") "acl2-doc-search.gz")))

   (defun extend-acl2-doc-manual-alist (key pathname top
                                            &optional
                                            printname
                                            url
                                            main-tags-file-name
                                            acl2-tags-file-name)
     (when (and url
		(not (and (stringp url)
			  (let ((len (length url)))
                            (and (> len 3)
				 (equal (substring url (- len 3) len)
					".gz"))))))
       (error "The URL specified for manual name %s does not end in \".gz\"."
              key))
     (let ((tuple (assoc key *acl2-doc-manual-alist*)))
       (cond
	(tuple
	 (setcdr tuple ; avoid setf; see my-cl-position
		 (acl2-doc-manual-alist-entry pathname top printname url
                                              main-tags-file-name
                                              acl2-tags-file-name))
	 *acl2-doc-manual-alist*)
	(t (push (cons key (acl2-doc-manual-alist-entry pathname top printname url
							main-tags-file-name
							acl2-tags-file-name))
		 *acl2-doc-manual-alist*)))))

   (extend-acl2-doc-manual-alist
    'combined
    (concat *acl2-sources-dir*
            "books/system/doc/rendered-doc-combined.lsp")
    'TOP
    "ACL2+Books Manual"
    "https://www.cs.utexas.edu/users/moore/acl2/manuals/current/rendered-doc-combined.lsp.gz"
    (concat *acl2-sources-dir* "TAGS-acl2-doc")
    (concat *acl2-sources-dir* "TAGS"))

   (extend-acl2-doc-manual-alist
    'acl2-only
    (concat *acl2-sources-dir* "doc.lisp")
    'ACL2
    "ACL2 User's Manual"
    nil
    nil
    (concat *acl2-sources-dir* "TAGS"))

   (defmacro defv (var form)
     `(progn (defvar ,var)
             (setq ,var ,form)))

   (defmacro defv-local (var form)
     `(progn (defvar-local ,var ,form)
             (put ',var 'permanent-local t))) ; required for saving
   ;; buffer-local values when
   ;; major mode is changed

   (defmacro acl2-doc-init-vars (first-time)
     `(progn
	(defv *acl2-doc-buffer-name* ; This is a constant.
	  "acl2-doc")
	(defv *acl2-doc-index-buffer-name*
	  "acl2-doc-index")
	(defv *acl2-doc-search-separator* "###---###---###---###---###")
	(defv *acl2-doc-search-buffer-name* "acl2-doc-search")
	(defv *acl2-doc-history-buffer-name* "acl2-doc-history")
	(defv *acl2-doc-all-topics-rev* nil)
	(defv *acl2-doc-state* nil)
	(defv *acl2-doc-children-ht* nil)
	(defv *acl2-doc-show-help-message* nil)
;;; Warning: Do not set *acl2-doc-show-extra* here (see comment in its
;;; introduction using defvar, above).
	(defv *acl2-doc-last-tags-file-name* nil)
	,@(and first-time
	       '((defv-local *acl2-doc-index-name* nil)
		 (defv-local *acl2-doc-index-name-found-p* nil)
		 (defv-local *acl2-doc-index-position* 1)
		 (defv-local *acl2-doc-search-string* nil)
		 (defv-local *acl2-doc-search-regexp-p* nil)
		 (defv-local *acl2-doc-search-position* 1)
		 (defv-local *acl2-doc-history* nil)
		 (defv-local *acl2-doc-return* nil)
		 (defv-local *acl2-doc-limit-topic* nil)
		 (defv-local *acl2-doc-topics-ht* nil)))))

   (acl2-doc-init-vars t)

;;; We define the following variable outside acl2-doc-init-vars, so that it is
;;; not smashed by invoking that macro after running acl2-doc-alist-create.
   (defv *acl2-doc-directory* nil)

   (defun my-cl-position (ch str)

;;;; We include this simple variant of cl-position because it is not
;;;; available in some versions of emacs (we have had a report of this
;;;; problem for GNU Emacs 24.3.1 on redhat).  We could (require 'cl)
;;;; or perhaps (require 'cl-lib), but some web pages suggest issues
;;;; with using cl functions (as opposed to macros).  I don't want to
;;;; think about any of that.

     (let ((continue t)
           (pos 0)
           (len (length str))
           (ans))
       (while (and continue (< pos len))
	 (when (eql (aref str pos) ch)
           (setq ans pos)
           (setq continue nil))
	 (setq pos (1+ pos)))
       ans))

   (defun acl2-doc-fix-symbol (sym)

;;;; Since Emacs Lisp doesn't seem to use |..| for escaping, we simply
;;;; remove those vertical bars that seem to have been placed by Common
;;;; Lisp.  NOTE: If this doesn't do the trick, consider modifying the
;;;; definition of function rendered-name-acl2-doc in file
;;;; books/system/doc/render-doc-base.lisp.

     (let* ((name (symbol-name sym))
            (pos (my-cl-position ?| name)))
       (cond ((null pos)                   ; common case
              sym)
             (t (let ((max (1- (length name))))
		  (cond ((eql max -1)      ; impossible?
			 sym)
			((not (eql (aref name max) ?|))
			 sym)
			((eql pos 0)
			 (intern (substring name 1 max)))
			((and (> pos 1)
                              (eql (aref name (- pos 1)) ?:)
                              (eql (aref name (- pos 2)) ?:))
			 (intern (concat (substring name 0 pos)
					 (substring name (1+ pos) max))))
			(t sym)))))))

   (defun acl2-doc-fix-entry (entry)
     (cons (acl2-doc-fix-symbol (car entry))
           (cons (let ((lst (cadr entry)))
                   (if (eq lst 'NIL)
                       ()
                     (let (ans)
                       (while lst
			 (push (acl2-doc-fix-symbol (pop lst))
                               ans))
                       (nreverse ans))))
		 (cddr entry))))

   (defun acl2-doc-fix-alist (alist)

;;;; We delete topics whose names start with a vertical bar.  Most of
;;;; these are for the tours anyhow.  We also lose release notes topics
;;;; for ACL2(r) from July 2011 and before, but that seems minor
;;;; compared to the pain of dealing with these topics, since Emacs
;;;; Lisp doesn't seem to use |..| for escaping.

     (let ((ans nil))
       (while alist
	 (let ((entry (pop alist)))
           (push (acl2-doc-fix-entry entry) ans)))
       (reverse ans)))

   (defun acl2-doc-large-file-warning-threshold ()

;;;; As of April 2019, file books/system/doc/rendered-doc-combined.lsp is
;;;; a bit over 100M bytes.  We take a guess here that modern platforms
;;;; can handle somewhat more than this size, so we rather arbitrarily
;;;; bump up the threshold for a warning, to provide a modest cushion for
;;;; avoiding the warning.

     (max (or large-file-warning-threshold 0)
	  120000000))

   (defun acl2-doc-alist-create (rendered-pathname)
     (when (not (file-exists-p rendered-pathname))
       (error "File %s is missing!" rendered-pathname))
     (let* ((large-file-warning-threshold (acl2-doc-large-file-warning-threshold))
            (buf0 (find-buffer-visiting rendered-pathname))

;;; We could let buf = buf0 if buf0 is non-nil.  But if the file was changed
;;; after loading it into buf0, then we would be operating on a stale buffer.  So
;;; we ignore buf0 other than to decide whether to delete the buffer just before
;;; returning from this function.

            (buf (progn (when buf0 ; avoid undo warning
			  (kill-buffer buf0))
			(message "Reading %s..."
				 rendered-pathname)
			(find-file-noselect rendered-pathname))))
       (with-current-buffer
           buf

;;; Warren Hunt asked that the acl2-doc buffer be put in the same directory as
;;; the file from which it was derived.  One basic advantage of this idea is that
;;; the directory won't depend on where acl2-doc was invoked.

	 (setq *acl2-doc-directory* default-directory)
	 (save-excursion
           (lisp-mode)
           (goto-char (point-min))
           (forward-sexp 1)
           (forward-line 3)
           (prog1 (acl2-doc-fix-alist (read buf))
             (when (not buf0)
               (kill-buffer buf))
             (message "Refreshed from %s" rendered-pathname))))))

   (defun acl2-doc-manual-entry (&optional manual-name)
     (let* ((manual-name (or manual-name *acl2-doc-manual-name*))
            (tuple (assoc manual-name *acl2-doc-manual-alist*)))
       (when (null tuple)
	 (error "No manual exists in %s with name %s."
		'*acl2-doc-manual-alist*
		manual-name))
       (cdr tuple)))

   (defun acl2-doc-manual-name ()
     *acl2-doc-manual-name*)

   (defun acl2-doc-pathname (&optional must-exist)
     (let ((pathname (nth 0 (acl2-doc-manual-entry))))
       (cond
	((null pathname)
	 (error "No pathname was specified in %s for manual name %s."
		'*acl2-doc-manual-alist*
		*acl2-doc-manual-name*))
	((and must-exist
              (not (file-exists-p pathname)))
	 (error "The file %s (for manual name %s) does not exist."
		pathname
		(acl2-doc-manual-name)))
	(t pathname))))

   (defun acl2-doc-top-name ()
     (nth 1 (acl2-doc-manual-entry)))

   (defun acl2-doc-manual-printname ()
     (or (nth 2 (acl2-doc-manual-entry))
	 (format "manual named `%s'"
		 (acl2-doc-manual-name))))

   (defun acl2-doc-url (&optional strict)
     (or (nth 3 (acl2-doc-manual-entry))
	 (and strict
              (error "No URL was specified for manual name %s."
                     *acl2-doc-manual-name*))))

   (defun acl2-doc-main-tags-file-name ()
     (nth 4 (acl2-doc-manual-entry)))

   (defun acl2-doc-acl2-tags-file-name ()
     (nth 5 (acl2-doc-manual-entry)))

   (defun acl2-doc-search-file-name ()
     (nth 6 (acl2-doc-manual-entry)))

   (defun acl2-doc-search-url ()
     (nth 7 (acl2-doc-manual-entry)))

   (defun acl2-doc-set-manual (manual-name)
;;; returns manual-name, except, error if manual-name names no manual
     (acl2-doc-manual-entry manual-name)
     (setq *acl2-doc-manual-name* manual-name))

   (defun acl2-doc-state-initialized-p ()
     (not (null *acl2-doc-state*)))

   (defun acl2-doc-gzipped-file (filename)
     (concat filename ".gz"))

   (defun acl2-doc-download-aux-1 (file-url file-pathname)
     (let ((file-backup (concat file-pathname ".backup"))
           (file-gzipped (acl2-doc-gzipped-file file-pathname)))
       (cond ((file-exists-p file-pathname)
              (message "Renaming %s to %s"
                       file-pathname
                       file-backup)
              (rename-file file-pathname file-backup 0)))
       (message "Preparing to download URL\n%s\ninto file\n%s"
		file-url file-gzipped)
       (url-copy-file file-url file-gzipped)
       (cond ((file-exists-p file-gzipped)
              (cond
               ((eql 0 (nth 7
                            (file-attributes ; size
                             file-gzipped)))
		(delete-file file-gzipped)
		(error
		 "Download/install failed (deleted zero-length file, %s)"
		 file-gzipped))
               (t
		(shell-command-to-string
		 (format "gunzip %s"
			 file-gzipped))
		(or (file-exists-p file-pathname)
                    (error "Gunzip failed")))))
             (t (error "Download/install failed")
		nil))))

   (defvar acl2-doc-download-error "")

   (defun acl2-doc-download-aux (url pathname)
     (condition-case err
	 (acl2-doc-download-aux-1 url pathname)
       (error
	(progn
	  (setq acl2-doc-download-error
		(format "You can copy URL %s
directly to file %s
and then apply gunzip to that file."
			url
			(acl2-doc-gzipped-file pathname)))
	  (error "Download failed (message: %s).
The following message is saved in Emacs variable acl2-doc-download-error:
%s"
		 (error-message-string err)
		 acl2-doc-download-error)))))

   (defun acl2-doc-download ()
     "Download the ``bleeding edge'' ACL2+Books Manual from the web;
then restart the ACL2-Doc browser to view that manual."
     (interactive)
     (acl2-doc-download-aux (acl2-doc-url t) (acl2-doc-pathname))

;;;; The following call of acl2-doc-reset may appear to have the
;;;; potential to cause a loop: acl2-doc-reset calls acl2-doc-fetch,
;;;; which calls the present function.  However, acl2-doc-fetch is
;;;; essentially a no-op in this case because of the file-exists-p
;;;; check made in the first call above of acl2-doc-download-aux.

     (acl2-doc-reset (acl2-doc-manual-name))
     (acl2-doc-top)
     (acl2-doc-download-aux (acl2-doc-search-url) (acl2-doc-search-file-name)))

   (defun manual-index-pathname ()
     (let* ((rendered (acl2-doc-pathname))
	    (rendered-length (length rendered))
	    (suffix "system/doc/rendered-doc-combined.lsp")
	    (suffix-length (length suffix)))
;;;; Sanity check (use (setq debug-on-error t) to see backtrace):
       (or (and (<= suffix-length rendered-length)
		(equal (substring rendered (- rendered-length suffix-length))
		       "system/doc/rendered-doc-combined.lsp"))
	   (error "Implementation error in acl2-doc: unexpected suffix"))
       (concat
	(substring rendered 0 (- rendered-length suffix-length))
	"doc/manual/index.html")))

   (defun acl2-doc-fetch ()
     (let* ((pathname (acl2-doc-pathname))
	    (pathname-exists (file-exists-p pathname))
	    (url (acl2-doc-url))
	    (pathname-gz (and url (acl2-doc-gzipped-file pathname)))
	    (manual-index-pathname (and url (manual-index-pathname))))
       (cond
	((and pathname-exists
	      (or (null url) ;; no download option
		  (null manual-index-pathname) ; no writes dates to compare
		  (file-newer-than-file-p pathname manual-index-pathname)
		  (yes-or-no-p ; minibuffer display is better than y-or-n-p
		   "Use outdated manual?  (Reply no for download option.) "))))
	((and (and pathname-gz
		   (file-exists-p pathname-gz))
	      (y-or-n-p
	       (format
		"Run gunzip on %s%s? "
		pathname-gz
		(if (and manual-index-pathname
			 (file-newer-than-file-p pathname
						 manual-index-pathname))
		    ""
		  ", even though you can download a newer version"))))
	 (shell-command-to-string
	  (format "gunzip %s"
		  pathname-gz))
	 (or (file-exists-p pathname)
	     (error "Execution of gunzip seems to have failed!")))
	((and url
	      (y-or-n-p
	       (format "Download %s and install as %s? "
		       url pathname)))
	 (acl2-doc-download))
	((or pathname-exists url)
	 (error "Update of manual aborted"))
	(t (error
	    "File %s not found, and\nno URL specified for the manual named %s"
	    pathname *acl2-doc-manual-name*)))))

   (defun acl2-doc-reset (manual-name)
     (let ((old-name (acl2-doc-manual-name)))
       (cond ((null manual-name)
              (setq manual-name old-name))
             ((not (eq old-name manual-name))
              (setq *acl2-doc-manual-name-previous* old-name)
              (acl2-doc-set-manual manual-name)))
       (acl2-doc-fetch)
       (let ((new-state (list (acl2-doc-top-name)
                              (acl2-doc-alist-create (acl2-doc-pathname t)))))
	 (when (get-buffer *acl2-doc-index-buffer-name*)
           (kill-buffer *acl2-doc-index-buffer-name*))
	 (when (get-buffer *acl2-doc-search-buffer-name*)
           (kill-buffer *acl2-doc-search-buffer-name*))
	 (acl2-doc-kill-buffers t)
	 (acl2-doc-init-vars nil)
	 (setq *acl2-doc-state* new-state)
	 t)))

   (defun acl2-doc-maybe-reset ()
     (cond ((not (acl2-doc-state-initialized-p))
            (acl2-doc-reset nil)
            t)
           (t nil)))

   (defun acl2-doc-state-top-name ()
     (acl2-doc-maybe-reset)
     (nth 0 *acl2-doc-state*))

   (defun acl2-doc-state-alist ()
     (acl2-doc-maybe-reset)
     (nth 1 *acl2-doc-state*))

;;; Based on http://ergoemacs.org/emacs/elisp_syntax_coloring.html:
   (defvar acl2-doc-keywords
     '(("\\[\\([^ \t]*[^0-9 \t][^ \t]*\\)\\]"
	. 1)))

;;; Can be modified by user; set to the desired link color, or nil if none.
   (defv *acl2-doc-link-color* "#0000FF") ; blue
   (make-face 'acl2-doc-link-face)

   (define-derived-mode acl2-doc-mode
     fundamental-mode
     "ACL2-Doc"
     "Major mode for acl2-doc buffer."

;;; By using lisp-mode-syntax-table, we arrange that the use of colon
;;; (:) doesn't break up an s-expression.  So for example,
;;; ACL2-PC::REWRITE is a single s-expression.  This matters because we
;;; define the function acl2-doc-topic-at-point in terms of
;;; backward-sexp.  Of course, we could instead evaluate the form
;;; (modify-syntax-entry ?: "w" acl2-doc-mode-syntax-table) but we start
;;; this way, in case other characters are missing and also because this
;;; approach might conceivably be useful for people who are navigating
;;; lisp forms in the acl2-doc buffer.

     :syntax-table (copy-syntax-table lisp-mode-syntax-table))

   (add-hook 'acl2-doc-mode-hook
             (lambda ()
               (when *acl2-doc-link-color*
		 (set-face-foreground 'acl2-doc-link-face *acl2-doc-link-color*)
		 (setq font-lock-defaults '(acl2-doc-keywords t))
		 (set (make-local-variable 'font-lock-keyword-face)
                      'acl2-doc-link-face))))

;;; Arrange that files ending in .acl2-doc come up in acl2-doc mode.
;;; See also the emacs documentation for auto-mode-alist.
   (if (not (assoc "\\.acl2-doc\\'" auto-mode-alist))
       (push '("\\.acl2-doc\\'" . acl2-doc-mode) auto-mode-alist))

   (defvar *acl2-doc-buffer-name-pattern* ; a constant
     (concat "^" *acl2-doc-buffer-name* "\\(<.+>\\|\\)$"))

   (defun acl2-doc-buffer-p (buffer)
     (and (string-match-p *acl2-doc-buffer-name-pattern*
			  (buffer-name buffer))
	  (with-current-buffer buffer
	    (equal major-mode 'acl2-doc-mode))))

   (defun current-acl2-buffer ()
     (let ((buf nil)
	   (lst (buffer-list)))

;;;; It is tempting to use (seq-find 'acl2-doc-buffer-p (buffer-list)), but
;;;; seq-find is not defined in some older Emacs versions (e.g., 24.5.1).

       (while (and lst
		   (null buf))
	 (if (acl2-doc-buffer-p (car lst))
	     (setq buf (car lst))
	   (pop lst)))
       buf))

   (defun switch-to-acl2-doc-buffer (&optional new-buffer-name)
     (if new-buffer-name
	 (let ((buf (generate-new-buffer-name
		     (if *acl2-doc-short-new-buffer-names*
			 *acl2-doc-buffer-name*
		       (concat *acl2-doc-buffer-name*
			       "<"
			       (symbol-name new-buffer-name)
			       ">")))))
           (if pop-up-windows ; t by default; with nil, want single window
               (switch-to-buffer-other-window buf)
             (switch-to-buffer buf)))
       (let ((current-acl2-buffer (current-acl2-buffer)))
	 (switch-to-buffer (if current-acl2-buffer
			       current-acl2-buffer
			     (generate-new-buffer-name *acl2-doc-buffer-name*)))))

;;;; The next two forms need only be evaluated when the buffer is first
;;;; created, but it is likely harmless to go ahead and evaluate them
;;;; every time.

     (acl2-doc-mode)
     (when *acl2-doc-directory*
       (setq default-directory *acl2-doc-directory*))
     t)

   (defun acl2-doc-kill-buffers (&optional do-not-ask)

     "Kill all background ACL2-Doc buffers.  If invoked in an
ACl2-Doc buffer, all ACl2-Doc buffers except the current one will
be killed.  If invoked in any other buffer, all ACL2-Doc buffers
will be killed.  With prefix argument, avoid a query that asks
for confirmation."

     (interactive)
     (when (or do-not-ask (y-or-n-p "Kill all other acl2-doc-buffers? "))

;;;; It may be tempting to use seq-filter below, but that isn't defined
;;;; in some older Emacs versions (e.g., 24.5.1).

       (let ((cur (current-buffer)))
	 (dolist (buf (buffer-list))
           (when (and (acl2-doc-buffer-p buf)
                      (not (eq cur buf)))
             (kill-buffer buf))))))

   (defun acl2-doc-print-topic (tuple)

;;; Warning: Do not set the buffer to read-only here, because this
;;; function may be called repeatedly for the same buffer, e.g., by
;;; function acl2-doc-search-buffer.

     (insert (format "Topic: %s\nParent list: %s\n%s\n%s\n"
                     (nth 0 tuple)
                     (nth 1 tuple)
                     (if (equal (length tuple) 4)
			 (if (eq (nth 0 tuple) 'TOP)
                             ""
                           (format ":DOC source: %s\n" (nth 3 tuple)))
                       (if (eq (acl2-doc-state-top-name) 'ACL2)
                           ""
			 ":DOC source: ACL2 Sources\n"))
                     (nth 2 tuple)))
     (set-buffer-modified-p nil)
     (force-mode-line-update))

   (defun acl2-doc-display-message (entry &optional extra)
     (let ((name (car (cdr entry)))
           (manual-name (acl2-doc-manual-printname))
           (help-msg (if *acl2-doc-show-help-message*
			 "; type h for help"
                       ""))
           (extra (or extra
                      *acl2-doc-show-extra*
                      "")))
       (setq *acl2-doc-show-help-message* nil)
       (setq *acl2-doc-show-extra* nil)
       (if (eq (acl2-doc-state-top-name) name)
           (message "At the top node of the %s%s%s"
                    manual-name help-msg extra)
	 (message "Topic: %s (%s)%s%s" name manual-name help-msg extra))))

   (defun acl2-doc-where ()
     (interactive)
     (cond ((consp *acl2-doc-history*)
            (acl2-doc-display-message (car *acl2-doc-history*)))
           (t (error "Empty history: No `where' to display!"))))

   (defun xdoc-tag-alist-fancy-p (val)

;;;; Keep this in sync with function xdoc-tag-alist-fancy-p in
;;;; books/system/doc/display.lisp.

     (or (null val)
	 (equal val "")
	 (equal (upcase val) "FANCY")))

   (defvar *acl2-manual-dir*
     (concat *acl2-sources-dir*
	     "books/doc/manual/"))

   (defvar *img-prefix*
     (byte-to-string 25))

   (defvar *img-suffix*
     (byte-to-string 26))

   (defun acl2-doc-handle-images (display-graphic-p)
     (save-excursion
       (goto-char (point-min))
       (let ((go t))
	 (while go
	   (let ((start (search-forward *img-prefix* nil t)))
	     (cond
	      (start
	       (let* ((end (search-forward *img-suffix*))
		      (src (buffer-substring start (1- end))))
		 (delete-region (1- start) end)
		 (cond
		  (display-graphic-p
		   (insert-image
		    (create-image (concat *acl2-manual-dir* src)))
		   (insert "\n"))
		  (t (insert "{IMAGE}")))))
	      (t (setq go nil))))))))

   (defun acl2-doc-handle-color ()

;;;; This function removes color indicators for Select Graphic Rendition (SGR)
;;;; in the current buffer.  If we want color, then we should use
;;;; ansi-color-apply-on-region to set color properties; if we want plain text
;;;; without color then we should use ansi-color-filter-region, which anyhow is
;;;; much more efficient than ansi-color-apply-on-region.

     (if (xdoc-tag-alist-fancy-p (getenv "ACL2_XDOC_TAGS"))
	 (ansi-color-apply-on-region (point-min) (point-max))
       (ansi-color-filter-region (point-min) (point-max))))

   (defun acl2-doc-display-basic (entry &optional extra no-handle-images)

;;;; Entry is a history entry, hence of the form (point name parents
;;;; string).

;;;; The first form below is unnecessary if the caller is
;;;; acl2-doc-display, but it's cheap.

     (switch-to-acl2-doc-buffer)
     (setq buffer-read-only nil)
     (erase-buffer)
     (acl2-doc-print-topic (cdr entry))  ; entry is (cons position tuple)
     (acl2-doc-handle-color)
     (when (not no-handle-images)
       (acl2-doc-handle-images (display-graphic-p))
       (setq buffer-read-only t))
     (goto-char (nth 0 entry))
     (push (car (cdr entry)) *acl2-doc-all-topics-rev*)
     (acl2-doc-display-message entry extra))

   (defun acl2-doc-display (name &optional extra new-buffer no-handle-images)

;;;; Name should be a symbol.  We display the topic and adjust the
;;;; history and return history.  Do not use this for the "l" or "r"
;;;; commands; use acl2-doc-display-basic instead, which does not mess
;;;; with those history variables.

     (let ((tuple (assoc name (acl2-doc-state-alist))))
       (cond (tuple (switch-to-acl2-doc-buffer new-buffer)
                    (let ((new-entry (cons 0 tuple)))
                      (if *acl2-doc-history*
			  (let ((old-entry (pop *acl2-doc-history*)))
                            (push (cons (point) (cdr old-entry))
				  *acl2-doc-history*)))
                      (push new-entry *acl2-doc-history*)
                      (setq *acl2-doc-return* nil)
                      (acl2-doc-display-basic new-entry extra no-handle-images)))
             (t (error "Not found: %s" name)))))

   (defun acl2-doc-topic-at-point ()

;;;; This function returns nil if the s-expression at point isn't a
;;;; symbol.  Otherwise, it returns that symbol in upper case, except
;;;; that it removes the leading and trailing bracket for [...].

     (let ((sym (sexp-at-point))
           (go t)
           (arrayp nil))
       (while go
	 (cond ((and (consp sym)
                     (equal (length sym) 2)
                     (member (car sym)
                             '(\` quote)))
		(setq sym (car (cdr sym))))
               (t (setq go nil))))

;;;; Deal with array case.

       (cond
	((null sym)

;;;; We have found that (sexp-at-point) returns nil when standing in text (in
;;;; acl2-doc mode) that ends in a square bracket followed by a period, e.g.,
;;;; "[loop-stopper]."  So we try again.

	 (setq sym
               (save-excursion
		 (if (< (point) (point-max))
                     (forward-char 1)) ; in case we are at "["
		 (let* ((saved-point (point))
			(start (if (looking-at "[[]")
                                   (point)
				 (and (search-backward "[" nil t)
                                      (match-beginning 0)))))
                   (and start
			(let ((end (and (search-forward "]" nil t)
					(match-end 0))))
			  (and end
                               (<= saved-point end)
                               (goto-char (1+ start))
                               (not (search-forward " " end t))
                               (read (current-buffer))))))))
	 (when sym
           (setq arrayp t)))
	((arrayp sym) ;; [...]
	 (setq sym (and (not (equal sym []))
			(aref sym 0)))
	 (when sym
           (setq arrayp t))))

;;;; Now we have sym and arrayp.

       (cond (arrayp ;; [...]
              (let ((tmp (and (symbolp sym)
                              (intern (upcase (symbol-name sym))))))
		(cond ((assoc tmp (acl2-doc-state-alist))
                       tmp)
                      ((numberp sym) ; e.g. from [1]
                       nil)
                      (t 'BROKEN-LINK))))
             ((not (and sym (symbolp sym)))
              nil)
             (t
              (let* ((name (symbol-name sym))
                     (max-orig (1- (length name)))
                     (max max-orig)
                     (name (cond ((equal (aref name 0) ?:)
				  (setq max (1- max))
				  (substring name 1))
				 (t name)))
                     (go t))
		(while (and go (< 1 max))
		  (cond ((member (aref name max)
				 '(?. ?\' ?:))
			 (setq max (1- max)))
			(t (setq go nil))))
		(intern (upcase (cond ((equal max max-orig)
                                       name)
                                      (t (substring name 0 (1+ max)))))))))))

   (defun acl2-doc-completing-read (prompt silent-error-p)
     (let* ((completion-ignore-case t)
            (default (acl2-doc-topic-at-point))
            (default (and (or (eq default 'BROKEN-LINK) ; optimization
                              (assoc default (acl2-doc-state-alist)))
			  default))
            (value-read (completing-read
			 (if default
                             (format "%s (default %s): " prompt default)
                           (format "%s: " prompt))
			 (acl2-doc-state-alist)
			 nil nil nil nil
			 default)))
       (list (cond ((equal value-read default) ;; i.e., (symbolp value-read)
                    default)
                   ((and (not silent-error-p)
			 (equal value-read ""))
                    (error "No default topic name found at point"))
                   (t (intern (upcase value-read)))))))

   (defun acl2-doc-go (name)

     "Go to the specified topic; performs completion."

     (interactive (acl2-doc-completing-read "Go to topic" nil))
     (acl2-doc-display name))

   (defun acl2-doc-go-new-buffer (name)

     "Go to the specified topic in a new buffer; performs completion."

     (interactive (acl2-doc-completing-read "Go to topic (new buffer)" nil))
     (acl2-doc-display name nil name))

   (defun acl2-doc-go-from-anywhere (name)

     "Go to the specified topic even if not within ACL2-Doc; performs completion."

     (interactive (with-syntax-table lisp-mode-syntax-table
                    (acl2-doc-completing-read "Go to topic" nil)))
     (when (not (acl2-doc-buffer-p (current-buffer)))
       (setq *acl2-doc-show-help-message* t))
     (acl2-doc-display name))

;;;; Avoid warning in Emacs 25.
   (defvar acl2-doc-find-tag-function
     'find-tag)

   (defun acl2-doc-go!-aux (new-buffer-p)
     (let ((name (acl2-doc-topic-at-point)))
       (cond ((not name)
              (error "Cursor is not on a name"))
             ((assoc name (acl2-doc-state-alist))

;;;; This code is a bit inefficient: the assoc above is done again by
;;;; acl2-doc-display.  But I like the simplicity of this code.

              (when new-buffer-p (switch-to-acl2-doc-buffer name))
              (acl2-doc-display name))
             ((acl2-doc-tagp (symbol-name name))
              (when new-buffer-p
		(if pop-up-windows ; t by default; with nil, want single window
                    (switch-to-buffer-other-window nil t)
		  (switch-to-buffer nil)))
              (acl2-doc-find-tag (acl2-doc-topic-to-tags-name name) nil t))
             (t
              (error "No topic name: %s" name)))))

   (defun acl2-doc-go! ()

     "Go to the topic occurring at the cursor position.  In the case
of <NAME>, instead go to the source code definition of NAME for
the current manual (as for `/', but without a minibuffer query)."

     (interactive)
     (acl2-doc-go!-aux nil))

   (defun acl2-doc-go!-new-buffer ()

     "Go to the topic occurring at the cursor position in a new
buffer.  In the case of <NAME>, instead go to the source code
definition of NAME for the current manual (as for `/', but
without a minibuffer query)."

     (interactive)
     (acl2-doc-go!-aux t))

   (defun acl2-doc-top ()
     "Go to the top topic."
     (interactive)
     (setq *acl2-doc-show-help-message* t)
     (acl2-doc-go (acl2-doc-state-top-name)))

   (defun acl2-doc (&optional clear)

     "Go to the ACL2-Doc browser; prefix argument clears state.
See the documentation topic for ACL2-Doc for more
information, either by starting ACL2-Doc and typing `h'
\(help), by viewing the ACL2-DOC topic in a web browser, or by
typing `:doc acl2-doc' in the ACL2 read-eval-print loop.

\\{acl2-doc-mode-map}"

     (interactive "P")
     (setq *acl2-doc-show-help-message* t)
     (cond (clear
            (acl2-doc-reset nil)
            (acl2-doc-top))
	   (t
	    (switch-to-acl2-doc-buffer)
	    (cond (*acl2-doc-history*
		   (acl2-doc-display-basic (car *acl2-doc-history*)))
		  (t
		   (acl2-doc-maybe-reset)
		   (acl2-doc-top))))))

   (defun acl2-doc-last ()
     "Go to the last topic visited in the current buffer.  This
   command is buffer-local."
     (interactive)
     (cond ((cdr *acl2-doc-history*)
            (push (pop *acl2-doc-history*)
		  *acl2-doc-return*)
            (acl2-doc-display-basic (car *acl2-doc-history*)))
           (t (error "No last page visited"))))

   (defun acl2-doc-return ()
     "Return to the last topic visited in the current buffer, popping
the stack of such topics.  This command is buffer-local."
     (interactive)
     (cond (*acl2-doc-return*
            (let ((entry (pop *acl2-doc-return*)))
              (push entry *acl2-doc-history*)
              (acl2-doc-display-basic entry)))
           (t (error "Nothing to return to"))))

   (defun acl2-doc-read-line ()

;;; Return the current line, and go to the end of it.

     (forward-line 0)
     (let ((beg (point)))
       (end-of-line)
       (buffer-substring beg (point))))

   (defun acl2-doc-up ()

     "Go to the parent of the current topic."

     (interactive)
     (switch-to-acl2-doc-buffer)
     (let ((first-parent
            (save-excursion
              (goto-char (point-min))
              (and (search-forward "Parent list: (" nil t)
                   (acl2-doc-topic-at-point)))))
       (cond ((null first-parent)
              (cond ((save-excursion
                       (goto-char (point-min))
                       (forward-line 1)
                       (member (acl2-doc-read-line)
                               '("Parent list: nil"
				 "Parent list: NIL"
				 "Parent list: ()")))
                     (error "Already at the root node of the manual"))
                    (t (error "Internal ACL2-Doc error in acl2-doc-up.
Please report this error to the ACL2 implementors."))))
             (t (acl2-doc-display first-parent)))))

   (defun acl2-doc-update-top-history-entry (buf &optional no-error)
     (cond ((null *acl2-doc-history*)
            (if no-error
		nil
              (error "Empty history!")))
           (t (with-current-buffer
		  buf
		(setq *acl2-doc-history*
                      (cons (cons (point) (cdr (car *acl2-doc-history*)))
                            (cdr *acl2-doc-history*)))))))

   (defun acl2-doc-quit ()

     "Quit the current ACL2-Doc buffer."

     (interactive)
     (unless (eq major-mode 'acl2-doc-mode)
       (error "Currently not in an ACL2-Doc buffer; consider using 'M-x acl2-doc-kill-buffers'"))
     (when (acl2-doc-buffer-p (current-buffer))
       (acl2-doc-update-top-history-entry (current-buffer)))

;;;; At one time we invoked (while (equal major-mode 'acl2-doc-mode)
;;;; (quit-window)), so that we would continue to quit, including
;;;; acl2-doc-history etc.  But a session that invoked emacs -nw from a
;;;; terminal on the Mac, that seemed to put us into an infinite loop.
;;;; It seems fine to quit just the current buffer.

     (quit-window))

   (defun acl2-doc-initialize (&optional select)

     "Restart the ACL2-Doc browser, clearing its state.  With a
prefix argument, a query asks you to select the name of an
available manual, using completion.  See the section \"Selecting
a Manual\" in :doc acl2-doc for more information."

     (interactive "P")
     (acl2-doc-reset
      (and select
           (let* ((default
                    (cond (*acl2-doc-manual-name-previous*)
			  ((and (eq (acl2-doc-manual-name)
                                    (caar *acl2-doc-manual-alist*))
				(consp (cdr *acl2-doc-manual-alist*)))
                           (car (cadr *acl2-doc-manual-alist*)))
			  ((or (caar *acl2-doc-manual-alist*) ; should be non-nil
                               (acl2-doc-manual-name)))))
		  (s (completing-read
                      (format "Select manual (default %s): " default)
                      *acl2-doc-manual-alist*
                      nil nil nil nil
                      default)))
             (cond ((eq s default) default)
                   (t (intern s))))))
     (acl2-doc-top))

;;; Start code for setting the limit topic.

;;;; When *acl2-doc-limit-topic* is non-nil, it is the "limit topic": we want
;;;; searches (including index operations) to be restricted to topics with a
;;;; parent chain leading to the limit topic.  We'll call such topics
;;;; "descendents".

;;;; When *acl2-doc-topics-ht* is non-nil, this is a hash table mapping each
;;;; descendent of *acl2-doc-limit-topic* to t.

;;;; When *acl2-doc-children-ht* is non-nil, this variable is a hash table that
;;;; maps each topic name to a hash table, which in turn maps children of that
;;;; key to t.

   (defun acl2-doc-topics-ht-1 (topic ht children-ht)

;;;; We mark each node reachable from topic by a path following children-ht,
;;;; stopping our exploration when we reach a node that is already marked.  A
;;;; key idea is to avoid looping by marking the topic before exploring its
;;;; children.

;;;; It seems plausible that this algorithm marks in ht every node reachable
;;;; from topic.  At some point maybe a proof will appear here.  Here we present
;;;; an informal argument by induction on the length of a path from the
;;;; top-level topic to a reachable node N.  For consider the first call of this
;;;; function on N.  There is a call on some parent P, so by induction, P is
;;;; marked; but the first mark of P will lead to a call of this function that
;;;; marks N.

     (when (not (gethash topic ht)) ; otherwise we could loop
       (puthash topic t ht)
       (let ((topic-children-ht (gethash topic children-ht)))
	 (when topic-children-ht
           (maphash (lambda (child val)
                      (when (null (gethash child ht))
			(acl2-doc-topics-ht-1 child ht children-ht)))
                    topic-children-ht)))))

   (defun acl2-doc-topics-ht-init (topic)
     (cond
      ((eq topic (acl2-doc-state-top-name)) ; no limitations
       (setq *acl2-doc-topics-ht* nil))
      (t ;; Set up initial *acl2-doc-children-ht*, mapping parents to children.
       (setq *acl2-doc-topics-ht* (make-hash-table :test 'eq))
       (when (null *acl2-doc-children-ht*)
	 (setq *acl2-doc-children-ht* (make-hash-table :test 'eq)))
;;; Map each parent to its children in *acl2-doc-children-ht*.
       (dolist (tup (acl2-doc-state-alist))
	 (let ((topic (car tup))
               (parents (cadr tup)))
           (when (not (member parents '(NIL ())))
             (dolist (parent parents)
               (let ((ht (cond ((gethash parent *acl2-doc-children-ht*))
                               (t (let ((ht (make-hash-table :test 'eq)))
                                    (puthash parent
                                             ht
                                             *acl2-doc-children-ht*)
                                    ht)))))
		 (puthash topic t ht))))))
       (acl2-doc-topics-ht-1 topic *acl2-doc-topics-ht* *acl2-doc-children-ht*)
       (puthash topic t *acl2-doc-topics-ht*)
       *acl2-doc-topics-ht*)))

   (defun acl2-doc-set-limit-topic (do-it)
     (cond
      ((null do-it)
       (setq *acl2-doc-limit-topic* nil
             *acl2-doc-topics-ht* nil))
      (t
       (let ((name
              (car (acl2-doc-completing-read
                    "Search or index only under topic"
                    t))))
	 (cond ((or (equal (symbol-name name) "")
                    (eq name *acl2-doc-limit-topic*))) ; nothing to do
               (t
		(let ((found-p (assoc name (acl2-doc-state-alist))))
		  (cond (found-p (setq *acl2-doc-limit-topic* name)
				 (acl2-doc-topics-ht-init name))
			(t (error "Unknown topic name: %s" name))))))))))

   (defun acl2-doc-under-limit-topic-p (topic ht)

;;;; Ht is the value of *acl2-doc-topics-ht* in the appropriate
;;;; ACL2-Doc buffer.

     (or (null ht)
	 (gethash topic ht)))

;;; End code for setting the limit topic.

   (defun acl2-doc-index-buffer ()
     (or (get-buffer *acl2-doc-index-buffer-name*)
	 (let ((buf (get-buffer-create *acl2-doc-index-buffer-name*))
               (alist (acl2-doc-state-alist)))
           (with-current-buffer
               buf
             (when *acl2-doc-directory* ; probably always true
               (setq default-directory *acl2-doc-directory*))
             (while alist
               (insert (format "%s\n" (car (pop alist)))))
             (acl2-doc-mode)
             (set-buffer-modified-p nil)
             (setq buffer-read-only t))
           buf)))

   (defun acl2-doc-index-main (name)
     (interactive (acl2-doc-completing-read
                   (format "Find topic%s (then type , for next match) "
                           (if *acl2-doc-limit-topic*
                               (format " under %s"
                                       *acl2-doc-limit-topic*)
                             ""))
                   t))
     (let ((buf (acl2-doc-index-buffer))
           (ht *acl2-doc-topics-ht*)
           (limit-topic *acl2-doc-limit-topic*))
       (cond
	((equal (symbol-name name) "")
	 (switch-to-buffer *acl2-doc-index-buffer-name*)
	 (goto-char (point-min)))
	(t
	 (let ((found-p (and (acl2-doc-under-limit-topic-p name ht)
                             (assoc name (acl2-doc-state-alist))))
               topic
               point
               (count 0)
               (sname (symbol-name name)))
           (setq *acl2-doc-index-name-found-p* found-p) ; a cons
           (setq *acl2-doc-index-name* sname)
           (cond
            (found-p
             (with-current-buffer
		 buf
               (goto-char (point-min))
               (while (search-forward sname nil t)
		 (let ((sym (intern (acl2-doc-read-line))))
                   (when (acl2-doc-under-limit-topic-p sym ht)
                     (setq count (1+ count)))))
               (goto-char (point-min)))
             (acl2-doc-display name
                               (format " (number of matches: %s)"
                                       count)))
            (t (with-current-buffer
                   buf
		 (goto-char (point-min))
		 (while (search-forward sname nil t)
                   (let ((sym (intern (acl2-doc-read-line))))
                     (when (acl2-doc-under-limit-topic-p sym ht)
                       (when (null topic)
			 (setq topic sym)
			 (setq point (point)))
                       (setq count (1+ count)))))
		 (when point
                   (goto-char point)))
               (cond (topic
                      (acl2-doc-display topic
					(format " (number of matches: %s)"
						count)))
                     (t (setq *acl2-doc-index-name* nil)
			(error "No matching topic found%s"
                               (if limit-topic
                                   (format " under %s" limit-topic)
				 "")))))))))))

   (defun acl2-doc-index (&optional arg)

     "Go to the specified topic or else one containing it as a
substring; performs completion.  If the empty string is supplied,
then go to the index buffer.  Otherwise, with prefix argument,
consider only descendents of the topic supplied in response to a
prompt.  Note that the index buffer is in ACL2-Doc mode; thus, in
particular, you can type <RETURN> while standing on a topic in
order to go directly to that topic."

     (interactive "P")
     (acl2-doc-set-limit-topic arg)
     (let ((buf (acl2-doc-index-buffer)))
       (condition-case err
           (call-interactively 'acl2-doc-index-main)
	 (t (setq *acl2-doc-index-position*
		  (with-current-buffer buf (point)))
            (signal (car err) (cdr err))))
       (setq *acl2-doc-index-position*
             (with-current-buffer buf (point)))))

   (defun acl2-doc-index-continue (previous-p)
     (let ((ht *acl2-doc-topics-ht*)
           (buf (get-buffer *acl2-doc-index-buffer-name*))
           (name *acl2-doc-index-name*)
           (limit-topic *acl2-doc-limit-topic*))
       (when (or (null buf) (null name))
	 (error "Need to initiate index search"))
       (let* (topic
              (acl2-doc-index-sym
               (and *acl2-doc-index-name-found-p* ; optimization
                    (intern *acl2-doc-index-name*)))
              (found-p *acl2-doc-index-name-found-p*)
              (position *acl2-doc-index-position*))
	 (with-current-buffer
             buf
           (goto-char position)
           (when previous-p

;;;; If this is the first use of "," or "<" after "i", and the match was exact,
;;;; then start the search backward in the index buffer from that match.
;;;; (Otherwise we go forward from the current position, which is presumably the
;;;; beginning of the index buffer.)

             (when (consp found-p)               ; start from the hit
               (when (equal (point) (point-min)) ; presumably true
		 (search-forward (format "\n%s\n" name))
		 (backward-char 1)         ; to previous line
		 (setq found-p nil))))

;;;; Note that subsequent uses of "," or "<" (after the same "i") are not the
;;;; first.

           (setq found-p (and found-p t))
           (while (null topic)
             (cond ((cond (previous-p
                           (beginning-of-line)
                           (search-backward name nil t))
			  (t
                           (end-of-line)
                           (search-forward name nil t)))
                    (let ((sym (intern (acl2-doc-read-line))))
                      (when (acl2-doc-under-limit-topic-p sym ht)
			(setq topic sym))))
                   (t ;; set to failure indicator, 0
                    (setq topic 0))))
           (setq position (point)))
	 (setq *acl2-doc-index-position* position)
	 (setq *acl2-doc-index-name-found-p* found-p)
	 (cond ((not (equal topic 0))      ; success
		(cond ((and found-p
                            (eq topic acl2-doc-index-sym))
                       (setq *acl2-doc-index-name-found-p* nil)
                       (acl2-doc-index-continue previous-p))
                      (t (acl2-doc-display topic))))
               (t (with-current-buffer
                      buf
                    (goto-char (if previous-p (point-max) (point-min)))
                    (setq position (point)))
		  (setq *acl2-doc-index-position* position)
		  (error
                   "No more matches%s; repeat to re-start index search"
                   (if limit-topic
                       (format " under %s" limit-topic)
                     "")))))))

   (defun acl2-doc-index-next ()

     "Find the next topic containing, as a substring, the topic of
the most recent i command.  Note: if this is the first \",\" or
\"<\" after an exact match from \"i\", then start the topic
search alphabetically from the beginning, but avoid a second hit
on the original topic.  Also note that this command is
buffer-local; it will follow the most recent i command executed
in the current ACL2-Doc buffer."

     (interactive)
     (acl2-doc-index-continue nil))

   (defun acl2-doc-index-previous ()

     "Find the previous topic containing, as a substring, the topic of
the most recent i command.  Note: if this is the first \",\" or \"<\"
after an exact match from \"i\", then start the topic search
alphabetically (backwards) from that exact match.  Also note that this
command is buffer-local like the \",\" command."

     (interactive)
     (acl2-doc-index-continue t))

   (defun acl2-doc-search-buffer ()
;;;; Return the search buffer, which contains all :doc topics, creating it first
;;;; (with those topics inserted) if necessary.
     (or (get-buffer *acl2-doc-search-buffer-name*)
	 (let ((acl2-doc-search-file-name (acl2-doc-search-file-name))
               (large-file-warning-threshold
		(acl2-doc-large-file-warning-threshold)))

;;; We assume that acl2-doc-search-file was written without Select Graphic
;;; Rendition (SGR) markings; see without-fancy-xdoc-tags and its use in
;;; books/xdoc/save-rendered.lisp.

           (and acl2-doc-search-file-name
		(file-exists-p acl2-doc-search-file-name)
		(find-file-noselect acl2-doc-search-file-name)))
	 (let ((buf (get-buffer-create *acl2-doc-search-buffer-name*))
               (alist (acl2-doc-state-alist))
               (large-file-warning-threshold nil)
               (undo-outer-limit nil))
           (with-current-buffer
               buf
             (while alist
               (insert "\n")
               (insert *acl2-doc-search-separator*)
               (insert "\n")
               (acl2-doc-print-topic (pop alist)))

;;; Since we are writing the acl2-doc-search buffer, we need to remove
;;; Select Graphic Rendition (SGR) markings.  We leave the images, however.

	     (acl2-doc-handle-color)
             (setq buffer-read-only t))
           buf)))

   (defun within-graphics ()
     (let ((saved-point (point)))
       (save-excursion
	 (let ((start (cond ((search-backward "\n" nil t)
			     (forward-char 1)
			     (point))
			    (t (point-min)))))
	   (goto-char saved-point)
	   (cond ((search-backward *img-prefix* start t)

;;;; We are on a line "... ^Y ... p ..." where p indicates the original
;;;; point (the beginning of a found string) and ^Y indicates the
;;;; furthest-right control-y preceding p.  We look for control-z
;;;; inbetween the two, and when one isn't found, that's when we are
;;;; within a control-y/control-z pair.

		  (not (search-forward *img-suffix* saved-point t)))
		 (t nil))))))

   (defun acl2-doc-search-aux-1 (continue-p str regexp-p)

;;; Returns a pair (position . topic-symbol) if we find str in the current
;;; (index) buffer, else nil.

     (cond
      ((if (eq continue-p :previous)

;;;; In order to avoid sticking on the same result when changing directions, we
;;;; always leave the cursor at the end of the match.  This takes a bit of extra
;;;; code when searching backwards.

           (cond (regexp-p
		  (and (save-excursion
			 (backward-char 1)
			 (re-search-backward str nil t))
                       (progn (goto-char (match-end 0))
                              t)))
		 (t
		  (and (save-excursion
			 (backward-char 1)
			 (search-backward str nil t))
                       (progn (goto-char (match-end 0))
                              t))))
	 (if regexp-p
             (re-search-forward str nil t)
           (search-forward str nil t)))
       (save-excursion
	 (let ((point-found (match-end 0)))
           (search-backward *acl2-doc-search-separator*)
           (forward-line 1)
           (let ((point-start (point)))

;;;; Why do we add 2 just below?  We add 1 because (point-min) = 1, and
;;;; we add one more because acl2-doc-print-topic prints a blank line
;;;; below the ":DOC source" line but the acl2-doc-search buffer is
;;;; printed without that blank line.

             (cons (+ 2 (- point-found point-start))
                   (let ((beg (+ point-start 7)))   ;;"Topic: "
                     (end-of-line)
                     (intern (buffer-substring beg (point)))))))))
      (t nil)))

   (defun acl2-doc-search-aux (str regexp-p)
     (when (equal str "")
       (error "Input a search string, or type \"n\" to continue previous search"))
     (let* ((ht *acl2-doc-topics-ht*)
            (limit-topic *acl2-doc-limit-topic*)
            (buf (acl2-doc-search-buffer))
            (continue-p (and (or (eq regexp-p :next)
				 (eq regexp-p :previous))
                             regexp-p))
            (str (cond
		  ((not continue-p) str)
		  (t (or *acl2-doc-search-string*
			 (error "There is no previous search to continue")))))
            (regexp-p (if continue-p
			  *acl2-doc-search-regexp-p*
			regexp-p))
            (pair nil)
            (position *acl2-doc-search-position*))
       (with-current-buffer
           buf
	 (if continue-p
             (goto-char position)
           (goto-char (point-min)))
	 (let (done)
           (while (not done)
             (let ((tmp (acl2-doc-search-aux-1 continue-p str regexp-p)))
               (cond ((null tmp)
                      (setq done t))
                     ((acl2-doc-under-limit-topic-p (cdr tmp) ht)
		      (if (not (within-graphics))
			  (setq pair tmp done t))))))
           (setq position (point))))
       (cond (pair
;;; The first two assignments are redundant if continue-p is true.
              (setq *acl2-doc-search-string* str)
              (setq *acl2-doc-search-regexp-p* regexp-p)
              (setq *acl2-doc-search-position* position)

;;;; At one time we could use the current buffer if it's the one
;;;; containing the search string.  But we need to go to the
;;;; appropriate character, (car pair), before we eliminate the
;;;; Ctl-Y/Ctl-Z pairs.

	      (acl2-doc-display (cdr pair) nil nil t)
              (goto-char (car pair))
	      (acl2-doc-handle-images (display-graphic-p))
	      (setq buffer-read-only t)
              (acl2-doc-update-top-history-entry (current-buffer)))
             (continue-p (setq *acl2-doc-search-position*
                               (with-current-buffer
                                   buf
				 (goto-char (if (eq continue-p :previous)
						(point-max)
                                              (point-min)))))
			 (error
			  "No more matches%s; try again for wrapped search"
			  (if limit-topic
                              (format " under %s" limit-topic)
                            "")))
             (t (error "Not found: %s" str)))))

   (defun acl2-doc-search-main (str)
     (interactive
      (list
       (read-from-minibuffer
	(format "Search%s (then type n for next match): "
		(if *acl2-doc-limit-topic*
                    (format " under %s"
                            *acl2-doc-limit-topic*)
		  "")))))
     (acl2-doc-search-aux str nil))

   (defun acl2-doc-search (&optional arg)

     "Search forward from the top of the manual for the input string.  If
the search succeeds, then go to that topic with the cursor put
immediately after the found text, with the topic name displayed in the
minibuffer.  With prefix argument, consider (also for subsequent \"n\"
and \"p\" commands) only descendents of the topic supplied in response
to a prompt."

     (interactive "P")
     (acl2-doc-set-limit-topic arg)
     (call-interactively 'acl2-doc-search-main))

   (defun acl2-doc-re-search-main (str)
     (interactive
      (list
       (read-from-minibuffer
	(format "Regular Expression Search%s (then type n for next match): "
		(if *acl2-doc-limit-topic*
                    (format " under %s"
                            *acl2-doc-limit-topic*)
		  "")))))
     (acl2-doc-search-aux str t))

   (defun acl2-doc-re-search (str)

     "Perform a regular expression search, forward from the top of the
manual, for the input string.  If the search succeeds, then go to that
topic with the cursor put immediately after the found text, with the
topic name displayed in the minibuffer.  With prefix argument,
consider (also for subsequent \"n\" and \"p\" commands) only
descendents of the topic supplied in response to a prompt."

     (interactive "P")
     (acl2-doc-set-limit-topic str)
     (call-interactively 'acl2-doc-re-search-main))

   (defun acl2-doc-search-next ()

     "Find the next occurrence for the most recent search or regular
expression search.  Note that this command is buffer-local; it
will follow the most recent search initiated in the current
buffer."

     (interactive)
     (acl2-doc-search-aux nil :next))

   (defun acl2-doc-search-previous ()

     "Find the previous occurrence for the most recent search or regular
expression search.  Note: as for \"n\", the cursor will end up at the end
of the match, and this command is buffer-local."

     (interactive)
     (acl2-doc-search-aux nil :previous))

   (defun acl2-doc-tab ()

     "Visit the next link after the cursor on the current page,
searching from the top if no link is below the cursor."

     (interactive)
     (switch-to-acl2-doc-buffer)
     (cond ((or (re-search-forward "[[][^ ]+]" nil t)
		(progn (goto-char (point-min))
                       (beep)
                       (message "Searching from the top...")
                       (re-search-forward "[[][^ ]+]" nil t)))
            (search-backward "[")
            (forward-char 1))
           (t (error "There are no links on this page."))))

   (defun acl2-doc-tab-back ()

     "Visit the previous link before the cursor on the current page,
searching from the bottom if no link is below the cursor."

     (interactive)
     (switch-to-acl2-doc-buffer)
     (cond ((or (re-search-backward "[[][^ ]+]" nil t)
		(progn (goto-char (point-max))
                       (beep)
                       (message "Searching from the bottom...")
                       (re-search-backward "[[][^ ]+]" nil t)))
            (forward-char 1))
           (t (error "There are no links on this page."))))

   (defun strip-cadrs (x)
     (let ((ans nil))
       (while x
	 (push (cadr (car x)) ans)
	 (setq x (cdr x)))
       (reverse ans)))

   (defun acl2-doc-history ()

     "Visit a buffer that displays the names of all topics visited
(in any ACL2-Doc buffer) in order, newest at the bottom.  That
buffer is in acl2-doc mode; thus the usual acl2-doc commands may
be used.  In particular, you can visit a displayed topic name by
putting your cursor on it and typing <RETURN>."

     (interactive)
     (let* ((buf0 (get-buffer *acl2-doc-history-buffer-name*))
            (buf (or buf0
                     (get-buffer-create *acl2-doc-history-buffer-name*)))
            (all (reverse *acl2-doc-all-topics-rev*)))
       (switch-to-buffer *acl2-doc-history-buffer-name*)
       (acl2-doc-mode)
       (cond (buf0
              (setq buffer-read-only nil)
              (delete-region (point-min) (point-max))))
       (insert "List of all visited topics in order, newest at the bottom:\n")
       (insert "=========================================================\n")
       (while all
	 (insert (format "%s" (pop all)))
	 (insert "\n"))

;;;; We could bind x to *acl2-doc-history* and execute the commented-out form
;;;; just below, after printing a separator such as the one above.  If someone
;;;; asks for this, we should think about printing the topics in
;;;; *acl2-doc-return* as well, and maybe even display a single list if we can
;;;; figure out a reasonable way to do so while indicating "last" and "return"
;;;; information.

;;;; (while x
;;;;   (insert (format "%s" (cadr (pop x))))
;;;;    (insert "\n"))

       (setq buffer-read-only t)
       (set-buffer-modified-p nil)
       (goto-char (point-max))
       (recenter -1)
       (message "List of all visited topics in order, newest at the bottom")))

   (defun acl2-doc-help ()

     "Go to the ACL2-DOC topic to read about how to use the
ACL2-Doc browser."

     (interactive)
     (acl2-doc-go 'ACL2-DOC))

   (defun acl2-doc-summary ()

     "Go to the ACL2-DOC-SUMMARY topic for one-line summaries of
ACL2-Doc browser commands."

     (interactive)
     (acl2-doc-go 'ACL2-DOC-SUMMARY))

;;; Start implementations of acl2-doc-definition and
;;; acl2-doc-where-definition.

   (defun acl2-doc-tagp (name)

;;;; This function recognizes strings of the form "<...>".  For
;;;; convenience, instead of returning t in the true case, it returns
;;;; the length of name.

     (let ((len (length name)))
       (and (equal (aref name 0) ?<)
            (equal (aref name (1- len)) ?>)
            len)))

   (defun acl2-doc-topic-to-tags-name (topic)
     (and topic
	  (let* ((name0 (symbol-name topic))
		 (len (acl2-doc-tagp name0))
		 (name (cond (len (substring name0 1 (1- len)))
                             (t name0)))
		 (colon-pos (my-cl-position ?: name)))
            (cond ((and colon-pos
			(< (1+ colon-pos) (length name))
			(equal (aref name (1+ colon-pos)) ?:))
                   (substring name (+ 2 colon-pos) (length name)))
		  (t name)))))

   (defun acl2-doc-tags-name-at-point ()
     (let ((topic (acl2-doc-topic-at-point)))
       (acl2-doc-topic-to-tags-name topic)))

   (defun acl2-doc-find-tag-next ()
     (let ((new-tags-file-name *acl2-doc-last-tags-file-name*)
           (old-tags-file-name tags-file-name))
       (unwind-protect
           (let ((tags-add-tables t)
		 (tags-case-fold-search t)) ; the name may be upper-case
             (visit-tags-table new-tags-file-name)
             (funcall acl2-doc-find-tag-function nil t)

;;;; We leave the buffer if and only if find-tag fails to cause an
;;;; error, which is when we save the point much as we do with
;;;; acl2-doc-quit.

             (if (acl2-doc-buffer-p (current-buffer))
		 (acl2-doc-update-top-history-entry (current-buffer) t)))
	 (if old-tags-file-name
             (visit-tags-table old-tags-file-name)))))

   (defun acl2-doc-find-tag-topic (default)
     (completing-read
      (if default
	  (format "Find tag (default %s): " default)
	(format "Find tag: "))
      (tags-lazy-completion-table)
      nil nil nil nil
      default))

   (defun acl2-doc-find-tag (default acl2-only &optional use-default)
     (let ((new-tags-file-name (if acl2-only
                                   (acl2-doc-acl2-tags-file-name)
				 (acl2-doc-main-tags-file-name)))
           (old-tags-file-name tags-file-name))
       (cond
	((equal new-tags-file-name nil)
	 (error "No tags table specified%s in %s"
		(if acl2-only " for ACL2 sources" "")
		(acl2-doc-manual-printname)))
	((not (file-exists-p new-tags-file-name))
	 (error "The tags table file %s does not exist.
See the online (XDOC) documentation for acl2-doc for how to build it."
		new-tags-file-name))
	((not (file-readable-p new-tags-file-name))
	 (error "The tags table file %s exists, but is not readable.
See the online (XDOC) documentation for acl2-doc for how to build it."
		new-tags-file-name))
	(t (unwind-protect
               (let ((tags-add-tables nil)
                     (tags-case-fold-search t)) ; the name may be upper-case
		 (visit-tags-table new-tags-file-name)
		 (funcall acl2-doc-find-tag-function
			  (if use-default
                              default
                            (acl2-doc-find-tag-topic default)))

;;;; If there is no error, then remember what we have in case we want
;;;; to find more matches.

		 (setq *acl2-doc-last-tags-file-name* new-tags-file-name)

;;;; We leave the buffer if and only if find-tag fails to cause an
;;;; error, which is when we save the point much as we do with
;;;; acl2-doc-quit.

		 (acl2-doc-update-top-history-entry (current-buffer) t))
             (if old-tags-file-name
		 (visit-tags-table old-tags-file-name)
               (tags-reset-tags-tables)))))))

   (defun acl2-doc-definition (arg)

     "Find an ACL2 definition (in analogy to built-in Emacs command meta-.).
With numeric prefix argument, find the next matching definition;
otherwise, the user is prompted, where the default is the name at
the cursor, obtained after stripping off any enclosing square
brackets ([..]), angle brackets (<..>) as from srclink tags, and
package prefixes.  With control-u prefix argument, search only
ACL2 source definitions; otherwise, books are searched as well.
As with built-in Emacs command meta-. , exact matches are given
priority.  For more information, see the Section on \"Selecting a
Manual\" in the acl2-doc online XDOC-based documentation."

     (interactive "P")
     (if (and arg (not (equal arg '(4)))) ;; prefix arg, not control-u
	 (acl2-doc-find-tag-next)
       (acl2-doc-find-tag (acl2-doc-tags-name-at-point) arg)))

   (defun acl2-doc-where-definition (arg)

     "Find an ACL2 definition.  This is the same as
acl2-doc-definition (the acl2-doc `/' command, as well as
control-t /), except that the default comes from the name of the
current page's topic instead of the cursor position.  Searches
are continued identically when control-t / is given a numeric
prefix argument, regardless of whether the first command was /,
control-t /, or W; thus, a search started with W can be continued
with, for example, meta-3 control-t /."

     (interactive "P")
     (if (and arg (not (equal arg '(4)))) ;; prefix arg, not control-u
	 (acl2-doc-find-tag-next)
       (acl2-doc-find-tag
	(acl2-doc-topic-to-tags-name (car (cdr (car *acl2-doc-history*))))
	arg)))

   (when (not (boundp 'ctl-t-keymap))

;;; Warning: Keep this in sync with the introduction of ctl-t-keymap in
;;; emacs-acl2.el.

;;; Note that ctl-t-keymap will already be defined if this file is loaded
;;; from emacs-acl2.el.  But if not, then we define it here.

;;; This trick probably came from Bob Boyer, to define a new keymap; so now
;;; control-t is the first character of a complex command.
     (defvar ctl-t-keymap)
     (setq ctl-t-keymap (make-sparse-keymap))
     (define-key (current-global-map) "\C-T" ctl-t-keymap)

;;; Control-t t now transposes characters, instead of the former control-t.
     (define-key ctl-t-keymap "\C-T" 'transpose-chars)
     (define-key ctl-t-keymap "\C-t" 'transpose-chars)
     )

   (define-key global-map "\C-tg" 'acl2-doc)
   (define-key global-map "\C-t." 'acl2-doc-go-from-anywhere)
   (define-key global-map "\C-t/" 'acl2-doc-definition)
   (define-key acl2-doc-mode-map " " 'scroll-up)
   (define-key acl2-doc-mode-map "," 'acl2-doc-index-next)
   (define-key acl2-doc-mode-map "<" 'acl2-doc-index-previous)
   (define-key acl2-doc-mode-map "D" 'acl2-doc-download)
   (define-key acl2-doc-mode-map "H" 'acl2-doc-history)
   (define-key acl2-doc-mode-map "I" 'acl2-doc-initialize)
   (define-key acl2-doc-mode-map "S" 'acl2-doc-re-search)
   (define-key acl2-doc-mode-map "\C-M" 'acl2-doc-go!)
   (define-key acl2-doc-mode-map (kbd "S-<return>")
     'acl2-doc-go!-new-buffer)
   (define-key acl2-doc-mode-map "K" 'acl2-doc-kill-buffers)
   (define-key acl2-doc-mode-map "\t" 'acl2-doc-tab)
   (define-key acl2-doc-mode-map "/" 'acl2-doc-definition)
   (define-key acl2-doc-mode-map "g" 'acl2-doc-go)
   (define-key acl2-doc-mode-map "G" 'acl2-doc-go-new-buffer)
   (define-key acl2-doc-mode-map "h" 'acl2-doc-help)
   (define-key acl2-doc-mode-map "?" 'acl2-doc-summary)
   (define-key acl2-doc-mode-map "i" 'acl2-doc-index)
   (define-key acl2-doc-mode-map "l" 'acl2-doc-last)
   (define-key acl2-doc-mode-map "n" 'acl2-doc-search-next)
   (define-key acl2-doc-mode-map "p" 'acl2-doc-search-previous)
   (define-key acl2-doc-mode-map "q" 'acl2-doc-quit)
   (define-key acl2-doc-mode-map "r" 'acl2-doc-return)
   (define-key acl2-doc-mode-map "s" 'acl2-doc-search)
   (define-key acl2-doc-mode-map "t" 'acl2-doc-top)
   (define-key acl2-doc-mode-map "u" 'acl2-doc-up)
   (define-key acl2-doc-mode-map "w" 'acl2-doc-where)
   (define-key acl2-doc-mode-map "W" 'acl2-doc-where-definition)
   (define-key acl2-doc-mode-map (kbd "<backtab>") 'acl2-doc-tab-back)




   )

;;; Support for xdoc-link-mode, used by acl2+books XDOC manual
 (let ((xdoc-el-file (concat (acl2-sources-dir) "books/xdoc/xdoc.el")))
   (if (file-exists-p xdoc-el-file)
       (load xdoc-el-file)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Miscellaneous
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 (defun acl2-info ()
   "Starts up info pointing at top of acl2 documentation"
   (interactive)
   (info (concat (acl2-sources-dir) "doc/EMACS/acl2-doc-emacs.info"))
   )

;;; From Bishop Brock:
;;;(defun date ()
;;;  "Inserts the date and time at point."
;;;  (interactive)
;;;  (insert (current-time-string)))

;;; Get control-meta-l to change buffers in rmail mode and perhaps some other
;;; modes where it otherwise doesn't work.
 (fset 'c-m-l "\C-Xb\C-M")
 (global-set-key "\214" 'c-m-l)
;;; (load "rmail")
;;; (define-key rmail-mode-map "\214" 'c-m-l)

;;; Turn on time/mail display on mode line.
 (load "time")
 (setq display-time-interval 10)
 (display-time) ; turn off as described just below:
;;; Turn off display-time with:
;;;   (display-time-mode) in emacs
;;;   (display-time-stop) in xemacs
;;; Needed for displaying day and date in addition to time:
;;; (setq display-time-day-and-date t)

;;; Disable commands that we do not want to execute by mistake:
 (put 'shell-resync-dirs 'disabled t)
 (put 'suspend-or-iconify-emacs 'disabled t)
 (put 'suspend-emacs 'disabled t)
 (put 'iconify-or-deiconify-frame 'disabled t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Some other features you may want
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Turn off menu bar:
;;; (menu-bar-mode 0)

;;; Turn off auto-save (not actually a good idea unless you save your files
;;; often).
;;; (setq auto-save-interval 0)
;;; (setq auto-save-timeout 0)

;;; Abbrevs are great!  For example, if you type
;;; ac
;;; followed by
;;; control-x '
;;; then (assuming the following form has been evaluated), the "ac" will be
;;; replaced by the value of *acl2-sources-dir*.
;;; (define-abbrev-table 'global-abbrev-table
;;;   (list
;;;    (list "ac" *acl2-sources-dir* nil 1)
;;;    ))

;;; Avoid getting two windows, for example with control-x control-b.
;;; (setq pop-up-windows nil)

;;; For compare-windows ignoring whitespace (control-t q):
;;; Set compare-windows-whitespace to something other than "[ \t\n]+"
;;; if desired.  Also consider compare-ignore-case.

;;; Turn on version control (backup files *.~1~, *.~2~, ...):
;;; (setq version-control t)

;;; If c-m-l does not work in rmail mode, you can do this:
;;; (load "rmail")
;;; (define-key rmail-mode-map "\214" 'c-m-l)

;;; If time and "mail" displays icons, this may turn them into ordinary ascii.
;;; (setq display-time-show-icons-maybe nil)

;;; To get ``real'' quotes with Escape-" (even without TeX mode):
;;; (autoload 'tex-insert-quote "tex-mode" nil t)
;;; (define-key global-map "\C-[\"" 'tex-insert-quote)

;;; To debug emacs errors with backtrace and recursive edit:
;;; (setq debug-on-error t)


 (when t
;;; ACL2 Version 8.6 -- A Computational Logic for Applicative Common Lisp
;;; Copyright (C) 2024, Matt Kaufmann
;;; License: A 3-clause BSD license.  See the LICENSE file distributed with ACL2.

;;; This is an extension to emacs/acl2-doc.el that defines the key, U,
;;; to bring up a URL, or a local file "res/...", in a web browser.  It
;;; should only be loaded after emacs/acl2-doc.el is loaded.

;;; Of course, this won't work if you are running acl2-doc from inside
;;; an Emacs that is not window-based -- for example, if your Emacs is
;;; running from within the "screen" program.

;;; At some point this file might be incorporated into acl2-doc.el.
;;; Perhaps the "g" command will be enhanced at that point, so that if
;;; one is looking at a word that seems to represent a URL or a local
;;; "res/..." name, then an error message will suggest using "U"
;;; instead.  Or perhaps "g" will simply invoke "U" in that case.

;;; Requirements:

;;; You'll need Emacs variable browse-url-browser-function to be set to
;;; browse-url-PROGRAM, where PROGRAM brings up a browser.  For example,
;;; you could put the form (setq browse-url-browser-function (quote
;;; browse-url-firefox)) in your ~/.emacs file, which will set
;;; browse-url-browser-function to the value, browse-url-firefox.  But
;;; then the command, firefox, needs to be on your path.  One way to
;;; accomplish this is to arrange for Emacs variable exec-path to
;;; include, say, "~/bin", in the list value of Emacs variable exec-path
;;; -- e.g., by including into your .emacs file the form
;;;   (setq exec-path
;;;         (append (butlast exec-path 1) '("~/bin") (last exec-path)))
;;; -- and then have something like the following in ~/bin/firefox (this
;;; has worked on a Mac; a different command, perhaps just a call of
;;; "firefox" [rather than "open"], may work on Linux):

;;; #!/usr/bin/env bash
;;; open -a 'firefox' "$@"

   (defun manual-dir ()
     (concat *acl2-doc-directory* "../../doc/manual"))

   (defun acl2-doc-open-url ()
     (interactive)
     (let ((topic (acl2-doc-topic-at-point)))
       (if (not topic)
	   (error "No topic at point."))
       (let* ((topic (downcase (symbol-name topic)))
	      (len (length topic)))
	 (if (equal (aref topic (1- len)) ?})
	     (setq topic (substring topic 0 (1- len))))
	 (let ((url (if (and (> len 4)
			     (equal (substring topic 0 4) "res/"))
			(concat "file://" (manual-dir) "/" topic)
		      (if (and (> len 4)
			       (equal (substring topic 0 4) "http"))
			  topic
			(error "No available topic at point.")))))
	   (browse-url url)))))

   (define-key acl2-doc-mode-map "U" 'acl2-doc-open-url)

   )

 (when t

;;; Copyright (C) 2024, ForrestHunt, Inc.
;;; Written by Matt Kaufmann
;;; License: A 3-clause BSD license.  See the LICENSE file distributed with ACL2.
;;; Release approved by DARPA with "DISTRIBUTION STATEMENT A. Approved
;;; for public release. Distribution is unlimited."

;;; These utilities have been used as part of a process of converting to
;;; XDOC an HTML file that was already created using latex2html.  There
;;; is little documentation, but it may be helpful in future projects,
;;; in which case it may be straightforward to add documentation at that
;;; time.

;;; This file assumes that ctl-t-keymap has been defined, and might more
;;; generally assume that emacs-acl2.el has been loaded.

   (defun within-tag (start-tag end-tag)
     (let ((saved-point (point)))
       (cond ((search-backward start-tag nil t)
	      (let ((p (match-beginning 0)))
		(goto-char saved-point)
		(cond ((search-backward end-tag nil t)
		       (goto-char saved-point)
		       (< (match-end 0) p))
		      (t t))))
	     (t nil))))

   (defun html-end-paragraphs ()
     (interactive)
     (save-excursion
       (goto-char (point-min))
       (while (search-forward "\n\n" nil t)
	 (let ((p0 (match-beginning 0)))
	   (when (not (or (within-tag "<ul>" "</ul>")
			  (within-tag "<ol>" "</ol>")
			  (within-tag "<dl>" "</dl>")
			  (within-tag "<pre>" "</pre>")))
	     (goto-char p0)
	     (insert "\n</p>")
;;;; Move past newlines.
	     (while (looking-at "\n")
	       (forward-char 1)))))))

   (defun html-fix-p-tag-within-lists ()
     (interactive)
     (save-excursion
       (goto-char (point-min))
       (while (search-forward "<p>" nil t)
	 (let ((p0 (match-end 0)))
	   (when (or (within-tag "<ul>" "</ul>")
		     (within-tag "<ol>" "</ol>")
		     (within-tag "<dl>" "</dl>"))
;;; Deliberately omitted <pre> above.
	     (goto-char (- p0 1))
	     (insert "/"))))))

   (defun html-fix-string (old new)
     (interactive)
     (save-excursion
       (goto-char (point-min))
       (while (search-forward old nil t)
	 (replace-match new nil t))))

   (defun html-fix-strings ()
     (interactive)
     (html-fix-string "\\" "\\\\")
     (html-fix-string "\"" "\\\"")
     (html-fix-string "&ldots;" "&hellip;")
;;; Latex2html has translated \ptt{<<=} to <tt>&laquo;=</tt>.
     (html-fix-string "&laquo;=" "&lt;&lt;="))

   (defun html-remove-comments ()
     (interactive)
     (save-excursion
       (goto-char (point-min))
       (while (search-forward "<!--" nil t)
	 (let ((beg (match-beginning 0)))
	   (search-forward "-->")
;;; Avoid blank lines that could cause paragraph markers to be added.
	   (while (looking-at "\n") (forward-char 1))
	   (delete-region beg (point))))))

   (defun html-balance-br ()
     (interactive)
     (html-fix-string "<br>" "<br/>"))

   (defun html-error-on-bad-stuff ()
     (interactive)
     (let ((saved-point (point)))
       (goto-char (point-min))
       (cond
	((search-forward "<sup>" nil t)
	 (goto-char (match-beginning 0))
	 (error "Need to deal with <sup> here."))
	((search-forward "<!-- MATH" nil t)
	 (goto-char (match-beginning 0))
	 (error "Need to deal with MATH comment here."))
	((search-forward ".svg" nil t)
	 (goto-char (match-beginning 0))
	 (error "Need to deal with image here."))
	((search-forward "<br/>" nil t)
	 (goto-char (match-beginning 0))
	 (error "Found <br/>; need to deal with <br> tags manually."))
	(t (goto-char saved-point)))))

   (defun html-convert-tt ()
     (interactive)
     (goto-char (point-min))
     (while (search-forward "<span  class=\"texttt\">" nil t)
       (let ((p1 (match-beginning 0))
	     (p2 (match-end 0)))
	 (search-forward "</span>")
	 (let ((p3 (match-beginning 0))
	       (p4 (match-end 0)))
	   (goto-char p2)
	   (cond
	    ((search-forward "<span" p3 t)
	     (goto-char (match-beginning 0))
	     (error "Unable to handle nested span tags within texttt"))
	    (t
	     (delete-region p3 p4)
	     (goto-char p3)
	     (insert "</tt>")
	     (delete-region p1 p2)
	     (goto-char p1)
	     (insert "<tt>")))))))

   (defun html-remove-span-1 (point1 point2)

;;; Here point1 and point2 are start and end positions of "<span".

     (search-forward "</span>")
     (let ((point3 (match-beginning 0))
	   (point4 (match-end 0)))
       (goto-char point2)
       (cond ((search-forward "class=\"texttt\"" point3 t)) ; just continue
	     ((search-forward "<span" point3 t)
	      (goto-char point1)
	      (error "Unable to handle nested span tags here"))
	     ((not (or (search-forward "class=\"MATH\"" point3 t)
		       (search-forward "class=\"arabic\"" point3 t)))
	      (goto-char point1)
	      (error "Unknown class here!"))
	     (t
	      (goto-char point3)
	      (kill-sexp)
	      (goto-char point1)
	      (kill-sexp)))))

   (defun html-remove-span ()
     (interactive)
     (goto-char (point-min))
     (while (search-forward "<span" nil t)
       (html-remove-span-1 (match-beginning 0) (match-end 0))))

   (defun html-fix-sub ()
     (interactive)
     (goto-char (point-min))
     (let ((saved-point (point)))
       (while (re-search-forward "</i><sub>\\(.*\\)</sub>" nil t)
;;;;                              0        1       2     3
	 (let* ((p0 (match-beginning 0))
		(p1 (match-beginning 1)))
	   (goto-char p1)
	   (search-forward "</sub>")
	   (let* ((p2 (match-beginning 0))
		  (p3 (match-end 0))
		  (subscript (buffer-substring p1 p2)))
	     (goto-char p1)
	     (when (search-forward "sub>" p2 t)
	       (error "Nested subscripts found here; must fix manually"))
	     (delete-region (+ p0 4) p3)
	     (goto-char p0)
	     (insert "_")
	     (insert subscript))))))

   (defun html-replace-string (from-string to-string start end)

;;; This is just a version of replace-string to use in a program, to
;;; avoid byte compiler warnings in some versions of Emacs.

     (save-excursion
       (goto-char start)
       (while (search-forward from-string end t)
	 (replace-match to-string end t))))

   (defun html-convert-code-to-tt-and-pre-to-code ()
     (interactive)
     (html-replace-string "<code>" "<tt>" (point-min) (point-max))
     (html-replace-string "</code>" "</tt>" (point-min) (point-max))
     (html-replace-string "<pre>" "<code>" (point-min) (point-max))
     (html-replace-string "</pre>" "</code>" (point-min) (point-max)))

   (defun html-remove-monospace-for-tt ()
     (interactive)
     (save-excursion
       (goto-char (point-min))
       (while (search-forward "<span style=\"font-family:monospace\">" nil t)
	 (replace-match "<span  class=\"texttt\">"))))

   (defun html-convert-tt-atsigns-to-code ()

;;;; E.g., convert

;;; <span  class="texttt">@@@
;;; <em>Base&nbsp;Case:</em>
;;; <br>(implies&nbsp;(not&nbsp;(consp&nbsp;x))
;;; <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="MATH"><i>&psi;</i></span>)
;;; <br>@@@
;;; </span>

;;;; to:

;;; <code>
;;; <em>Base Case:</em>
;;; (implies (not (consp x))
;;;          <span class="MATH"><i>&psi;</i></span>)
;;; </code>

     (interactive)
     (goto-char (point-min))
     (while (search-forward "<span  class=\"texttt\">@@@" nil t)
       (let ((p0 (match-beginning 0))
	     (p1 (match-end 0))
	     (newline-br-atsigns-string "\n<br>@@@"))
	 (search-forward newline-br-atsigns-string)
	 (let ((p2 (+ 1 (match-beginning 0))))
	   (html-replace-string "&nbsp;" " " p1 p2)
;;;; Now recalculate end points.
	   (goto-char p1)
	   (search-forward newline-br-atsigns-string)
	   (let ((p2 (+ 1 (match-beginning 0))))
	     (html-replace-string "<br>" "" p1 p2)
;;;; Now recalculate end points.
	     (search-forward (concat newline-br-atsigns-string "\n</span>"))
	     (replace-match "</code>")
	     (goto-char p0)
	     (delete-region p0 p1)
	     (insert "<code>"))))))

   (defun html-convert ()
     (interactive)
     (html-mode)
     (untabify (point-min) (point-max))
     (html-remove-comments)
     (html-error-on-bad-stuff)
     (html-convert-code-to-tt-and-pre-to-code)
     (html-convert-tt-atsigns-to-code)
     (html-balance-br)
     (html-remove-monospace-for-tt)

;;; It's probably much more common to have $..$ within a texttt
;;; environment than vice versa.  So we remove the "MATH" (and "arabic")
;;; stuff first, skipping over texttt.

     (html-remove-span)
     (html-end-paragraphs)
     (html-convert-tt)
     (html-fix-sub)
     (html-fix-p-tag-within-lists)
     (html-fix-strings)
     (indent-rigidly (point-min) (point-max) 1)
     (untabify (point-min) (point-max)))

   (define-key ctl-t-keymap "h" 'html-convert)
   (define-key ctl-t-keymap "m" 'html-remove-span)

;;; The following keyboard macro expects one to be on a line of the form
;;; nodexx.html
;;; for some "xx".  It switches to a (hopefully new) buffer, "nodexx",
;;; and inserts the contents of notes-version-6/nodexx.html.
;;; This probably isn't of general use but I found it useful and it
;;; might inspire development of a more general utility.

   (fset 'node
	 [?\C-a ?\C-f ?\C-f ?\C-  ?\C-e ?\M-w ?\C-x ?b ?\C-y backspace backspace backspace backspace backspace return ?\C-x ?i ?n ?o ?t ?e ?s ?- ?v ?e ?r ?s ?i ?o ?n ?- ?6 ?/ ?\C-y return ?\C-s ?< ?a ?  ?i ?d ?= ?\C-n ?\C-n ?\C-n ?\C-n ?\C-a ?\M-< ?\C-w ?\M-> ?\C-  ?\C-p ?\C-p ?\C-p ?\C-p ?\C-p ?\C-w])

   )



;;; Local Variables:
;;; mode: emacs-lisp
;;; End:

 )

(postinit)
