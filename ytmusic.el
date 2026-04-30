;;; ytmusic.el --- Play youtube songs with MPV from emacs  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Brandon Brodrick

;; Author: Brandon Brodrick <bbrodrick@parthenonsoftware.com>
;; Keywords: multimedia, matching

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

 ;;; Code:
(defgroup ytmusic nil
  "Customization group for the ytmusic package."
  :group 'applications)

(defcustom *ytmusic-path* "~/.emacs.d/ytmusic"
     "YTMusic path."
     :type    '(string)
     :group   'ytmusic)

(defcustom *ytmusic-playlist-file* "playlist.txt"
     "YTMusic playlist text file."
     :type    '(string)
     :group   'ytmusic)

(setq *playlist-tracks* '())

(defun ytmusic-get-youtube-recommendations ()
  (interactive)
  (let ((search-term (read-string "Song: ")))
    (with-temp-buffer
      (insert (shell-command-to-string (format "source %s/venv/bin/activate && python3 %s/get_song_url.py '%s'" *ytmusic-path* *ytmusic-path* search-term)))
      (eval-buffer))))

(defun ytmusic-play ()
  (interactive)
  (let* ((buffer "*Music*")
	(playlist *playlist-tracks*)
	(buf (get-buffer buffer)))
    (when (not buf) (vterm buffer))
    (with-current-buffer buffer
      (when (not buf)
	(progn
	  (vterm-send-string (format "cd %s" *ytmusic-path*))
	  (vterm-send-return)
	  (vterm-send-string "source venv/bin/activate")
	  (vterm-send-return)))
      (ytmusic-vterm-playlist--run playlist))))

(defun ytmusic-vterm-playlist--run (playlist)
  (let* ((cmd (format "mpv --playlist='%s'" *ytmusic-playlist-file*))
	 (playlist-file (find-file-noselect *ytmusic-playlist-file*)))
    (with-current-buffer *ytmusic-playlist-file*
      (erase-buffer)
      (insert (mapconcat '(lambda (x) (format "%s" (plist-get x :url))) *playlist-tracks* "\n"))
      (write-region (point-min) (point-max) *ytmusic-playlist-file*)
      (save-buffer))
    (vterm-send-string cmd)
    (vterm-send-return)))

(global-set-key (kbd "C-c p p")
(lambda ()
  (interactive)
  (with-current-buffer "*Music*"
    (vterm-send-string "p"))))

(provide 'ytmusic)
;;; ytmusic.el ends here
