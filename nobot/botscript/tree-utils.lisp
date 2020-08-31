(uiop:define-package :nobot/botscript/tree-utils
    (:use :cl
          :anaphora)
  (:import-from :nobot/utils
                #:defcontextvar
                #:setf-context-var
                #:equals)
  (:import-from :nobot/botscript/nodes
                #:from-parse-tree-source-node
                #:get-parse-tree
                #:token-node
                #:get-token-type
                #:value-of-token)
  (:export #:with-tree
           #:@revert-tree
           #:@insert-new-tree
           #:@is-token-of-value
           #:@is-token-of-type
           #:make-tree-from-token))

(in-package :nobot/botscript/tree-utils)

(defcontextvar *tree*)
(defcontextvar *current-sort-type*)

(defgeneric make-tree-from-token (obj))
(defgeneric same-parse-tree-? (obj1 obj2))

(defmacro with-tree ((&optional sort-type) &body body)
  `(multiple-value-bind (res-body new-tree)
       (let* ((*current-sort-type* ',sort-type)
              (*tree* (when *current-sort-type*
                        (list *current-sort-type*))))
         (values (progn ,@body) *tree*))
     (when ',sort-type
       (@insert-new-tree new-tree))
     (if ',sort-type
         res-body
         new-tree)))

(defun @revert-tree ()
  (setf-context-var *tree* nil))

;;TODO: poor impl, i think
(defun @insert-new-tree (new-tree)
  (labels ((%insert-new-tree (tree)
             (when tree
               (let ((root (car tree))
                     (tail (cdr tree)))
                 (if (eq root *current-sort-type*)
                     (cons root (append tail (when new-tree
                                               (list new-tree))))
                     (cons root (mapcar #'%insert-new-tree tail)))))))
    (setf-context-var *tree* (if *tree*
                                 (%insert-new-tree *tree*)
                                 new-tree))))

(defmethod make-tree-from-token ((obj token-node))
  (list (get-token-type obj) (value-of-token obj)))

(defmethod same-parse-tree-? ((obj1 from-parse-tree-source-node)
                              (obj2 from-parse-tree-source-node))
  (same-parse-tree-? (get-parse-tree obj1)
                     (get-parse-tree obj2)))

(defmethod same-parse-tree-? ((obj1 list) (obj2 list))
  )
