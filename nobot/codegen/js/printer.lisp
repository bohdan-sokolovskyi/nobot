;;;; Copyright (c) 2021 Bohdan Sokolovskyi
;;;; Author: Bohdan Sokolovskyi <sokol.chemist@gmail.com>


(uiop:define-package :nobot/codegen/js/printer
    (:use :cl)
  (:import-from :anaphora
                #:aif
                #:it)
  (:import-from :nobot/utils
                #:to-string)
  (:export #:print-js-code-from-tree))

(in-package :nobot/codegen/js/printer)

(defvar *stream*)

;;;;;;;;;;;;;;;;;;;;;; js code printer ;;;;;;;;;;;;;;;;;;;;;;
(defmacro print-js-code-from-tree ((stream) lisp-form)
  `(let ((*stream* ,stream))
     (pprint-js-tree ,lisp-form)))

;;TODO check extra args
;;TODO add newlines
;;TODO add whitespaces
(defun print-js-tree (tree)
  (mapc #'pprint-js-tree tree))

(defun pprint-js-tree (tree)
  (let ((root (car tree)))
    (case root
      (:js
       (mapc #'pprint-js-tree (cdr tree)))
      (:multi-comment
       (format *stream* "/* ~a */" (second tree)))
      (:import
       (format *stream* "import {~{~a~^, ~}} from ~a;"
               (second tree)
               (third tree)))
      (:const
       (format *stream* "const ~a = ~a;"
               (second tree)
               (let ((*stream* nil))
                 (pprint-js-tree (third tree)))))
      (:new-object
       (format *stream* "new ~a(~{~a~^, ~});"
               (second tree)
               (let ((*stream* nil))
                 (mapcar #'pprint-js-tree (cddr tree)))))
      (:object
       (format *stream* "{~{~a~^, ~}}"
               (mapcar
                (lambda (key-val)
                  (format nil "~a: ~a"
                          (car key-val)
                          (let ((*stream* nil))
                            (pprint-js-tree (second key-val)))))
                (cdr tree))))
      (:stmt
       (format *stream* "~a;"
               (let ((*stream* nil))
                 (pprint-js-tree (second tree)))))
      (:chain-expr
       (format *stream* "~{~a~^.~}"
               (let ((*stream* nil))
                 (mapcar #'pprint-js-tree (cddr tree)))))
      (:list
       (format *stream* "[~{~a~^, ~}]"
               (let ((*stream* nil))
                 (mapcar #'pprint-js-tree (cdr tree)))))
      (:call-expr
       (format *stream* "~a(~{~a~^, ~})"
               (second tree)
               (let ((*stream* nil))
                 (mapcar #'pprint-js-tree (cddr tree)))))
      (:if-stmt
       (format *stream* "if(~a) {~{~a~^~%~}} ~a"
               (pprint-js-tree (second tree))
               (mapcar #'pprint-js-tree (third tree))
               (let ((else (fourth tree)))
                 (if (null else)
                     ""
                     (format nil "else {~{~a~^~%~}}"
                             (mapcar #'pprint-js-tree else))))))
      (:arrow-fun
       (format *stream* "(~{~a~^, ~}) => {~{~a~^~%~}}"
               (second tree)
               (let ((*stream* nil))
                 (mapcar #'pprint-js-tree (cddr tree)))))
      ((:str :number)
       (format *stream* "~a" (second tree)))
      (:null
       (format *stream* "null"))
      (t (error "unknown js rule ~a" root)))))

;; example
;; (:js (:multi-comment
;;   "Bot Tom generated by NOBOT platform v.0.1 in XX.XX.XX
;;    Author: Bohdan Sokolovskyi
;;    Version: 0.1")
;;  (:import ("Bot" "TelegramApplication" "WebApplication") "botlib/src/wisteria.js")
;;  (:const "bot"
;;          (:new-object "Bot"
;;                       (:object
;;                        ("name" (:str "Tom"))
;;                        ("type" (:str "chat"))
;;                        ("startFrom" (:str "a")))))
;;  (:const "application"
;;          (:new-object "WebApplication"
;;                       (:object
;;                        ("host" (:str "localhost"))
;;                        ("port" (:num 3000)))))
;;  (:chain-expr "bot"
;;               (:call-expr "use"
;;                           (:object
;;                            "userName"
;;                            (:null))))
;;  ;; generate by map fun
;;  (:chain-expr "bot"
;;               (:call-expr "on"
;;                           (:str "a")
;;                           (:if-expr (:eq "inputMsg" (:str "Hello"))
;;                                     (:body
;;                                      (:chain-expr "controller"
;;                                                   (:call-expr "say"
;;                                                               (:str "Hello, what is your name?")))
;;                                      (:chain-expr "controller"
;;                                                   (:call-expr "next"
;;                                                               (:str "b"))))
;;                                     (:body
;;                                      (:chain-expr "controller"
;;                                                   (:call-expr "next"
;;                                                               (:str "def")))))))
;;  (:chain-expr "bot"
;;               (:call-expr "on"
;;                           (:str "b")
;;                           (:arrow-fun ("inputMsg" "controller")
;;                                       (:body
;;                                        (:chain-expr "controller"
;;                                                     (:call-expr "save"
;;                                                                 "inputMsg"
;;                                                                 (:str "userName")))
;;                                        (:chain-expr "controller"
;;                                                     (:call-expr "next"
;;                                                                 (:str "a")))))))
;;  (:chain-expr "bot"
;;               (:call-expr "on"
;;                           (:str "def")
;;                           (:arrow-fun "inputMsg" "controller"
;;                                       (:body
;;                                        (:chain-expr "controller"
;;                                                     (:call-expr "say"
;;                                                                 "Sorry, i don't understand you"))
;;                                        (:chain-expr "controller"
;;                                                     (:call-expr "next"
;;                                                                 (:str "a")))))))
;;  (:chain-expr "bot"
;;               (:call-expr ))
;;  (:chain-expr "application"
;;               (:call-expr "configure"
;;                           "bot")
;;               (:call-expr "run")))
