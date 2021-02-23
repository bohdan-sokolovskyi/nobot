;;;; Copyright (c) 2021 NOBOT
;;;; Author: Bohdan Sokolovskyi <sokol.chemist@gmail.com>


(uiop:define-package :nobot/toplevel/error-handling
    (:use :cl)
  (:import-from :alexandria
                #:with-gensyms)
  (:import-from :nobot/logger
                #:log-error)
  (:export
   ;; Level 1 errors
   #:raise-bs-lexer-error
   #:raise-bs-parser-error
   ;; Level 2 errors
   #:raise-bs-post-process-error
   #:lexer-error-handler
   #:toplevel-error-handler
   #:get-error-msg))

(in-package :nobot/toplevel/error-handling)

;;TODO: see issue #3

;; Level 1 errors
(define-condition bs-lexer-error (error)
  ((error-msg
    :initarg :error-msg
    :initform nil
    :accessor get-error-msg)))

(define-condition bs-parser-error (error) ())

(defmacro raise-bs-lexer-error (msg &rest rest)
  `(error 'bs-lexer-error
          :error-msg (log-error ,msg ,@rest)))

(defmacro raise-bs-parser-error (msg &rest rest)
  `(progn
     (error 'bs-parser-error
            :error-msg (log-error ,msg ,@rest))
     nil))

(defmacro lexer-error-handler ((action-on-catch) &body body)
  `(handler-case
       (progn ,@body)
     (bs-lexer-error (c)
       (funcall ,action-on-catch))))

;; Level 2 errors
(define-condition bs-post-process-error (error) ())

(defmacro raise-bs-post-process-error (msg &rest rest)
  `(error 'bs-post-process-error
          :error-msg (log-error ,msg ,@rest)))

(defmacro toplevel-error-handler (&body body)
  `(handler-case
       (progn ,@body)
     (bs-lexer-error (c)
       (declare (ignore c))
       nil)
     (bs-parser-error (c)
       (declare (ignore c))
       nil)))

