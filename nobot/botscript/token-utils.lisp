(uiop:define-package :nobot/botscript/token-utils
    (:use :cl
          :anaphora
          :alexandria
          :nobot/utils
          :nobot/collections
          :nobot/botscript/nodes)
  (:export #:convert-tokens
           #:convert-token
           #:same-tokens-?
           #:same-tokens-seq-?
           #:make-tokens-source
           #:new-token
           #:is-valid-token-type-?))

(in-package :nobot/botscript/token-utils)

(defparameter *token-types* (make-hash-table :test #'eq))


;; init token types
(mapcar
 (lambda (str)
   (let ((up-string (string-upcase str)))
     (setf (gethash (intern up-string :keyword) *token-types*)
           (intern (set-<> up-string) :cl-user))))
 '("keyword"
   "unknown"
   "number-string"
   "id"))


(defgeneric convert-tokens (obj &key with-pos re-cached lazy))
(defgeneric convert-token (obj &key with-pos))
(defgeneric same-tokens-? (obj1 obj2 &key with-pos))
(defgeneric same-tokens-seq-? (obj1 obj2 &key with-pos))
(defgeneric make-tokens-source (obj))

(defmethod convert-tokens ((obj from-tokens-source-node) &key (with-pos t) re-cached lazy)
  (aif (and (not re-cached) (get-converted-tokens-seq obj))
       it
       (set-tokens-seq
        (mapcar (if lazy
                    (lambda (token)
                      (lazy! ("token-node")
                        (convert-token token
                                       :with-pos with-pos)))
                    (lambda (token)
                      (convert-token token
                                      :with-pos with-pos)))
                (get-tokens-seq obj))
        obj)))

(defmethod convert-token ((obj token-node) &key with-pos)
  (let ((converted-token (list (get-token-type obj)
                               (value-of-token obj))))
    (if with-pos
        (append converted-token
                (list (get-position obj)))
        converted-token)))

(defmethod same-tokens-? ((obj1 token-node) (obj2 token-node) &key (with-pos t))
  (and (eq (get-token-type obj1)
           (get-token-type obj2))
       (equals
        (value-of-token obj1)
        (value-of-token obj2))
       (if with-pos
           (equals
            (get-position obj1)
            (get-position obj2))
           t)))

(defmethod same-tokens-? ((obj1 list) (obj2 list) &key (with-pos t))
  (let ((len (if with-pos
                 3
                 2)))
    (and (eql (length obj1) len)
         (eql (length obj2) len)
         (let ((type-of-token-1 (first obj1))
               (type-of-token-2 (first obj2))
               (value-of-token-1 (second obj1))
               (value-of-token-2 (second obj2)))
           (and (is-valid-token-type-? type-of-token-1
                                       :error nil)
                (is-valid-token-type-? type-of-token-2
                                       :error nil)
                (cond ((and (typep value-of-token-1 'symbol)
                            (typep value-of-token-2 'symbol))
                       (equals (string-upcase (symbol-name value-of-token-1))
                               (string-upcase (symbol-name value-of-token-2))))
                      ((and (typep value-of-token-1 'string)
                            (typep value-of-token-2 'string))
                       (equals (string-upcase value-of-token-1)
                               (string-upcase value-of-token-2)))
                      (t (equals value-of-token-1 value-of-token-2)))
                (if with-pos
                    (equals (third obj1) (third obj2))
                    t))))))

(defmethod same-tokens-seq-? ((obj1 list) (obj2 list) &key (with-pos t))
  (and
   (eql (length obj1)
        (length obj2))
   (every (lambda (token-1 token-2)
            (and (eq (type-of token-1)
                     (type-of token-2))
                 (same-tokens-? token-1 token-2
                                :with-pos with-pos)))
          obj1
          obj2)))

(defmethod same-tokens-seq-? ((obj1 from-tokens-source-node) (obj2 from-tokens-source-node) &key with-pos)
  (same-tokens-seq-? (get-tokens-seq obj1) (get-tokens-seq obj2)
                     :with-pos with-pos))

(defmethod make-tokens-source ((obj from-source-code-node))
  (make-instance 'from-tokens-source-node
                 :source (get-source obj)
                 :type (get-source-type obj)
                 :tokens-seq (get-tokens-buffer obj)))

(defun new-token (&rest args)
  (let* ((copy-args (copy-list args))
         (token-type (prog1
                         (getf copy-args :type)
                       (remf copy-args :type))))
    (apply (curry #'make-instance 'token-node)
           (nconc (list :type (gethash token-type *token-types*))
                  copy-args))))


(defun is-valid-token-type-? (type &key (error t))
  (or (if (keywordp type)
          (gethash type *token-types*)
          (some (compose (curry #'equal (string-upcase (symbol-name type)))
                         #'symbol-name)
                (hash-table-values *token-types*)))
      (when error
        (error "Unknown type of token: ~A" type))))
