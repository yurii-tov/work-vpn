(setq work-vpn-connected-p nil)


(defun work-vpn-setup ()
  (with-current-buffer "*work-vpn*"
    (use-local-map
     (define-keymap :parent (current-local-map)
       "g" (lambda ()
             (interactive)
             (work-vpn-disconnect)
             (work-vpn-connect))
       "k" 'work-vpn-disconnect))
    (setq-local comint-output-filter-functions
                (remq 'comint-watch-for-password-prompt
                      comint-output-filter-functions))))


(defun work-vpn-connect ()
  (interactive)
  (let* ((file "~/.password-store/work-vpn.gpg")
         (server (with-temp-buffer
                   (insert-file-contents file)
                   (cadr (split-string (buffer-string) nil t)))))
    (async-shell-command
     (format "gpg -qd %s | head -1 | vpncli -s connect %s && mstsc ~/connect.rdp"
             file server)
     "*work-vpn*"))
  (work-vpn-setup)
  (message "Connected 🙉")
  (setq work-vpn-connected-p t))


(defun work-vpn-disconnect ()
  (interactive)
  (when-let* ((b (get-buffer "*work-vpn*"))
              ((get-buffer-process "*work-vpn*")))
    (with-current-buffer b
      (comint-kill-subjob)
      (sit-for 2)))
  (async-shell-command "vpncli.exe disconnect" "*work-vpn*")
  (sit-for 2)
  (message "Disconnected 🙈")
  (setq work-vpn-connected-p nil))


(defun work-vpn ()
  (interactive)
  (if work-vpn-connected-p
      (work-vpn-disconnect)
    (work-vpn-connect)))


(keymap-global-set "C-c k" 'work-vpn)
