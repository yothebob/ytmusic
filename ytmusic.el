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

(defun ytmusic-song (url)
  (let ((found-track
	 (cl-find-if #'(lambda (x) (equal (plist-get x :url) url)) *playlist-tracks*)))
    (when found-track (message (format "Playing %s By %s..."
				       (plist-get found-track :title)
				       (plist-get found-track :artist))))))

(defun ytmusic-edit-youtube-recommendations ()
  (interactive)
  (switch-to-buffer "*youtube-reccomendations*")
  (with-current-buffer "*youtube-reccomendations*"
    (erase-buffer)
    (insert ";; M-x eval-buffer to save edits.\n")
    (insert "(setq *playlist-tracks* '(\n")
    (dolist (track *playlist-tracks*)
      (insert (format "  %S\n" track)))
    (insert "))\n")
      (lisp-interaction-mode)))

(defun ytmusic-get-youtube-recommendations ()
  (interactive)
  (let ((search-term (read-string "Song: ")))
    (with-temp-buffer
      (insert (shell-command-to-string (format "source %s/venv/bin/activate && python3 %s/get_song_url.py '%s'" *ytmusic-path* *ytmusic-path* search-term)))
      (eval-buffer))))

(defun ytmusic-save-playlist ()
  (interactive)
  (let ((new-playlist (read-string "Playlist Name: ")))
   (with-temp-file (format "%s/playlists/%s.el" *ytmusic-path* new-playlist)
    (insert "(setq *playlist-tracks* '(\n")
    (dolist (track *playlist-tracks*)
      (insert (format "  %S\n" track)))
    (insert "))\n"))))

(defun ytmusic-load-playlist (pl)
  (interactive)
  (with-temp-buffer
      (insert-file-literally pl)
      (eval-buffer)))

(defun ytmusic-play ()
  (interactive)
  (let* ((buffer "*Music*")
	 (playlist (ytmusic-load-playlist (read-file-name "Playlist: " (concat *ytmusic-path* "/playlists/"))))
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
	 (playlist-file (find-file-noselect (concat *ytmusic-path* "/" *ytmusic-playlist-file*))))
    (with-current-buffer *ytmusic-playlist-file*
      (erase-buffer)
      (insert (mapconcat '(lambda (x) (format "%s" (plist-get x :url))) *playlist-tracks* "\n"))
      (write-region (point-min) (point-max) *ytmusic-playlist-file*)
      (save-buffer))
    (vterm-send-string cmd)
    (vterm-send-return)))

(defun ytmusic-send-cmd (cmd)
(with-current-buffer "*Music*"
    (vterm-send-string cmd)))

(defun ytmusic-send-pause/play ()
  (interactive)
  (ytmusic-send-cmd "p"))

(defun ytmusic-send-quit ()
  (interactive)
  (ytmusic-send-cmd "q"))

(defun ytmusic-send-vol-down (arg)
  (interactive "p")
  (dotimes (i arg)
  (ytmusic-send-cmd "9")))

(defun ytmusic-send-vol-up (arg)
  (interactive "p")
  (dotimes (i arg)
  (ytmusic-send-cmd "0")))

(defun ytmusic-send-next-song (arg)
  (interactive "p")
  (dotimes (i arg)
  (ytmusic-send-cmd ">")))

(defun ytmusic-send-prev-song (arg)
  (interactive "p")
  (dotimes (i arg)
  (ytmusic-send-cmd "<")))

(global-set-key (kbd "C-c p <") 'ytmusic-send-prev-song)
(global-set-key (kbd "C-c p >") 'ytmusic-send-next-song)
(global-set-key (kbd "C-c p 0") 'ytmusic-send-vol-up)
(global-set-key (kbd "C-c p 9") 'ytmusic-send-vol-down)
(global-set-key (kbd "C-c p p") 'ytmusic-send-pause/play)
(global-set-key (kbd "C-c p q") 'ytmusic-send-quit)

(provide 'ytmusic)
;;; ytmusic.el ends here
