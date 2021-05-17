#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/functions.rkt"
         "private/types.rkt"
         "expressions.rkt"
         "modules.rkt"
         racket/contract)

(provide
 module-add-function
 module-function-count
 function-name
 function-parameter-types
 function-result-types
 function-variable-type
 (contract-out
  [function-variable-count
   (function? . -> . exact-nonnegative-integer?)]

  [module-function
   (->i ([n (mod) (or/c string?
                        (and/c exact-nonnegative-integer?
                               (</c (module-function-count mod))))])
        ([mod module?])
        [_ function?])]))

;; ---------------------------------------------------------------------------------------------------

(define/contract (module-add-function name arg-types result-types var-types body
                                      #:module [mod (current-module)])
  (->* (string? (listof type?) (listof type?) (listof type?) expression?) (#:module module?)
       function?)
  (function
   (BinaryenAddFunction (module-ref mod)
                        name
                        (type-ref (type-create arg-types))
                        (type-ref (type-create result-types))
                        (map type-ref var-types)
                        (expression-ref body))))

(define/contract (module-function-count [mod (current-module)])
  (() (module?) . ->* . exact-positive-integer?)
  (BinaryenGetNumFunctions (module-ref mod)))

(define (module-function n [mod (current-module)])
  (function
   (if (string? n)
       (BinaryenGetFunction (module-ref mod) n)
       (BinaryenGetFunctionByIndex (module-ref mod) n))))

(define/contract (function-name f)
  (function? . -> . string?)
  (BinaryenFunctionGetName (function-ref f)))

(define/contract (function-parameter-types f)
  (function? . -> . (listof type?))
  (type-expand
   (type
    (BinaryenFunctionGetParams (function-ref f)))))

(define/contract (function-result-types f)
  (function? . -> . (listof type?))
  (type-expand
   (type
    (BinaryenFunctionGetResults (function-ref f)))))

(define (function-variable-count f)
  (BinaryenFunctionGetNumVars (function-ref f)))

(define/contract (function-variable-type f n)
  (->i ([f function?]
        [n (f) (and/c exact-positive-integer?
                      (</c (function-variable-count f)))])
       [_ type?])
  (BinaryenFunctionGetVar (function-ref f) n))

(define/contract (function-get-locals-count f)
  (function? . -> . exact-nonnegative-integer?)
  (BinaryenFunctionGetNumLocals (function-ref f)))

(define/contract (function-local-has-name? f n)
  (function? exact-nonnegative-integer? . -> . boolean?)
  (BinaryenFunctionHasLocalName (function-ref f) n))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           "test-utils.rkt")

  (test-case "Module Function Check"
    (with-test-mod
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0)))
      (check = 1 (module-function-count))
      (check = 0 (function-variable-count (module-function 0)))))

  
  (test-case "pass"
    (check-true #true)))
