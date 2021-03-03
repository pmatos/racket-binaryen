#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "modules.rkt"
         racket/contract)

(provide literal?
         literal-ref
         make-literal-int32)

;; ---------------------------------------------------------------------------------------------------

(struct literal (ref))

(define/contract (make-literal-int32 x)
  ((integer-in -2147483648 2147483647) . -> . literal?)
  (literal
   (BinaryenLiteralInt32 x)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
