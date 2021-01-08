(uiop:define-package :nobot/toplevel/translator
    (:use :cl)
  (:import-from :nobot/botscript
                #:parse-file)
  (:import-from :nobot/toplevel/context
                #:with-translator-context)
  (:import-from :nobot/toplevel/logger
                #:configure-logger)
  (:import-from :nobot/utils
                #:with-logger)
  (:export #:*run-and-burn*
           #:*run-and-burn-in-runtime*
           #:*run-and-burn-as-server*))

(in-package :nobot/toplevel/translator)

(defun *run-and-burn* (file)
  (with-translator-context (:source-type :file
                            :source file)
    (with-logger ((configure-logger))
      ;; Level 1: parse source file and get instance with tree of code
      
      ;; Level 2: traverse tree and collect information
      
      ;; Level 3: generate project
      
      ;; Level 4: generate code
      
      ;; Level 5: final processing
      
      )))

(defun *run-and-burn-in-runtime* ()
  ;; WIP
  )

(defun *run-and-burn-as-server* (&key (port 8086))
  ;; WIP
  )
