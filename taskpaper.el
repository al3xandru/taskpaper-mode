;;; taskpaper-mode.el --- Major mode for editing TaskPaper files

;; Copyright (C) 2016 Alex Popescu

;; Author: Alex Popescu <alex@mypopescu.com>
;; Original: Mattias Jadelius <https://github.com/jeddthehumanoid>
;; Keywords: taskpaper
;; Version: 0.0.2

;; This file is not part of Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License along
;; with this program; if not, write to the Free Software Foundation, Inc.,
;; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

;;; Commentary:

;; This is a major mode for editing TaskPaper docs.
;; It was initially developed by Mattias Jadelius. 

;;; Installation:

;; To install, just drop this file into a directory in your
;; `load-path' and (optionally) byte-compile it.  To automatically
;; handle files ending in '.yml', add something like:
;;
;;    (require 'yaml-mode)
;;    (add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
;;
;; to your .emacs file.
;;
;; Unlike python-mode, this mode follows the Emacs convention of not
;; binding the ENTER key to `newline-and-indent'.  To get this
;; behavior, add the key definition to `yaml-mode-hook':
;;
;;    (add-hook 'yaml-mode-hook
;;     '(lambda ()
;;        (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;;; Known Bugs:

;;; Code:


;; User definable variables
;;;###autoload
(defgroup taskpaper nil
  "Support for TaskPaper todo format"
  :group 'languages
  :prefix "taskpaper-")

(defcustom taskpaper-mode-hook nil
  "*Hook run by `taskpaper-mode'."
  :type 'hook
  :group 'taskpaper)

(defcustom taskpaper-append-date-to-done nil
  "Include date when tagging task as @done"
  :type 'boolean
  :group 'taskpaper)

;; Constants
(defconst taskpaper-mode-vresion "0.0.2" "Version of `taskpaper-mode'.")

(defconst taskpaper-font-lock-keywords
  '(
    (".*@done.*" . font-lock-comment-face)
    (".*:$" . font-lock-function-name-face)
    ("^ *[^- ].*[^:]$" . font-lock-comment-face)
    ("@.*" . font-lock-variable-name-face)))

;; Mode setup
(defvar taskpaper-mode-map
  (let ((map (make-sparse-keymap)))
    ;; (define-key map (kbd "<S-RET>") 'taskpaper-focus-selected-project)
    ;; (define-key map (kbd "<S-backspace>") 'taskpaper-unfocus-project)
    ;; (define-key map (kbd "C-c d") 'taskpaper-toggle-done)
    (define-key map (kbd "C-c l") 'taskpaper-choose-project)
    map)
  "`taskpaper-mode' keymap")

;;;###autoload
(define-derived-mode taskpaper-mode text-mode "TaskPaper"
  "Simple mode to edit TaskPaper.

\\{taskpaper-mode-map}"
  (setq font-lock-defaults '(taskpaper-font-lock-keywords)))

(defun taskpaper-choose-project ()
  "Show a list of projects to chose from."
  (let ((projects '())
        (startpoint (point))
        (x 0)
        (buffer (concat (buffer-name) ": Projects")))
    (goto-char 0)
    ;;Gather list of projects
    (while (re-search-forward ":$" nil t)
      (back-to-indentation)
      (setq projects (append projects (list (buffer-substring-no-properties (point) (- (line-end-position) 1)))))
      (end-of-line))

    (goto-char startpoint)

    (when (get-buffer buffer)
      (kill-buffer buffer))
    ;;Open popupwindow for selecting project
    (split-window-vertically (- (+ (length projects) 1)))
    (other-window 1)
    (get-buffer-create buffer)
    (switch-to-buffer buffer)
    (while (< x (length projects))
      (insert (elt projects x))
      (insert "\n")
      (setq x (+ x 1)))
    (goto-char 0))
  (toggle-read-only t)
  (local-set-key (kbd "<return>") 'taskpaper-projectwindow-select)
  (local-set-key (kbd "<ESC> <ESC>") 'taskpaper-projectwindow-esc))

  ; (defun taskpaper-projectwindow-esc()
  ;   "Exit projectwindow, not selecting a project"
  ;   (interactive)
  ;   (local-unset-key (kbd "<return"))
  ;   (local-unset-key (kbd "<ESC> <ESC>"))
  ;   (kill-buffer)
  ;   (delete-window)
  ;   (other-window (- 1)))

  ; (defun taskpaper-projectwindow-select()
  ;   "Action to perform when project is selected in project window."
  ;   (interactive)
  ;   (local-unset-key (kbd "<return>"))
  ;   (let ((buffer (substring (buffer-name) 0 -10)) project)
  ;     (message "substring: %s" buffer)
  ;     (setq project (buffer-substring-no-properties (line-beginning-position) (line-end-position)))
  ;     (kill-buffer)
  ;     (delete-window)
  ;     (other-window (- 1))
  ;     (switch-to-buffer buffer)

  ;     (goto-char 0)
  ;     (re-search-forward project)
  ;     (taskpaper-unfocus-project)
  ;     (taskpaper-focus-selected-project)))

  ; (defun taskpaper-focus-selected-project()
  ;   "Hide everything not related to project under cursor."
  ;   (interactive)
  ;   (let ((startpoint (point)) start end)
  ;     (end-of-line)
  ;     (re-search-backward ":$")
  ;     (beginning-of-line)
  ;     (setq start (point))
  ;     (re-search-forward ":$")
  ;     (re-search-forward ":$")
  ;     (beginning-of-line)
  ;     (setq end (point))
  ;     (add-text-properties 1 start '(invisible t))
  ;     (add-text-properties end (point-max) '(invisible t))
  ;     (goto-char startpoint)))

  ; (defun taskpaper-unfocus-project()
  ;   "Show all projects if focused on one."
  ;   (interactive)
  ;   (add-text-properties 1 (point-max) '(invisible nil)))

  ; (defun taskpaper-toggle-done()
  ;   "Toggle done status on task, this sets @done-tag with date."
  ;   (interactive)
  ;   (let ((startpoint (point)) (line (line-number-at-pos)))
  ;     (back-to-indentation)
  ;     (re-search-forward "@done" nil 2)
  ;     (if (= line (line-number-at-pos))
  ;         (progn
  ;           (end-of-line)
  ;           (re-search-backward "@")
  ;           (backward-char)
  ;           (kill-line)
  ;           )
  ;       (progn
  ;         (goto-char startpoint)
  ;         (end-of-line)
  ;         (insert " @done")
  ;         )
  ;       )
  ;     (when (not (equal (point) (line-end-position)))
  ;       (goto-char startpoint))))

;; (defun taskpaper-mode ()
;;   "Major mode for editing taskpaper styled files."
;;   (interactive)
;;   (kill-all-local-variables)

;;   (setq major-mode 'taskpaper-mode)
;;   (setq mode-name "Taskpaper") ; for display purposes in mode line
;;   (use-local-map taskpaper-mode-map)

;;   (taskpaper-functions)
;;   (setq font-lock-defaults '(tpKeywords))

;;   ;; Dont wrap lines
;;   (toggle-truncate-lines t)

;;   ;; ... other code here

;;   (run-hooks 'taskpaper-mode-hook))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.taskpaper$" . taskpaper-mode))

(provide 'taskpaper-mode)
