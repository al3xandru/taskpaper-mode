# TaskPaper major mode for Emacs

This is a slightly modernized fork of [taskpaper.el][taskpaper.el] providing
the following features:

* improved syntax recognition
* support for navigating projects
* focusing on a project
* configurable append date to done tasks

## Instalation

Put `taskpaper-mode.el` file somewhere and add it to your `init.el`:

```elisp
(load-file "~/taskpaper-mode/taskpaper-mode.el")
(require 'taskpaper-mode)
```

### Spacemacs

If  you are using Spacemacs:

```elisp
(defun dotspacemacs/layers ()
    ;; ...
    dotspacemacs-additional-packages
    '(
        (taskpaper-mode :location (recipe :fetcher github :repo "al3xandru/taskpaper-mode" :branch dev))
     ))
```

## Keyboard shortcuts
 
    S-return     Focus project under cursor
    S-backspace  Back to all projects
    C-c l        Chose project from list
    C-c d        Toggle done state

## Configuration options

Append date to @done:

```elisp
    (setq taskpaper-append-date-to-done t)
```

Add special faces for tags:

```elisp
(font-lock-add-keywords 'taskpaper-mode
                      '(
                        ("@important" . font-lock-keyword-face)
                        ("@today" . font-lock-string-face)))
```

[taskpaper.el]: https://github.com/jedthehumanoid/taskpaper.el
