#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "modules.rkt"
         racket/contract)

(provide
 module-export-function)

;; ---------------------------------------------------------------------------------------------------

(struct export (ref))

(define/contract (module-export-function internal external
                                         #:module [mod (current-module)])
  ((string? string?) (#:module module?) . ->* . export?)
  (export
   (BinaryenAddFunctionExport (module-ref mod) internal external)))


;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
