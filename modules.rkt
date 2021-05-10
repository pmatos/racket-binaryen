#lang racket/base
;; ---------------------------------------------------------------------------------------------------

(require "private/binaryen-ffi.rkt"
         "private/modules.rkt"
         racket/contract)

(provide
 module?
 module-ref
 module-create
 module-valid?
 module-print
 module-optimize!
 module-read
 (contract-out
  [module-parse (string? . -> . module?)]
  [current-module (parameter/c (or/c #false module?))])
 module-write)

;; ---------------------------------------------------------------------------------------------------

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

(define/contract (module-read in)
  (bytes? . -> . module?)
  (make-module (BinaryenModuleRead in)))

(define/contract (module-write mod textual? #:sourcemap [sm #false])
  ((module? boolean?) (#:sourcemap (or/c string? #false)) . ->* . bytes?)
  (if textual?
      (BinaryenModuleAllocateAndWriteText (module-ref mod))
      (BinaryenModuleAllocateAndWrite (module-ref mod) sm)))

;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           "test-utils.rkt"
           racket/port)

  (test-case "Module creation"
    (void
     (for/list ([i (in-range 1000)])
       (module-create))))

  (test-case "Module Parsing"
    (with-test-mod
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0)))
      
      (check-true (module-valid?))))
       
  (test-case "pass"
    (check-true #true)))
