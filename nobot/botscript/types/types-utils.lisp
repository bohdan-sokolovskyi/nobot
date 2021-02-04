;;;; Copyright (c) 2021 NOBOT-S
;;;; Author: Bohdan Sokolovskyi <sokol.chemist@gmail.com>


(uiop:define-package :nobot/botscript/types/types-utils
    (:use :cl)
  (:import-from :alexandria
                #:with-gensyms)
  (:import-from :nobot/utils
                #:reintern)
  (:export #:define-types
           #:convert-type
           #:$get-value
           #:$get-description
           #:get-from-type
           #:get-type-value-list))

(in-package :nobot/botscript/types/types-utils)

(defclass $type ()
  ((value :initarg :value
          :type symbol
          :reader $get-value)
   (description :initarg :description
                :type string
                :reader $get-description)))

(defgeneric get-from-type (type class-type what-need)
  (:documentation "
Class type: [:token - for lexer, :sort - for parser]
What need: [:symbol, :symbol-description]")
  (:method (type class-type what-need)
    (error "unexpected class type ~a. Expected: [:token or :sort]"
           class-type)))

(defgeneric get-type-value-list (class-type)
  (:documentation "Class type: [:token - for lexer, :sort - for parser]")
  (:method (class-type)
    (error "unexpected class-type: ~a. Epxected: [:token or :sort]"
           class-type)))


(defmacro define-types (&rest types-and-descriptions-list)
  (with-gensyms (table up-string value description)
    `(let ((,table (make-hash-table :test #'eq)))
       (mapcar
        (lambda (type-and-description)
          (destructuring-bind (&key ,value ,description)
              type-and-description
            (progn
              (assert (and ,value ,description))
              (let ((,up-string (string-upcase ,value)))
                (setf (gethash (intern ,up-string :keyword) ,table)
                      (make-instance '$type
                                     :value (intern (set-<> ,up-string) :cl-user)
                                     :description ,description))))))
        ,types-and-descriptions-list)
       ,table)))

(defun convert-type (type &key only-to-symbol)
  (let ((package (if only-to-symbol
                     :cl-user
                     :keyword)))
    (cond
      ((stringp type) (intern type package))
      ((keywordp type) type)
      ((symbolp type) (reintern type package))
      (t (error "representation of sort type maybe only is string, keyword or symbol")))))

(defun set-<> (str)
  (format nil "<~a>" str))
