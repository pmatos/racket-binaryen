#lang racket/base
;; ---------------------------------------------------------------------------------------------------
(require racket/contract
         racket/port
         racket/string
         rackunit
         binaryen)

;; ---------------------------------------------------------------------------------------------------

(define/contract (create-square)
  (-> module?)
  (parameterize ([current-module (module-create)])
    (module-add-function "square"
                         (list type-int32)
                         (list type-int32)
                         '()
                         (make-mul-int32 (make-localget 0 type-int32)
                                         (make-localget 0 type-int32)))
    (module-export-function "$square" "square")
    (current-module)))

(test-case "module printing"
  (define s
    (with-output-to-string
      (lambda () (module-print (create-square) #:colors #false))))
  (check-true (string-contains? s "(module"))
  (check-true (string-contains? s "(param $0 i32) (result i32)")))
