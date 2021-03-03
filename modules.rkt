#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         racket/contract)

(provide
 current-module
 module?
 module-ref
 module-create
 module-valid?
 module-print
 module-optimize!)

;; ---------------------------------------------------------------------------------------------------

; Module is just an opaque type representing a module
(struct module (ref)
  #:constructor-name make-module)

(define current-module (make-parameter #false))

(define/contract (module-create)
  (-> module?)
  (make-module (BinaryenModuleCreate)))

(define/contract (module-valid? [mod (current-module)])
  (() (module?) . ->* . boolean?)
  (BinaryenModuleValidate (module-ref mod)))

(define/contract (module-print [mod (current-module)])
  (() (module?) . ->* . void?)
  (BinaryenModulePrint (module-ref mod)))

(define/contract (module-optimize! [mod (current-module)])
  (() (module?) . ->* . void?)
  (BinaryenModuleOptimize (module-ref mod)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit)

  (test-case "pass"
    (check-true #true)))
