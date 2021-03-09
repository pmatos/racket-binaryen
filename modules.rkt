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
 module-optimize!
 module-read
 module-parse
 module-write)

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

(define/contract (module-read in)
  (bytes? . -> . module?)
  (make-module (BinaryenModuleRead in)))

(define/contract (module-parse s)
  (string? . -> . module?)
  (make-module (BinaryenModuleParse s)))

(define/contract (module-write mod textual? #:sourcemap [sm #false])
  ((module? boolean?) (#:sourcemap (or/c string? #false)) . ->* . bytes?)
  (if textual?
      (BinaryenModuleAllocateAndWriteText (module-ref mod))
      (BinaryenModuleAllocateAndWrite (module-ref mod) sm)))
  
;; ---------------------------------------------------------------------------------------------------

(module+ test

  (require rackunit
           racket/port)

  (test-case "Module creation"
    (void
     (for/list ([i (in-range 1000)])
       (module-create))))

  (test-case "Module Parsing"
    (define in
      '(module
           (func (export "this_is_zero") (result i32)
                 (i32.const 0))))
    (define mod (with-output-to-string (lambda () (write in))))
    (check-true (module-valid? (module-parse mod))))
       
  (test-case "pass"
    (check-true #true)))
