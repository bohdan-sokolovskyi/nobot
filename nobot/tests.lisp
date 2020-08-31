(uiop:define-package :nobot/tests
    (:use :cl
          :lisp-unit
          :nobot/tests/lexer
          :nobot/tests/parser)
  (:nicknames :nobot-tests)
  (:export #:run-unit-tests))

(in-package :nobot/tests)

(defun run-unit-tests ()
  (run-tests :all :nobot/tests/lexer)
  (run-tests :all :nobot/tests/parser))
