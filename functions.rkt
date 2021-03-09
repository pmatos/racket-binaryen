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

(define/contract (module-function-count #:module [mod (current-module)])
  (() (#:module module?) . ->* . exact-positive-integer?)
  (BinaryenGetNumFunctions (module-ref mod)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           racket/port)

  (test-case "Module Function Check"
    (define in
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0))))
    (define mod
      (module-parse
       (with-output-to-string (lambda () (write in)))))
    
    (check = 1 (module-function-count #:module mod)))

  
  (test-case "pass"
    (check-true #true)))
