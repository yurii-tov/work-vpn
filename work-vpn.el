(setq work-vpn-connected-p nil)


(defun work-vpn-connect ()
  (interactive)
  (let* ((file "~/.password-store/work-vpn.gpg")
         (server (with-temp-buffer
                   (insert-file-contents file)
                   (cadr (split-string (buffer-string) nil t)))))
    (start-file-process-shell-command
     "work-vpn" nil
     (format "gpg -qd %s | head -1 | vpncli -s connect %s && mstsc ~/connect.rdp"
             file server))
    (message "Connected 🙉")
    (setq work-vpn-connected-p t)))


(defun work-vpn-disconnect ()
  (interactive)
  (start-file-process-shell-command "work-vpn" nil "vpncli.exe disconnect")
  (message "Disconnected 🙈")
  (setq work-vpn-connected-p nil))


(defun work-vpn ()
  (interactive)
  (if work-vpn-connected-p
      (work-vpn-disconnect)
    (work-vpn-connect)))


(keymap-global-set "C-c k" 'work-vpn)
