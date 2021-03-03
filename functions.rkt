#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "expressions.rkt"
         "modules.rkt"
         "types.rkt"
         racket/contract)

(provide
 module-add-function)

;; ---------------------------------------------------------------------------------------------------

(struct function (ref))

(define/contract (module-add-function name arg-types result-types var-types body #:module [mod (current-module)])
  ((string? (listof type?) (listof type?) (listof type?) expression?) (#:module module?) . ->* . function?)
  (function
   (BinaryenAddFunction (module-ref mod)
                        name
                        (type-ref (type-create arg-types))
                        (type-ref (type-create result-types))
                        (map type-ref var-types)
                        (expression-ref body))))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
